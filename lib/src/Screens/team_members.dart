import 'package:full_app_code/src/Screens/team_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: const TeamMemberPage(),
    );
  }
}

class TeamMemberPage extends StatefulWidget {
  const TeamMemberPage({super.key});

  @override
  State<TeamMemberPage> createState() => _TeamMemberPageState();
}

class _TeamMemberPageState extends State<TeamMemberPage> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  int memberCount = 5;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (int i = 0; i < memberCount; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _addMember() {
    setState(() {
      memberCount++;
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    });
  }

  void _removeMember(int index) {
    if (memberCount > 1) {
      setState(() {
        _controllers[index].dispose();
        _focusNodes[index].dispose();
        _controllers.removeAt(index);
        _focusNodes.removeAt(index);
        memberCount--;
      });
    }
  }

  void _createTeam() {
    List<String> members = [];
    for (var controller in _controllers) {
      if (controller.text.trim().isNotEmpty) {
        members.add(controller.text.trim());
      }
    }

    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one member!'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Team created with ${members.length} members: ${members.join(", ")}'),
          backgroundColor: const Color(0xFF00C4FF),
          duration: const Duration(seconds: 3),
        ),
      );
    }

      Navigator.push(context, MaterialPageRoute(builder: (context)=>TeamPage()));
      // Add your navigation or logic here

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF140088), Colors.black],
            stops: [0.0, 0.2],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Cricket ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: 'Scorer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          SvgPicture.asset('assets/ix_support.svg', colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn), width: 25, height: 25),
                          const SizedBox(width: 12),
                          SvgPicture.asset('assets/Group.svg', colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn), width: 25, height: 25),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),

                  // Title
                  const Text(
                    'Add Team Member',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Member Input Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Member input fields
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: memberCount,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 30,
                                    child: Text(
                                      '${index + 1}.',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _controllers[index],
                                      focusNode: _focusNodes[index],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontFamily: 'Poppins',
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Enter member name',
                                        hintStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.3),
                                          fontSize: 18,
                                        ),
                                        enabledBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white, width: 1),
                                        ),
                                        focusedBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(color: Color(0xFF00C4FF), width: 2),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                      textCapitalization: TextCapitalization.words,
                                    ),
                                  ),
                                  if (memberCount > 1)
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.red, size: 20),
                                      onPressed: () => _removeMember(index),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Add Member Button
                        TextButton.icon(
                          onPressed: _addMember,
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00C4FF)),
                          label: const Text(
                            'Add More Members',
                            style: TextStyle(
                              color: Color(0xFF00C4FF),
                              fontSize: 16,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Create Team Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _createTeam,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C4FF),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),


                            child: const Text(
                              'Create Team',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
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
}