import 'dart:collection';
import 'package:flutter/foundation.dart';

class ScoreCardLogic {
  void Function()? onPersist;
  void Function()? onUndoPersist;
  void Function()? onOverCompleted;

  int totalRuns = 0;
  int wickets = 0;
  int legalBalls = 0;
  int ballsThisOver = 0;
  int runsThisOver = 0;
  int maidens = 0;
  int wides = 0;
  int noBalls = 0;
  int strikerIndex = 0; // 0 for batsman1, 1 for batsman2

  final List<String> ballHistory = [];
  final ListQueue<_ScoreSnapshot> _undoStack = ListQueue();

  Map<String, dynamic> batsman1 = {'name': 'Virat Kohli', 'runs': 0, 'balls': 0, 'fours': 0, 'sixes': 0, 'dotBalls': 0, 'sr': 0.0};
  Map<String, dynamic> batsman2 = {'name': 'MS Dhoni', 'runs': 0, 'balls': 0, 'fours': 0, 'sixes': 0, 'dotBalls': 0, 'sr': 0.0};
  Map<String, dynamic> currentBowler = {'name': 'Starc', 'overs': 0.0, 'runs': 0, 'wickets': 0, 'er': 0.0, 'maidens': 0};

  String get overs => '${legalBalls ~/ 6}.${legalBalls % 6}';

  void _saveSnapshot() => _undoStack.addLast(_ScoreSnapshot.from(this));

  void _switchStrike() {
    strikerIndex = (strikerIndex == 0) ? 1 : 0;
    debugPrint("Strike Switched: Batsman ${strikerIndex + 1} is on strike");
  }

  void addRuns(int runs) {
    _saveSnapshot();
    totalRuns += runs;
    legalBalls++;
    ballsThisOver++;
    runsThisOver += runs;

    var striker = (strikerIndex == 0) ? batsman1 : batsman2;
    striker['runs'] += runs;
    striker['balls'] += 1;
    if (runs == 4) striker['fours'] += 1;
    if (runs == 6) striker['sixes'] += 1;
    if (runs == 0) striker['dotBalls'] += 1;
    striker['sr'] = (striker['runs'] / striker['balls']) * 100;

    currentBowler['runs'] += runs;
    currentBowler['overs'] = legalBalls ~/ 6 + (legalBalls % 6) / 10;
    double totalOvers = (legalBalls / 6);
    currentBowler['er'] = totalOvers == 0 ? 0.0 : (currentBowler['runs'] / totalOvers);

    if (runs % 2 != 0) _switchStrike();
    ballHistory.add(runs.toString());
    _checkOverCompletion();
    onPersist?.call();
  }

  void addWicket() {
    _saveSnapshot();
    wickets++;
    legalBalls++;
    ballsThisOver++;
    currentBowler['wickets'] += 1;
    currentBowler['overs'] = legalBalls ~/ 6 + (legalBalls % 6) / 10;
    ballHistory.add('W');
    _checkOverCompletion();
    onPersist?.call();
  }

  void addWide() {
    _saveSnapshot();
    totalRuns++;
    wides++;
    currentBowler['runs'] += 1;
    ballHistory.add('WD');
    onPersist?.call();
  }

  void addNoBall() {
    _saveSnapshot();
    totalRuns++;
    noBalls++;
    currentBowler['runs'] += 1;
    ballHistory.add('NB');
    onPersist?.call();
  }

  void _checkOverCompletion() {
    if (ballsThisOver == 6) {
      if (runsThisOver == 0) {
        maidens++;
        currentBowler['maidens'] += 1;
      }
      ballHistory.clear();
      ballsThisOver = 0;
      runsThisOver = 0;
      _switchStrike();
      onOverCompleted?.call();
    }
  }

  void undoLastAction() {
    if (_undoStack.isNotEmpty) {
      _undoStack.removeLast().restore(this);
      onUndoPersist?.call();
    }
  }

  void _validateMatch() { if (wickets >= 10) throw Exception('All wickets down'); }
}

class _ScoreSnapshot {
  final int totalRuns, wickets, legalBalls, ballsThisOver, strikerIndex, maidens, wides, noBalls;
  final List<String> ballHistory;
  final Map<String, dynamic> b1, b2, cb;

  _ScoreSnapshot.from(ScoreCardLogic l)
      : totalRuns = l.totalRuns, wickets = l.wickets, legalBalls = l.legalBalls,
        ballsThisOver = l.ballsThisOver, strikerIndex = l.strikerIndex, maidens = l.maidens,
        wides = l.wides, noBalls = l.noBalls, ballHistory = List.from(l.ballHistory),
        b1 = Map.from(l.batsman1), b2 = Map.from(l.batsman2), cb = Map.from(l.currentBowler);

  void restore(ScoreCardLogic l) {
    l.totalRuns = totalRuns; l.wickets = wickets; l.legalBalls = legalBalls;
    l.ballsThisOver = ballsThisOver; l.strikerIndex = strikerIndex; l.maidens = maidens;
    l.wides = wides; l.noBalls = noBalls; l.ballHistory..clear()..addAll(ballHistory);
    l.batsman1 = Map.from(b1); l.batsman2 = Map.from(b2); l.currentBowler = Map.from(cb);
  }
}