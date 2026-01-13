// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// // Ensure this path matches your project structure
// import '../Pages/Teams/playerselection_page.dart';
//
// class BluetoothPage extends StatefulWidget {
//   const BluetoothPage({Key? key}) : super(key: key);
//
//   @override
//   State<BluetoothPage> createState() => _BluetoothPageState();
// }
//
// class _BluetoothPageState extends State<BluetoothPage>
//     with SingleTickerProviderStateMixin {
//
//   BluetoothDevice? _connectedGameDevice;
//   BluetoothDevice? device;
//   BluetoothCharacteristic? writeChar;
//
//   // Animation for the scanning icon
//   late AnimationController _animationController;
//   late Animation<double> _animation;
//
//   // Lists to store devices
//   List<BluetoothDevice> _systemDevices = []; // Paired/Bonded devices
//   List<ScanResult> _scanResults = []; // Scanned BLE devices
//   bool _isScanning = false;
//
//   // Subscriptions
//   StreamSubscription<List<ScanResult>>? _scanResultsSubscription;
//   StreamSubscription<bool>? _isScanningSubscription;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Setup Animation
//     _animationController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     );
//     _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
//
//     // Initialize Bluetooth
//     _initBluetooth();
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     _scanResultsSubscription?.cancel();
//     _isScanningSubscription?.cancel();
//     super.dispose();
//   }
//
//
//   Future<void> connect(BluetoothDevice d) async {
//     await FlutterBluePlus.stopScan();
//     try {
//       await d.connect(autoConnect: false);
//     } catch (e) {
//       debugPrint("Already connected or error: $e");
//     }
//     device = d;
//     await device!.requestMtu(247);
//     await Future.delayed(const Duration(milliseconds: 300));
//     await discover();
//     setState(() {});
//   }
//
//
//   Future<void> discover() async {
//     if (device == null) return;
//     final services = await device!.discoverServices();
//     for (var s in services) {
//       debugPrint(" Service UUID: ${s.uuid}");
//       debugPrint("  Primary: ${s.isPrimary}");
//       for (var c in s.characteristics) {
//         debugPrint("Characteristic UUID: ${c.uuid}");
//         debugPrint("Properties: ${c.properties}");
//         if (c.properties.read) {
//           try {
//             final value = await c.read();
//             debugPrint("Value (raw bytes): $value");
//             debugPrint("Value (as string): ${String.fromCharCodes(value)}");
//           } catch (e) {
//             debugPrint("Read failed: $e");
//           }
//         }
//         if (c.properties.write || c.properties.writeWithoutResponse) {
//           writeChar = c;
//           debugPrint("WRITE CHAR FOUND: ${c.uuid}");
//         }
//       }
//     }
//     if (writeChar == null) {
//       debugPrint("NO WRITE CHARACTERISTIC FOUND");
//     }
//   }
//
//   Future<void> _initBluetooth() async {
//     // 1. Check Permissions
//     await _requestPermissions();
//
//     // 2. Listen to Scan State (to update UI loading/animation)
//     _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
//       if (mounted) {
//         setState(() {
//           _isScanning = state;
//         });
//         if (state) {
//           _animationController.repeat();
//         } else {
//           _animationController.stop();
//           _animationController.reset();
//         }
//       }
//     });
//
//     // 3. Listen to Scan Results
//     _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
//       if (mounted) {
//         setState(() {
//           _scanResults = results;
//
//         });
//       }
//     }, onError: (e) {
//       _showSnackBar('Scan Error: $e', Colors.red);
//     });
//
//     // 4. Get initially bonded (paired) devices
//     try {
//       final bonded = await FlutterBluePlus.bondedDevices;
//       if (mounted) {
//         setState(() {
//           _systemDevices = bonded;
//
//         });
//       }
//     } catch (e) {
//       debugPrint("Error getting bonded devices: $e");
//     }
//   }
//
//   Future<void> _requestPermissions() async {
//     if (Platform.isAndroid) {
//       await [
//         Permission.location,
//         Permission.bluetoothScan,
//         Permission.bluetoothConnect,
//       ].request();
//     }
//   }
//
//   // Start Scanning for BLE Devices
//   Future<void> startSearching() async {
//     try {
//       // Check if Bluetooth is On
//       if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
//         _showSnackBar('Please turn on Bluetooth', Colors.red);
//         if (Platform.isAndroid) {
//           await FlutterBluePlus.turnOn();
//         }
//         return;
//       }
//
//       // Refresh bonded devices
//       final bonded = await FlutterBluePlus.bondedDevices;
//       setState(() {
//         _systemDevices = bonded;
//         _scanResults.clear();
//       });
//
//       // Start Scan (15 seconds)
//       await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
//
//     } catch (e) {
//       _showSnackBar('Error starting scan: $e', Colors.red);
//     }
//   }
//
//   Future<void> _connectToDevice(BluetoothDevice device) async {
//     try {
//       // Connect with autoConnect to false for faster non-bonded connection
//       await device.connect(autoConnect: false);
//
//       _showSnackBar('Connected to ${device.platformName}', Colors.green);
//       setState(() {
//         _connectedGameDevice = device;
//       });
//
//       // Refresh bonded list in case we bonded during connection
//       final bonded = await FlutterBluePlus.bondedDevices;
//       setState(() {
//         _systemDevices = bonded;
//       });
//     } catch (e) {
//       _showSnackBar('Connection failed: ${e.toString().split(']').last}', Colors.red);
//     }
//   }
//
//   Future<void> _disconnectDevice(BluetoothDevice device) async {
//     try {
//       await device.disconnect();
//       _showSnackBar('Disconnected', Colors.orange);
//       // If we disconnected the currently selected game device, clear the variable
//       if (_connectedGameDevice == device) {
//         setState(() {
//           _connectedGameDevice = null;
//         });
//       }
//     } catch (e) {
//       _showSnackBar('Error disconnecting', Colors.red);
//     }
//   }
//
//   void _showSnackBar(String message, Color backgroundColor) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message, style: const TextStyle(color: Colors.white)),
//           backgroundColor: backgroundColor,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }
//
//   IconData _getDeviceIcon(String deviceName) {
//     final name = deviceName.toLowerCase();
//     if (name.contains('laptop') || name.contains('pc')) return Icons.laptop;
//     if (name.contains('phone')) return Icons.phone_iphone;
//     if (name.contains('watch')) return Icons.watch;
//     if (name.contains('headphone') || name.contains('buds')) return Icons.headphones;
//     if (name.contains('ble')) return Icons.bluetooth_connected;
//     return Icons.bluetooth;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//       // -----------------------------------------------------------
//       // UPDATED FLOATING ACTION BUTTON (With Safety Check)
//       // -----------------------------------------------------------
//       floatingActionButton: FloatingActionButton.extended(
//         // Grey if not connected, Blue if connected
//         backgroundColor: _connectedGameDevice != null ? const Color(0xFF00BCD4) : Colors.grey,
//         onPressed: () {
//           // SAFETY CHECK: Ensure device is not null before navigating
//           if (_connectedGameDevice != null) {
//
//             final device = _connectedGameDevice;
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => SelectPlayersPage(
//                   device: device!,
//                 ),
//               ),
//             );
//           } else {
//             // Show error if user clicks button without connecting
//             _showSnackBar("Please connect to a device first", Colors.red);
//           }
//         },
//         label: const Text("Setup Match"),
//         icon: const Icon(Icons.sports_cricket),
//       ),
//       // -----------------------------------------------------------
//
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Color(0xFF1A0A5C), Color(0xFF000000)],
//             stops: [0.0, 0.5],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Header
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         const Text(
//                           'Cricket',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         const Padding(
//                           padding: EdgeInsets.only(bottom: 4),
//                           child: Text(
//                             'Scorer (BLE)',
//                             style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.headphones, color: Colors.white, size: 24),
//                           onPressed: () {},
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.settings, color: Colors.white, size: 24),
//                           onPressed: () {},
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Bluetooth Icon
//               Container(
//                 margin: const EdgeInsets.symmetric(vertical: 20),
//                 child: _isScanning
//                     ? RotationTransition(
//                   turns: _animation,
//                   child: const Icon(Icons.bluetooth_searching, color: Color(0xFF40C4FF), size: 50),
//                 )
//                     : const Icon(Icons.bluetooth, color: Color(0xFF40C4FF), size: 50),
//               ),
//
//               // Device Lists
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       // My Device Container (Bonded Devices)
//                       Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF2A2A4A),
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text(
//                                   'My Devices ',
//                                   style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
//                                 ),
//                                 TextButton.icon(
//                                   onPressed: _isScanning ? () => FlutterBluePlus.stopScan() : startSearching,
//                                   icon: Icon(
//                                     _isScanning ? Icons.stop : Icons.search,
//                                     color: _isScanning ? Colors.redAccent : const Color(0xFF00BCD4),
//                                     size: 18,
//                                   ),
//                                   label: Text(
//                                     _isScanning ? 'Stop' : 'Find New',
//                                     style: TextStyle(
//                                       color: _isScanning ? Colors.redAccent : const Color(0xFF00BCD4),
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 16),
//                             if (_systemDevices.isNotEmpty)
//                               ..._systemDevices.map((d) => _buildDeviceTile(d, isBonded: true),
//                               )
//                             else
//                               const Center(
//                                 child: Padding(
//                                   padding: EdgeInsets.symmetric(vertical: 20),
//                                   child: Text(
//                                     'No bonded devices found',
//                                     style: TextStyle(color: Colors.white54, fontSize: 14),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//
//                       const SizedBox(height: 16),
//
//                       // Scanned Devices Container
//                       if (_scanResults.isNotEmpty)
//                         Container(
//                           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                           padding: const EdgeInsets.all(20),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF2A2A4A),
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 'Available Devices',
//                                 style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
//                               ),
//                               const SizedBox(height: 8),
//                               const Text(
//                                 'Tap connect to pair/connect',
//                                 style: TextStyle(color: Colors.white54, fontSize: 12),
//                               ),
//                               const SizedBox(height: 16),
//                               // Filter out devices with empty names
//                                 ..._scanResults
//                                     .where((r) => r.device.platformName.isNotEmpty)
//                                     .map((r) => _buildDeviceTile(r.device, rssi: r.rssi)),
//                             ],
//                           ),
//                         ),
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // A unified tile widget for both bonded and scanned devices
//   Widget _buildDeviceTile(BluetoothDevice device, {bool isBonded = false, int? rssi}) {
//     // We use a StreamBuilder to listen to the specific device's connection state
//     return StreamBuilder<BluetoothConnectionState>(
//       stream: device.connectionState,
//       initialData: BluetoothConnectionState.disconnected,
//       builder: (context, snapshot) {
//         final state = snapshot.data ?? BluetoothConnectionState.disconnected;
//         final isConnected = state == BluetoothConnectionState.connected;
//         final isConnecting = state == BluetoothConnectionState.connecting;
//
//         final deviceName = device.platformName.isNotEmpty ? device.platformName : "Unknown Device";
//         final deviceId = device.remoteId.str;
//
//         return Container(
//           margin: const EdgeInsets.only(bottom: 12),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: isConnected ? const Color(0xFF1E3A5F) : const Color(0xFF1F1F3F),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: isConnected ? const Color(0xFF4CAF50) : Colors.transparent,
//               width: 1.5,
//             ),
//           ),
//           child: Row(
//             children: [
//               // Icon Box
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: isConnected ? const Color(0xFF4CAF50) : const Color(0xFF4C4CFF),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: isConnecting
//                     ? const Padding(
//                   padding: EdgeInsets.all(10),
//                   child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
//                 )
//                     : Icon(_getDeviceIcon(deviceName), color: Colors.white, size: 24),
//               ),
//               const SizedBox(width: 12),
//
//               // Device Info
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       deviceName,
//                       style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
//                     ),
//                     const SizedBox(height: 2),
//                     Row(
//                       children: [
//                         if (isConnected) ...[
//                           Container(
//                             width: 6,
//                             height: 6,
//                             decoration: const BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Color(0xFF4CAF50),
//                             ),
//                           ),
//                           const SizedBox(width: 6),
//                         ],
//                         Text(
//                           isConnecting
//                               ? 'Connecting...'
//                               : (isConnected ? 'Connected' : (rssi != null ? '$rssi dBm' : deviceId)),
//                           style: TextStyle(
//                             color: isConnecting
//                                 ? const Color(0xFF00BCD4)
//                                 : (isConnected ? const Color(0xFF4CAF50) : Colors.white54),
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Action Buttons
//               if (isConnected)
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.red.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: IconButton(
//                     icon: const Icon(Icons.link_off, color: Colors.redAccent, size: 20),
//                     onPressed: () => _disconnectDevice(device),
//                     tooltip: 'Disconnect',
//                     padding: const EdgeInsets.all(8),
//                     constraints: const BoxConstraints(),
//                   ),
//                 )
//               else if (!isConnecting)
//                 Container(
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF00BCD4).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: IconButton(
//                     icon: const Icon(Icons.link, color: Color(0xFF00BCD4), size: 20),
//                     onPressed: () => _connectToDevice(device),
//                     tooltip: 'Connect',
//                     padding: const EdgeInsets.all(8),
//                     constraints: const BoxConstraints(),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// Ensure this path matches your project structure
import '../Pages/Teams/playerselection_page.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({Key? key}) : super(key: key);

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage>
    with SingleTickerProviderStateMixin {

  // The currently active device for the game
  BluetoothDevice? _connectedGameDevice;

  // Helper variables for logic
  BluetoothDevice? device;
  BluetoothCharacteristic? writeChar;

  // Animation for the scanning icon
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Lists to store devices
  List<BluetoothDevice> _systemDevices = []; // Paired/Bonded devices
  List<ScanResult> _scanResults = []; // Scanned BLE devices
  bool _isScanning = false;

  // Subscriptions
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;
  StreamSubscription<bool>? _isScanningSubscription;

  @override
  void initState() {
    super.initState();

    // Setup Animation
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    // Initialize Bluetooth
    _initBluetooth();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scanResultsSubscription?.cancel();
    _isScanningSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initBluetooth() async {
    // 1. Check Permissions
    await _requestPermissions();

    // 2. Listen to Scan State (to update UI loading/animation)
    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      if (mounted) {
        setState(() {
          _isScanning = state;
        });
        if (state) {
          _animationController.repeat();
        } else {
          _animationController.stop();
          _animationController.reset();
        }
      }
    });

    // 3. Listen to Scan Results
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          _scanResults = results;
        });
      }
    }, onError: (e) {
      _showSnackBar('Scan Error: $e', Colors.red);
    });

    // 4. Get initially bonded (paired) devices
    try {
      final bonded = await FlutterBluePlus.bondedDevices;
      if (mounted) {
        setState(() {
          _systemDevices = bonded;
        });
      }
    } catch (e) {
      debugPrint("Error getting bonded devices: $e");
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await [
        Permission.location,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();
    }
  }

  // Start Scanning for BLE Devices
  Future<void> startSearching() async {
    try {
      // Check if Bluetooth is On
      if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
        _showSnackBar('Please turn on Bluetooth', Colors.red);
        if (Platform.isAndroid) {
          await FlutterBluePlus.turnOn();
        }
        return;
      }

      // Refresh bonded devices
      final bonded = await FlutterBluePlus.bondedDevices;
      setState(() {
        _systemDevices = bonded;
        _scanResults.clear();
      });

      // Start Scan (15 seconds)
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

    } catch (e) {
      _showSnackBar('Error starting scan: $e', Colors.red);
    }
  }

  // --- CONNECT LOGIC (Fixed & Merged) ---

  Future<void> _connectToDevice(BluetoothDevice selectedDevice) async {
    // 1. Stop scanning ensures stable connection
    await FlutterBluePlus.stopScan();

    try {
      // 2. Connect
      // autoConnect: false is faster for UI interactions
      await selectedDevice.connect(autoConnect: false);

      _showSnackBar('Connected to ${selectedDevice.platformName}', Colors.green);

      setState(() {
        _connectedGameDevice = selectedDevice; // For UI
        this.device = selectedDevice;          // For Logic (discover method)
      });

      // 3. Service Discovery & MTU
      // Wait a tiny bit for connection stability
      await Future.delayed(const Duration(milliseconds: 300));

      if (Platform.isAndroid) {
        try {
          await selectedDevice.requestMtu(247);
        } catch(e) {
          debugPrint("MTU Request failed (might be iOS or already high): $e");
        }
      }

      // Find the Write Characteristic
      await discover();

      // 4. Refresh bonded list
      final bonded = await FlutterBluePlus.bondedDevices;
      if(mounted) {
        setState(() {
          _systemDevices = bonded;
        });
      }

    } catch (e) {
      _showSnackBar('Connection failed: ${e.toString().split(']').last}', Colors.red);
    }
  }

  Future<void> discover() async {
    if (device == null) return;

    debugPrint("Discovering Services...");
    final services = await device!.discoverServices();

    for (var s in services) {
      debugPrint(" Service UUID: ${s.uuid}");
      for (var c in s.characteristics) {
        // Check for Read
        if (c.properties.read) {
          try {
            // Optional: Read initial value
            // final value = await c.read();
          } catch (e) {
            debugPrint("Read failed: $e");
          }
        }

        // Check for Write
        if (c.properties.write || c.properties.writeWithoutResponse) {
          writeChar = c;
          debugPrint(">>> WRITE CHAR FOUND: ${c.uuid}");
        }
      }
    }

    if (writeChar == null) {
      debugPrint("!!! NO WRITE CHARACTERISTIC FOUND !!!");
      _showSnackBar("Warning: No writable characteristic found", Colors.orange);
    }
  }

  Future<void> _disconnectDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
      _showSnackBar('Disconnected', Colors.orange);
      // If we disconnected the currently selected game device, clear the variable
      if (_connectedGameDevice == device) {
        setState(() {
          _connectedGameDevice = null;
          this.device = null;
          this.writeChar = null;
        });
      }
    } catch (e) {
      _showSnackBar('Error disconnecting', Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  IconData _getDeviceIcon(String deviceName) {
    final name = deviceName.toLowerCase();
    if (name.contains('laptop') || name.contains('pc')) return Icons.laptop;
    if (name.contains('phone')) return Icons.phone_iphone;
    if (name.contains('watch')) return Icons.watch;
    if (name.contains('headphone') || name.contains('buds')) return Icons.headphones;
    if (name.contains('ble')) return Icons.bluetooth_connected;
    return Icons.bluetooth;
  }


  Future<void> send(String cmd) async {
    if (writeChar == null) {
      debugPrint("Cannot send, writeChar is null");
      return;
    }
    // if (_writing) return;
    // _writing = true;
    try {
      debugPrint(" Sending: $cmd");
      await writeChar!.write(
        utf8.encode("$cmd\n"),
        withoutResponse: false,
      );
      // await Future.delayed(const Duration(milliseconds: 150));
    } catch (e) {
      debugPrint("BLE WRITE ERROR: $e");
    }
    // _writing = false;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // FAB to start game
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _connectedGameDevice != null ? const Color(0xFF00BCD4) : Colors.grey,
        onPressed: () {
          if (_connectedGameDevice != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SelectPlayersPage(
                  device: _connectedGameDevice!,
                ),
              ),
            );
          } else {
            _showSnackBar("Please connect to a device first", Colors.red);
          }
        },
        label: const Text("Setup Match"),
        icon: const Icon(Icons.sports_cricket),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0A5C), Color(0xFF000000)],
            stops: [0.0, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Cricket',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Scorer (BLE)',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.headphones, color: Colors.white, size: 24),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white, size: 24),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bluetooth Scanning Animation/Icon
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: _isScanning
                    ? RotationTransition(
                  turns: _animation,
                  child: const Icon(Icons.bluetooth_searching, color: Color(0xFF40C4FF), size: 50),
                )
                    : const Icon(Icons.bluetooth, color: Color(0xFF40C4FF), size: 50),
              ),

              // Device Lists
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // My Device Container (Bonded Devices)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A4A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'My Devices ',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                TextButton.icon(
                                  onPressed: _isScanning ? () => FlutterBluePlus.stopScan() : startSearching,
                                  icon: Icon(
                                    _isScanning ? Icons.stop : Icons.search,
                                    color: _isScanning ? Colors.redAccent : const Color(0xFF00BCD4),
                                    size: 18,
                                  ),
                                  label: Text(
                                    _isScanning ? 'Stop' : 'Find New',
                                    style: TextStyle(
                                      color: _isScanning ? Colors.redAccent : const Color(0xFF00BCD4),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_systemDevices.isNotEmpty)
                              ..._systemDevices.map((d) => _buildDeviceTile(d, isBonded: true))
                            else
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Text(
                                    'No bonded devices found',
                                    style: TextStyle(color: Colors.white54, fontSize: 14),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Scanned Devices Container
                      if (_scanResults.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A4A),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Available Devices',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Tap connect to pair/connect',
                                style: TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                              const SizedBox(height: 16),
                              // Filter out devices with empty names
                              ..._scanResults
                                  .where((r) => r.device.platformName.isNotEmpty)
                                  .map((r) => _buildDeviceTile(r.device, rssi: r.rssi)),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // A unified tile widget for both bonded and scanned devices
  Widget _buildDeviceTile(BluetoothDevice device, {bool isBonded = false, int? rssi}) {
    // We use a StreamBuilder to listen to the specific device's connection state
    return StreamBuilder<BluetoothConnectionState>(
      stream: device.connectionState,
      initialData: BluetoothConnectionState.disconnected,
      builder: (context, snapshot) {
        final state = snapshot.data ?? BluetoothConnectionState.disconnected;
        final isConnected = state == BluetoothConnectionState.connected;
        final isConnecting = state == BluetoothConnectionState.connecting;

        final deviceName = device.platformName.isNotEmpty ? device.platformName : "Unknown Device";
        final deviceId = device.remoteId.str;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isConnected ? const Color(0xFF1E3A5F) : const Color(0xFF1F1F3F),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isConnected ? const Color(0xFF4CAF50) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Icon Box
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isConnected ? const Color(0xFF4CAF50) : const Color(0xFF4C4CFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isConnecting
                    ? const Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : Icon(_getDeviceIcon(deviceName), color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),

              // Device Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deviceName,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (isConnected) ...[
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          isConnecting
                              ? 'Connecting...'
                              : (isConnected ? 'Connected' : (rssi != null ? '$rssi dBm' : deviceId)),
                          style: TextStyle(
                            color: isConnecting
                                ? const Color(0xFF00BCD4)
                                : (isConnected ? const Color(0xFF4CAF50) : Colors.white54),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              if (isConnected)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.link_off, color: Colors.redAccent, size: 20),
                    onPressed: () => _disconnectDevice(device),
                    tooltip: 'Disconnect',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                )
              else if (!isConnecting)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BCD4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.link, color: Color(0xFF00BCD4), size: 20),
                    onPressed: () => _connectToDevice(device),
                    tooltip: 'Connect',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}