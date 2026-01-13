import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:full_app_code/src/services/score_card_page.dart';
import 'package:full_app_code/src/Providers/score_card_logic.dart';
import 'package:full_app_code/main.dart';

class SelectPlayersPage extends StatefulWidget {
  final  BluetoothDevice device;

  const SelectPlayersPage({
    super.key,
    required this.device,
  });


  @override
  _SelectPlayersPageState createState() => _SelectPlayersPageState();


}

class _SelectPlayersPageState extends State<SelectPlayersPage> {
  String? selectedStriker;
  String? selectedNonStriker;
  String? selectedBowler;

  List<String> players = [
    'Virat Kohli',
    'MS Dhoni',
    'Rohit Sharma',
    'KL Rahul',
    'Hardik Pandya',
  ];

  List<String> bowlers = ['Starc', 'Bumrah', 'Shami'];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF283593), Color(0xFF1A237E), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
                  // Top header section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Cricket",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Scorer",
                                style: TextStyle(
                                  fontSize: 23,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.headphones,
                              color: Colors.white70,
                              size: 22,
                            ),
                            SizedBox(width: 12),
                            Icon(
                              Icons.settings,
                              color: Colors.white70,
                              size: 22,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 41),

                  // Card container
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C2026),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back arrow + title
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: const Text(
                                "Select Opening Players",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Striker
                              const Text(
                                "Striker",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 15),
                              _buildDropdown(
                                hint: "Select Striker",
                                value: selectedStriker,
                                items: players,
                                onChanged: (value) {
                                  setState(() => selectedStriker = value);
                                },
                              ),

                              const SizedBox(height: 20),

                              // Non-Striker
                              const Text(
                                "Non-Striker",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 15),
                              _buildDropdown(
                                hint: "Select Non-Striker",
                                value: selectedNonStriker,
                                items: players,
                                onChanged: (value) {
                                  setState(() => selectedNonStriker = value);
                                },
                              ),

                              const SizedBox(height: 20),

                              // Bowler
                              const Text(
                                "Bowler",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 15),
                              _buildDropdown(
                                hint: "Choose Bowler",
                                value: selectedBowler,
                                items: bowlers,
                                onChanged: (value) {
                                  setState(() => selectedBowler = value);
                                },
                              ),

                              const SizedBox(height: 57),

                              // Proceed Button
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0E7292),
                                    minimumSize: const Size(50, 50),
                                    maximumSize: const Size(150, 50),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed: () {
                                    // Validation
                                    if (selectedStriker == null ||
                                        selectedNonStriker == null ||
                                        selectedBowler == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Please select all players!"),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                      return;
                                    }

                                    if (selectedStriker == selectedNonStriker) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Striker and Non-Striker must be different!"),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                      return;
                                    }

                                    // Create new ScoreCardLogic instance with selected players
                                    final logic = ScoreCardLogic();

                                    // Initialize batsmen
                                    logic.batsman1 = {
                                      'name': selectedStriker!,
                                      'runs': 0,
                                      'balls': 0,
                                      'fours': 0,
                                      'sixes': 0,
                                      'sr': 0.0,
                                    };

                                    logic.batsman2 = {
                                      'name': selectedNonStriker!,
                                      'runs': 0,
                                      'balls': 0,
                                      'fours': 0,
                                      'sixes': 0,
                                      'sr': 0.0,
                                    };

                                    // Initialize bowler
                                    logic.currentBowler = {
                                      'name': selectedBowler!,
                                      'overs': 0.0,
                                      'runs': 0,
                                      'wickets': 0,
                                      'er': 0.0,
                                    };

                                    // Striker is batsman1
                                    logic.strikerIndex = 0;

                                    // Navigate to ScoreCard with initialized logic
                                    // Import main.dart to access objectBoxDB
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ScoreCardPage(
                                              objectBoxDB: objectBoxDB,
                                              logic: logic,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        fit: FlexFit.loose,
                                        child: const Text(
                                          "Proceed",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 50),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
      height: 44.23,
      decoration: BoxDecoration(
        color: Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(20),
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
          ),
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
            size: 20,
          ),
          isExpanded: true,
          isDense: true,
          items: items
              .map(
                (player) => DropdownMenuItem<String>(
              value: player,
              child: Text(
                player,
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),
          )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}