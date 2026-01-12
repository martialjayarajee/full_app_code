import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// Ensure these imports match your actual project structure
import 'package:full_app_code/src/services/score_card_page.dart';
import 'package:full_app_code/src/Providers/score_card_logic.dart';
import 'package:full_app_code/main.dart';

class SelectPlayersPage extends StatefulWidget {
  // 1. This variable accepts the device passed from BluetoothPage
  final BluetoothDevice? device;

  // 2. The constructor makes it optional (removes 'required')
  // This ensures it works for BOTH BluetoothPage (device passed) and TeamPage (no device)
  SelectPlayersPage({Key? key, this.device}) : super(key: key);

  @override
  _SelectPlayersPageState createState() => _SelectPlayersPageState();
}

class _SelectPlayersPageState extends State<SelectPlayersPage> {
  String? selectedStriker;
  String? selectedNonStriker;
  String? selectedBowler;

  // Sample data - You can replace this with real data later
  List<String> players = [
    'Virat Kohli', 'MS Dhoni', 'Rohit Sharma', 'KL Rahul', 'Hardik Pandya'
  ];
  List<String> bowlers = ['Starc', 'Bumrah', 'Shami'];

  BluetoothCharacteristic? writeChar;
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    // Start searching for the writable service as soon as the page loads
    _discoverServices();
  }

  Future<void> _discoverServices() async {
    // If no device was passed (e.g. came from TeamPage), stop here.
    if (widget.device == null) return;

    try {
      // Discover services on the connected device
      List<BluetoothService> services = await widget.device!.discoverServices();

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          // Look for a characteristic we can write to
          if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
            setState(() {
              writeChar = characteristic;
              isReady = true;
            });
            debugPrint("✅ Connected to Write Characteristic");
            return;
          }
        }
      }
    } catch (e) {
      debugPrint("❌ Error finding services: $e");
    }
  }

  // Function to send commands to the BLE Device
  Future<void> send(String cmd) async {
    if (writeChar == null) return;
    try {
      await writeChar!.write(utf8.encode("$cmd\n"), withoutResponse: false);
      debugPrint("Sent: $cmd");
    } catch (e) {
      debugPrint("Write Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF283593), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - MediaQuery.of(context).padding.top,
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                            "Select Players",
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                        ),
                        // Visual Indicator: Green if BLE is ready, Grey if not
                        Row(
                          children: [
                            Text(isReady ? "Connected" : "Offline",
                                style: TextStyle(color: isReady ? Colors.green : Colors.grey, fontSize: 12)),
                            const SizedBox(width: 5),
                            Icon(Icons.bluetooth, color: isReady ? Colors.green : Colors.grey),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Form Container
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C2026),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Striker"),
                        _buildDropdown("Select Striker", selectedStriker, players, (val) => setState(() => selectedStriker = val)),

                        const SizedBox(height: 20),

                        _buildLabel("Non-Striker"),
                        _buildDropdown("Select Non-Striker", selectedNonStriker, players, (val) => setState(() => selectedNonStriker = val)),

                        const SizedBox(height: 20),

                        _buildLabel("Bowler"),
                        _buildDropdown("Select Bowler", selectedBowler, bowlers, (val) => setState(() => selectedBowler = val)),

                        const SizedBox(height: 40),

                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0E7292),
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            ),
                            onPressed: () async {
                              // 1. Validation
                              if (selectedStriker == null || selectedNonStriker == null || selectedBowler == null) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select all players")));
                                return;
                              }

                              // 2. BLE Commands (Only runs if Bluetooth is ready)
                              if (isReady) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Syncing Display...")));
                                try {
                                  // Send initialization commands
                                  await Future.wait([
                                    send("TEXT 3 2 1 255 255 200 10:10"),
                                    send("TEXT 5 30 2 255 0 255 SCR:"),
                                    send("TEXT 50 30 2 255 255 255 0"),
                                    send("TEXT 10 60 1 0 255 0 ${selectedBowler?.toUpperCase()}:"),
                                    send("TEXT 8 74 1 200 255 255 ${selectedStriker?.toUpperCase()}:"),
                                    send("TEXT 8 84 1 200 255 255 ${selectedNonStriker?.toUpperCase()}:"),
                                  ]);
                                } catch (e) {
                                  debugPrint("Error sending BLE commands: $e");
                                }
                              }

                              // 3. Prepare Logic Data
                              final logic = ScoreCardLogic();
                              logic.batsman1 = {'name': selectedStriker!, 'runs': 0, 'balls': 0, 'fours': 0, 'sixes': 0, 'sr': 0.0};
                              logic.batsman2 = {'name': selectedNonStriker!, 'runs': 0, 'balls': 0, 'fours': 0, 'sixes': 0, 'sr': 0.0};
                              logic.currentBowler = {'name': selectedBowler!, 'overs': 0.0, 'runs': 0, 'wickets': 0, 'er': 0.0};
                              logic.strikerIndex = 0;

                              // 4. Navigate to ScoreCard
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  // NOTE: If ScoreCardPage needs to update the display later,
                                  // you might need to pass 'widget.device' to it as well!
                                  builder: (context) => ScoreCardPage(objectBoxDB: objectBoxDB, logic: logic),
                                ),
                              );
                            },
                            child: const Text("Proceed", style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDropdown(String hint, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}