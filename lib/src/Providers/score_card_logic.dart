import 'dart:collection';
import 'package:flutter/material.dart';

class ScoreCardLogic {
  // =============================================================
  // OPTIONAL HOOKS (DB / SERVICE LAYER)
  // =============================================================

  void Function()? onPersist;
  void Function()? onUndoPersist;
  void Function()? onOverCompleted;
  // =============================================================
  // MATCH STATE
  // =============================================================

  int totalRuns = 0;
  int wickets = 0;

  int legalBalls = 0;
  int ballsThisOver = 0;

  final List<String> ballHistory = [];

  // =============================================================
  // EXTRAS
  // =============================================================

  int wides = 0;
  int noBalls = 0;
  int byes = 0;
  int legByes = 0;

  // =============================================================
  // BATTING STATS (CURRENT BATSMAN)
  // =============================================================

  int batRuns = 0;
  int ballsFaced = 0;
  int fours = 0;
  int sixes = 0;
  int dotBalls = 0;

  // Track two batsmen specifically
  int strikerIndex = 0; // 0 for Batsman 1, 1 for Batsman 2

  // We will now use these maps to store individual stats
  Map<String, dynamic> batsman1 = {
    'name': 'Virat Kohli', 'runs': 0, 'balls': 0, 'fours': 0, 'sixes': 0, 'sr': 0.0
  };
  Map<String, dynamic> batsman2 = {
    'name': 'MS Dhoni', 'runs': 0, 'balls': 0, 'fours': 0, 'sixes': 0, 'sr': 0.0
  };

  Map<String, dynamic> currentBowler = {
    'name': 'Starc',
    'overs': 0.0,
    'runs': 0,
    'wickets': 0,
    'er': 0.0
  };

  // =============================================================
  // BOWLING STATS (CURRENT BOWLER)
  // =============================================================

  int ballsBowled = 0;
  int runsConceded = 0;
  int wicketsTaken = 0;
  int maidens = 0;

  int runsThisOver = 0;

  // =============================================================
  // UNDO STACK
  // =============================================================

  final ListQueue<_ScoreSnapshot> _undoStack = ListQueue();

  // =============================================================
  // GETTERS
  // =============================================================

  String get overs => '${legalBalls ~/ 6}.${legalBalls % 6}';

  double get strikeRate =>
      ballsFaced == 0 ? 0 : (batRuns / ballsFaced) * 100;

  String get strikeRateFormatted =>
      strikeRate.toStringAsFixed(2);

  double get economyRate =>
      ballsBowled == 0 ? 0 : runsConceded / (ballsBowled / 6);

  bool get canUndo => _undoStack.isNotEmpty;

  // =============================================================
  // SNAPSHOT HANDLING
  // =============================================================

  void _saveSnapshot() {
    _undoStack.addLast(_ScoreSnapshot.from(this));
  }

  // =============================================================
  // RUNS (LEGAL DELIVERY)
  // =============================================================

  void addRuns(int runs) {
    _validateMatch();
    _saveSnapshot();

    totalRuns += runs;
    batRuns += runs;
    ballsFaced++;
    legalBalls++;
    ballsThisOver++;
    ballsBowled++;
    runsConceded += runs;
    runsThisOver += runs;

    var currentStriker = (strikerIndex == 0) ? batsman1 : batsman2;

    currentStriker['runs'] += runs;
    currentStriker['balls'] += 1;
    if (runs == 4) currentStriker['fours'] += 1;
    if (runs == 6) currentStriker['sixes'] += 1;

    currentStriker['sr'] = (currentStriker['runs'] / currentStriker['balls']) * 100;

    if (runs % 2 != 0) {
      _switchStrike();
    }

    if (runs == 0) dotBalls++;
    if (runs == 4) fours++;
    if (runs == 6) sixes++;

    ballHistory.add(runs.toString());

    _checkOverCompletion();
    onPersist?.call();
  }

  void _switchStrike() {
    strikerIndex = (strikerIndex == 0) ? 1 : 0;
    debugPrint("Strike Switched: Now Batsman ${strikerIndex + 1} is on strike");
  }

  // =============================================================
  // WICKET (LEGAL DELIVERY)
  // =============================================================

  void addWicket() {
    _validateMatch();
    _saveSnapshot();

    wickets++;
    wicketsTaken++;
    ballsFaced++;
    legalBalls++;
    ballsThisOver++;
    ballsBowled++;

    ballHistory.add('W');

    _checkOverCompletion();
    onPersist?.call();
  }

  // =============================================================
  // EXTRAS (ILLEGAL)
  // =============================================================

  void addWide({int runs = 1}) {
    _saveSnapshot();

    totalRuns += runs;
    wides++;
    runsConceded += runs;

    ballHistory.add('WD');
    onPersist?.call();
  }

  void addNoBall({int battingRuns = 0}) {
    _saveSnapshot();

    totalRuns += 1 + battingRuns;
    noBalls++;
    runsConceded += 1 + battingRuns;

    batRuns += battingRuns;
    if (battingRuns == 4) fours++;
    if (battingRuns == 6) sixes++;

    ballHistory.add(battingRuns > 0 ? 'NB+$battingRuns' : 'NB');
    onPersist?.call();
  }

  void addByes(int runs) {
    _saveSnapshot();

    totalRuns += runs;
    byes += runs;

    ballsFaced++;
    legalBalls++;
    ballsThisOver++;
    ballsBowled++;

    ballHistory.add('B+$runs');

    _checkOverCompletion();
    onPersist?.call();
  }

  void addLegByes(int runs) {
    _saveSnapshot();

    totalRuns += runs;
    legByes += runs;

    ballsFaced++;
    legalBalls++;
    ballsThisOver++;
    ballsBowled++;

    ballHistory.add('LB+$runs');

    _checkOverCompletion();
    onPersist?.call();
  }

  // =============================================================
  // OVER MANAGEMENT
  // =============================================================

  void _checkOverCompletion() {
    if (ballsThisOver == 6) {
      // 1. Check for Maiden Over before resetting
      if (runsThisOver == 0) {
        maidens++;
        currentBowler['maidens'] = (currentBowler['maidens'] ?? 0) + 1;
      }

      // 2. CRITICAL: Clear the ball history list for the UI reset
      ballHistory.clear();

      // 3. Reset over-specific counters
      ballsThisOver = 0;
      runsThisOver = 0;

      _switchStrike();

      // 4. Optional: Trigger a specific callback if you want to show a dialog
      onOverCompleted?.call();
    }
  }
  // =============================================================
  // UNDO
  // =============================================================

  void undoLastAction() {
    if (_undoStack.isEmpty) return;

    final snapshot = _undoStack.removeLast();
    snapshot.restore(this);
    onUndoPersist?.call();
  }

  // =============================================================
  // VALIDATION
  // =============================================================

  void _validateMatch() {
    if (wickets >= 10) {
      throw Exception('All wickets are down');
    }
  }

  // =============================================================
  // RESET MATCH
  // =============================================================

  void resetMatch() {
    totalRuns = 0;
    wickets = 0;
    legalBalls = 0;
    ballsThisOver = 0;

    wides = 0;
    noBalls = 0;
    byes = 0;
    legByes = 0;

    batRuns = 0;
    ballsFaced = 0;
    fours = 0;
    sixes = 0;
    dotBalls = 0;

    ballsBowled = 0;
    runsConceded = 0;
    wicketsTaken = 0;
    maidens = 0;

    runsThisOver = 0;
    ballHistory.clear();
    _undoStack.clear();
  }

  // =============================================================
  // SNAPSHOTS (FOR DATABASE)
  // =============================================================

  Map<String, dynamic> battingSnapshot() => {
    'runs': batRuns,
    'balls': ballsFaced,
    'fours': fours,
    'sixes': sixes,
    'dotBalls': dotBalls,
    'strikeRate': strikeRate,
  };

  Map<String, dynamic> bowlingSnapshot() => {
    'overs': ballsBowled / 6,
    'runsConceded': runsConceded,
    'wickets': wicketsTaken,
    'maidens': maidens,
    'economy': economyRate,
  };
}

// =============================================================
// SNAPSHOT CLASS (UNDO ENGINE)
// =============================================================

class _ScoreSnapshot {
  final int totalRuns;
  final int wickets;
  final int legalBalls;
  final int ballsThisOver;

  final int wides;
  final int noBalls;
  final int byes;
  final int legByes;

  final int batRuns;
  final int ballsFaced;
  final int fours;
  final int sixes;
  final int dotBalls;

  final int ballsBowled;
  final int runsConceded;
  final int wicketsTaken;
  final int maidens;
  final int runsThisOver;

  final List<String> ballHistory;

  _ScoreSnapshot({
    required this.totalRuns,
    required this.wickets,
    required this.legalBalls,
    required this.ballsThisOver,
    required this.wides,
    required this.noBalls,
    required this.byes,
    required this.legByes,
    required this.batRuns,
    required this.ballsFaced,
    required this.fours,
    required this.sixes,
    required this.dotBalls,
    required this.ballsBowled,
    required this.runsConceded,
    required this.wicketsTaken,
    required this.maidens,
    required this.runsThisOver,
    required this.ballHistory,
  });

  factory _ScoreSnapshot.from(ScoreCardLogic l) {
    return _ScoreSnapshot(
      totalRuns: l.totalRuns,
      wickets: l.wickets,
      legalBalls: l.legalBalls,
      ballsThisOver: l.ballsThisOver,
      wides: l.wides,
      noBalls: l.noBalls,
      byes: l.byes,
      legByes: l.legByes,
      batRuns: l.batRuns,
      ballsFaced: l.ballsFaced,
      fours: l.fours,
      sixes: l.sixes,
      dotBalls: l.dotBalls,
      ballsBowled: l.ballsBowled,
      runsConceded: l.runsConceded,
      wicketsTaken: l.wicketsTaken,
      maidens: l.maidens,
      runsThisOver: l.runsThisOver,
      ballHistory: List<String>.from(l.ballHistory),
    );
  }

  void restore(ScoreCardLogic l) {
    l.totalRuns = totalRuns;
    l.wickets = wickets;
    l.legalBalls = legalBalls;
    l.ballsThisOver = ballsThisOver;

    l.wides = wides;
    l.noBalls = noBalls;
    l.byes = byes;
    l.legByes = legByes;

    l.batRuns = batRuns;
    l.ballsFaced = ballsFaced;
    l.fours = fours;
    l.sixes = sixes;
    l.dotBalls = dotBalls;

    l.ballsBowled = ballsBowled;
    l.runsConceded = runsConceded;
    l.wicketsTaken = wicketsTaken;
    l.maidens = maidens;
    l.runsThisOver = runsThisOver;

    l.ballHistory
      ..clear()
      ..addAll(ballHistory);
  }

}
