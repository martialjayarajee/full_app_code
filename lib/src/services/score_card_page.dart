import 'package:flutter/material.dart';
import '../Providers/score_card_logic.dart';
import '../database/objectbox.dart';
import '../database/scorecard_db_service.dart';
import 'package:full_app_code/src/Screens/ScoreCard.dart';

class ScoreCardPage extends StatefulWidget {
  final ObjectBoxDB objectBoxDB;
  final ScoreCardLogic logic;

  const ScoreCardPage({
    super.key,
    required this.objectBoxDB,
    required this.logic,
  });

  @override
  State<ScoreCardPage> createState() => _ScoreCardPageState();
}

class _ScoreCardPageState extends State<ScoreCardPage> {
  late final ScoreCardDBService _dbService;

  @override
  void initState() {
    super.initState();

    _dbService = ScoreCardDBService(widget.objectBoxDB);

    // 🔗 Hook logic → database
    widget.logic.onPersist = _saveToDatabase;
    widget.logic.onUndoPersist = _undoFromDatabase;

    // ✅ New Bowler Logic Hook
    widget.logic.onOverCompleted = () {
      _showNewBowlerDialog();
    };
  }

  // ✅ New Bowler Selection Dialog
  void _showNewBowlerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Force user to click the button
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2126),
        title: const Text("Over Completed", style: TextStyle(color: Colors.white)),
        content: const Text(
          "The over has finished. Please prepare the next bowler.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                // Reset the live bowler map in logic for the UI table
                widget.logic.currentBowler = {
                  'name': 'Bumrah',
                  'overs': 0.0,
                  'runs': 0,
                  'wickets': 0,
                  'er': 0.0,
                  'maidens': 0,
                };
                // Reset bowler stats in logic
                widget.logic.ballsBowled = 0;
                widget.logic.runsConceded = 0;
                widget.logic.wicketsTaken = 0;
                widget.logic.maidens = 0;
              });
              Navigator.pop(context);
              debugPrint("New Bowler Set - UI Table Reset");
            },
            child: const Text(
              "Start New Over",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= DATABASE SAVE =================

  void _saveToDatabase() {
    // Save batsman 1
    _dbService.saveOrUpdateBatting(
      batID: 'BAT_001',
      inningsType: 'First',
      teamId: 'T001',
      playerId: 'P001',
      runs: widget.logic.batsman1['runs'] ?? 0,
      balls: widget.logic.batsman1['balls'] ?? 0,
      fours: widget.logic.batsman1['fours'] ?? 0,
      sixes: widget.logic.batsman1['sixes'] ?? 0,
      dotBalls: 0, // You can track this if needed
    );

    // Save batsman 2
    _dbService.saveOrUpdateBatting(
      batID: 'BAT_002',
      inningsType: 'First',
      teamId: 'T001',
      playerId: 'P002',
      runs: widget.logic.batsman2['runs'] ?? 0,
      balls: widget.logic.batsman2['balls'] ?? 0,
      fours: widget.logic.batsman2['fours'] ?? 0,
      sixes: widget.logic.batsman2['sixes'] ?? 0,
      dotBalls: 0,
    );

    // Save bowler
    _dbService.saveOrUpdateBowling(
      bowlID: 'BOWL_001',
      inningsType: 'First',
      teamId: 'T002',
      playerId: 'P010',
      overs: widget.logic.ballsBowled / 6.0,
      runsGiven: widget.logic.runsConceded,
      wickets: widget.logic.wicketsTaken,
      extras: widget.logic.wides + widget.logic.noBalls,
      maidens: widget.logic.maidens,
    );

    final allBatting = widget.objectBoxDB.battingBox.getAll();
    final allBowling = widget.objectBoxDB.bowlingBox.getAll();

    if (allBatting.isNotEmpty && allBowling.isNotEmpty) {
      final lastBat = allBatting.last;
      final lastBowl = allBowling.last;

      debugPrint('🏏 --- DB UPDATE SUCCESS ---');
      debugPrint('👤 Batting: ${lastBat.runs} runs (${lastBat.ballsPlayed} balls)');
      debugPrint('🎯 Bowling: ${lastBowl.wicketsConceded} wickets, ${lastBowl.extras} extras');
      debugPrint('-----------------------------');
    }
  }

  void _undoFromDatabase() {
    _dbService.undoLastBatting();
    _dbService.undoLastBowling();
  }

  @override
  Widget build(BuildContext context) {
    return ScoreCardUI(logic: widget.logic);
  }
}