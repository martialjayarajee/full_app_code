import 'package:flutter/material.dart';
import 'package:full_app_code/src/Screens/ScoreCard.dart';
class SelectPlayersPage extends StatefulWidget {
  @override
  _SelectPlayersPageState createState() => _SelectPlayersPageState();
}

class _SelectPlayersPageState extends State<SelectPlayersPage> {
  String? selectedStriker;
  String? selectedNonStriker;
  String? selectedBowler;

  List<String> players = [
    'Player 1',
    'Player 2',
    'Player 3',
    'Player 4',
    'Player 5',
  ];

  List<String> bowlers = ['Bowler 1', 'Bowler 2', 'Bowler 3'];

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
                minHeight:
                    screenHeight -
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
                            const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
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
                                    // Proceed logic
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>Board()));

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Proceeding to match..."),
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
                                      // sized image won't cause overflow
                                      // Image.asset(
                                      //   'assets/images/mdi_cricket.svg',
                                      //   width: 20,
                                      //   height: 20,
                                      //   fit: BoxFit.contain,
                                      // ),
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
