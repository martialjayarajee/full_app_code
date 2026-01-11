import 'package:full_app_code/src/database/objectbox.dart';
import 'package:full_app_code/src/database/batting_stats.dart';
import 'package:full_app_code/src/database/bowling_stats.dart';

class ScoreCardDBService {
  final ObjectBoxDB _db;

  ScoreCardDBService(this._db);

  // ===================== BATTING =====================

  void saveOrUpdateBatting({
    required String batID,
    required String inningsType,
    required String teamId,
    required String playerId,
    required int runs,
    required int balls,
    required int fours,
    required int sixes,
    required int dotBalls,
  }) {
    final batting = BattingStats(
      batID: batID,
      inningsType: inningsType,
      teamId: teamId,
      playerId: playerId,
      runs: runs,
      ballsPlayed: balls,
      fours: fours,
      sixes: sixes,
      dotBalls: dotBalls,
    );

    batting.updateStrikeRate();
    _db.battingBox.put(batting);
  }

  // ===================== BOWLING =====================

  void saveOrUpdateBowling({
    required String bowlID,
    required String inningsType,
    required String teamId,
    required String playerId,
    required double overs,
    required int runsGiven,
    required int wickets,
    required int extras,
    required int maidens,
  }) {
    final bowling = BowlingStats(
      bowlID: bowlID,
      inningsType: inningsType,
      teamId: teamId,
      playerId: playerId,
      oversBowled: overs,
      runsGiven: runsGiven,
      wicketsConceded: wickets,
      extras: extras,
      maidens: maidens,
    );

    bowling.updateEconomy();
    _db.bowlingBox.put(bowling);
  }

  // ===================== UNDO =====================

  void undoLastBatting() {
    final all = _db.battingBox.getAll();
    if (all.isNotEmpty) {
      _db.battingBox.remove(all.last.id);
    }
  }

  void undoLastBowling() {
    final all = _db.bowlingBox.getAll();
    if (all.isNotEmpty) {
      _db.bowlingBox.remove(all.last.id);
    }
  }
}
