import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:full_app_code/src/services/score_card_page.dart';
import 'package:full_app_code/src/Providers/score_card_logic.dart';
import 'package:full_app_code/main.dart';

class SelectPlayersPage extends StatefulWidget {
  final BluetoothDevice? device;

  const SelectPlayersPage({Key? key, this.device}) : super(key: key);

  @override
  _SelectPlayersPageState createState() => _SelectPlayersPageState();
}

class _SelectPlayersPageState extends State<SelectPlayersPage> {
  String? selectedStriker;
  String? selectedNonStriker;
  String? selectedBowler;

  List<String> players = [
    'Kohli', 'Dhoni', 'Rohit', 'Rahul', 'Hardik'
  ];
  List<String> bowlers = ['Starc', 'Bumrah', 'Shami'];

  BluetoothCharacteristic? writeChar;
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    _discoverServices();
  }

  Future<void> _discoverServices() async {
    if (widget.device == null) return;

    try {
      // 1. Request MTU (The fix you already applied)
      if (Platform.isAndroid) {
        await widget.device!.requestMtu(247);
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // 2. Discover Services
      List<BluetoothService> services = await widget.device!.discoverServices();

      // 3. FIX: Iterate through ALL services. Do NOT 'return' immediately.
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {

            // We assign the characteristic, but we keep looping
            // to match Project 1's behavior (in case there are multiple).
            writeChar = characteristic;

            setState(() {
              isReady = true;
            });
            debugPrint("✅ Found Write Characteristic: ${characteristic.uuid}");
          }
        }
      }

      if (writeChar == null) {
        debugPrint("❌ No writable characteristic found!");
      }

    } catch (e) {
      debugPrint("❌ Error finding services: $e");
    }
  }

  Future<void> send(String cmd) async {
    if (writeChar == null) return;
    try {
      // Added a small delay to prevent flooding the device
      await Future.delayed(const Duration(milliseconds: 50));
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
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                            "Select Players",
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                        ),
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
                              if (selectedStriker == null || selectedNonStriker == null || selectedBowler == null) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select all players")));
                                return;
                              }

                              if (isReady) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Syncing Display...")));
                                try {
                                  // FIX: Send commands ONE BY ONE (Sequentially)
                                  // Future.wait sends them all at once, which crashes some BLE buffers.
                                  await send("TEXT 3 2 1 255 255 200 10:10");
                                  await send("TEXT 5 30 2 255 0 255 SCR:");
                                  await send("TEXT 50 30 2 255 255 255 0");
                                  await send("TEXT 10 60 1 0 255 0 ${selectedBowler?.toUpperCase()}:");
                                  await send("TEXT 8 74 1 200 255 255 ${selectedStriker?.toUpperCase()}:");
                                  await send("TEXT 8 84 1 200 255 255 ${selectedNonStriker?.toUpperCase()}:");
                                } catch (e) {
                                  debugPrint("Error sending BLE commands: $e");
                                }
                              }

                              final logic = ScoreCardLogic();
                              logic.batsman1 = {'name': selectedStriker!, 'runs': 0, 'balls': 0, 'fours': 0, 'sixes': 0, 'sr': 0.0};
                              logic.batsman2 = {'name': selectedNonStriker!, 'runs': 0, 'balls': 0, 'fours': 0, 'sixes': 0, 'sr': 0.0};
                              logic.currentBowler = {'name': selectedBowler!, 'overs': 0.0, 'runs': 0, 'wickets': 0, 'er': 0.0};
                              logic.strikerIndex = 0;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
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