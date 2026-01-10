import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TeamPage extends StatefulWidget {
  final String team1Name;
  final List<String> team1Members;
  final String team2Name;
  final List<String> team2Members;

  const TeamPage({
    super.key,
    required this.team1Name,
    required this.team1Members,
    required this.team2Name,
    required this.team2Members,
  });

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  String? selectedTossWinner;
  String? selectedDecision;
  final TextEditingController _oversController = TextEditingController();

  @override
  void dispose() {
    _oversController.dispose();
    super.dispose();
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
                          children: const [
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
                          SvgPicture.asset('assets/ix_support.svg',
                              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                              width: 25,
                              height: 25),
                          const SizedBox(width: 12),
                          SvgPicture.asset('assets/Group.svg',
                              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                              width: 25,
                              height: 25),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Teams Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Teams',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Team 1
                        _buildTeamContainer('Team 1', widget.team1Name),
                        const SizedBox(height: 16),
                        
                        // Team 2
                        _buildTeamContainer('Team 2', widget.team2Name),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Toss Details Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Toss Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Winner Dropdown
                        const Text(
                          'Winner',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3C3C3E),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF5C5C5E),
                              width: 1,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedTossWinner,
                              hint: const Text(
                                'Not Selected',
                                style: TextStyle(
                                  color: Color(0xFF8E8E93),
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              isExpanded: true,
                              dropdownColor: const Color(0xFF3C3C3E),
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                              items: [widget.team1Name, widget.team2Name].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedTossWinner = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Decision Dropdown
                        const Text(
                          'Decision',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3C3C3E),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF5C5C5E),
                              width: 1,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedDecision,
                              hint: const Text(
                                'Not Selected',
                                style: TextStyle(
                                  color: Color(0xFF8E8E93),
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              isExpanded: true,
                              dropdownColor: const Color(0xFF3C3C3E),
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                              items: ['Bat', 'Bowl'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedDecision = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Overs Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overs',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _oversController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter the overs',
                            hintStyle: const TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 16,
                              fontFamily: 'Poppins',
                            ),
                            filled: true,
                            fillColor: const Color(0xFF3C3C3E),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF5C5C5E),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF5C5C5E),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF00C4FF),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Start Match Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        int? overs = int.tryParse(_oversController.text);
                        if (overs == null || overs < 1 || overs > 20) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter valid overs (1-20)'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        
                        if (selectedTossWinner == null || selectedDecision == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please complete toss details'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Proceed to match
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Starting match...'),
                            backgroundColor: Color(0xFF00C4FF),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C4FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Start Match',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  Widget _buildTeamContainer(String label, String teamName) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF3C3C3E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF5C5C5E),
                width: 1,
              ),
            ),
            child: Text(
              teamName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      ],
    );
  }
}