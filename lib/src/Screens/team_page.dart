import 'package:full_app_code/src/Screens/advanced.settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:full_app_code/src/Screens/playerselection_page.dart';
import 'package:full_app_code/src/Screens/Team_Name.dart';

void main() => runApp(const FigmaToCodeApp());

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A237E),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      home: const TeamPage(),
    );
  }
}

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  String? selectedTeam1;
  String? selectedTeam2;
  String? selectedTossWinner;
  String? selectedTossDecision;
  final TextEditingController oversController = TextEditingController();
  bool additionalSettings = false;

  List<String> teams = ['Mumbai Indians', 'Chennai Super Kings', 'Royal Challengers', 'Delhi Capitals'];
  final List<String> tossDecisions = ['Bat', 'Bowl'];

  void _addNewTeam(String teamName) {
    if (teamName.isNotEmpty && !teams.contains(teamName)) {
      setState(() {
        teams.add(teamName);
      });
    }
  }

  @override
  void dispose() {
    oversController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF283593), Color(0xFF1A237E), Color(0xFF000000)],
            stops: [0.0, 0.0, 0.2],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: h),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.all(w * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(w),
                          SizedBox(height: h * 0.035),
                          _buildAddTeamsButton(w),
                          SizedBox(height: h * 0.035),
                          _buildTeamsSection(w),
                          SizedBox(height: h * 0.025),
                          _buildTossDetailsSection(w),
                          SizedBox(height: h * 0.025),
                          _buildOversSection(w),
                          SizedBox(height: h * 0.04),
                          _buildBottomRow(w),
                          SizedBox(height: h * 0.025),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double w) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Cricket ', style: _textStyle(w * 0.1)),
              TextSpan(text: 'Scorer', style: _textStyle(w * 0.05)),
            ],
          ),
        ),
        Row(
          children: [
            _buildSvgIcon('assets/ix_support.svg', w * 0.065),
            SizedBox(width: w * 0.025),
            Opacity(
              opacity: 0.90,
              child: _buildSvgIcon('assets/Group.svg', w * 0.065),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddTeamsButton(double w) {
    return GestureDetector(
      //onTap: () => _showAddTeamDialog(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: w * 0.04),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2026),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>TeamNameScreen()));
                print("Add Teams button pressed!");
              },
              child: Text('Add Teams', style: _textStyle(w * 0.04)),
            ),

            SizedBox(width: w * 0.025),
            _buildSvgIcon('assets/images/mdi_plus-circle-outline.svg', w * 0.065),
          ],
        ),
      ),
    );
  }

  void _showAddTeamDialog() {
    final TextEditingController teamController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2026),
        title: const Text('Add New Team'),
        content: TextField(
          controller: teamController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter team name',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            filled: true,
            fillColor: const Color(0xFF2C2C2E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF00C4FF), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (teamController.text.trim().isNotEmpty) {
                _addNewTeam(teamController.text.trim());
                Navigator.push(context, MaterialPageRoute(builder: (context)=>TeamNameScreen()));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Team "${teamController.text.trim()}" added!'),
                    backgroundColor: const Color(0xFF00C4FF),
                  ),
                );
              }
            },
            child: const Text('Add', style: TextStyle(color: Color(0xFF00C4FF))),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsSection(double w) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Teams', style: _textStyle(w * 0.04)),
          SizedBox(height: w * 0.04),
          _buildDropdownField('Team 1', selectedTeam1, (value) {
            setState(() => selectedTeam1 = value);
          }, w),
          SizedBox(height: w * 0.04),
          _buildDropdownField('Team 2', selectedTeam2, (value) {
            setState(() => selectedTeam2 = value);
          }, w),
        ],
      ),
    );
  }

  Widget _buildTossDetailsSection(double w) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Toss Details', style: _textStyle(w * 0.04)),
          SizedBox(height: w * 0.04),
          _buildLabeledDropdown('Add', 'Choose team', selectedTossWinner, (value) {
            setState(() => selectedTossWinner = value);
          }, w),
          SizedBox(height: w * 0.04),
          _buildLabeledDropdown('Choose to', 'Choose team', selectedTossDecision, (value) {
            setState(() => selectedTossDecision = value);
          }, w, isTossDecision: true),
        ],
      ),
    );
  }

  Widget _buildOversSection(double w) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(10),
      ),
      child: _buildLabeledTextField('Overs', 'Enter the overs', w),
    );
  }

  Widget _buildBottomRow(double w) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            setState(() => additionalSettings = !additionalSettings);

              Navigator.push(context, MaterialPageRoute(builder: (context)=>MatchSettingsPage()));
              // Add your navigation or logic here

          },
          child: Row(
            children: [
              Text('Additional\nSettings', style: _textStyle(w * 0.04)),
              SizedBox(width: w * 0.025),
              Switch(
                value: additionalSettings,
                onChanged: (value) {
                  setState(() => additionalSettings = value);
                },
                activeColor: const Color(0xFF00C4FF),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            if (selectedTeam1 == null || selectedTeam2 == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select both teams!'),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (oversController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter overs!'),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Match started: $selectedTeam1 vs $selectedTeam2'),
                  backgroundColor: const Color(0xFF00C4FF),
                ),
              );
            }
            Navigator.push(context, MaterialPageRoute(builder: (context)=>SelectPlayersPage()));

          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: w * 0.03),
            decoration: BoxDecoration(
              color: const Color(0xFF00C4FF),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Start Match', style: _textStyle(w * 0.04)),
                SizedBox(width: w * 0.02),
                _buildSvgIcon('assets/mdi_cricket.svg', w * 0.062),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String? value, Function(String?) onChanged, double w) {
    return GestureDetector(
      onTap: () => _showTeamPicker(label, value, onChanged),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.03),
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          border: Border.all(color: const Color(0xFFD1D1D1)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value ?? label,
              style: _textStyle(w * 0.034, null, value == null ? const Color(0xFF9E9E9E) : Colors.black),
            ),
            _buildSvgIcon(
              'assets/material-symbols_arrow-drop-down-circle-outline.svg',
              w * 0.062,
              colored: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledDropdown(String label, String placeholder, String? value, Function(String?) onChanged, double w, {bool isTossDecision = false}) {
    return Row(
      children: [
        SizedBox(
          width: w * 0.26,
          child: Text(label, style: _textStyle(w * 0.034)),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (isTossDecision) {
                _showTossDecisionPicker(value, onChanged);
              } else {
                _showTeamPicker(label, value, onChanged);
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.025),
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                border: Border.all(color: const Color(0xFFD1D1D1)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value ?? placeholder,
                    style: _textStyle(w * 0.034, null, value == null ? const Color(0xFF9E9E9E) : Colors.black),
                  ),
                  _buildSvgIcon(
                    'assets/material-symbols_arrow-drop-down-circle-outline.svg',
                    w * 0.052,
                    colored: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledTextField(String label, String placeholder, double w) {
    return Row(
      children: [
        SizedBox(
          width: w * 0.26,
          child: Text(label, style: _textStyle(w * 0.034)),
        ),
        Expanded(
          child: TextField(
            controller: oversController,
            keyboardType: TextInputType.number,
            style: _textStyle(w * 0.034, null, Colors.black),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: _textStyle(w * 0.034, null, const Color(0xFF9E9E9E)),
              filled: true,
              fillColor: const Color(0xFFD9D9D9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD1D1D1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD1D1D1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF00C4FF), width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.025),
            ),
          ),
        ),
      ],
    );
  }

  void _showTeamPicker(String label, String? currentValue, Function(String?) onChanged) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select $label',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Color(0xFF00C4FF)),
                  onPressed: () {
                    Navigator.pop(context);
                    _showAddTeamDialog();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...teams.map((team) => ListTile(
              title: Text(team),
              trailing: currentValue == team ? const Icon(Icons.check, color: Colors.white) : null,
              onTap: () {
                onChanged(team);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showTossDecisionPicker(String? currentValue, Function(String?) onChanged) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Decision',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...tossDecisions.map((decision) => ListTile(
              title: Text(decision),
              trailing: currentValue == decision ? const Icon(Icons.check, color: Color(0xFF00C4FF)) : null,
              onTap: () {
                onChanged(decision);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSvgIcon(String path, double size, {bool colored = true}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: colored
          ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
          : null,
    );
  }

  TextStyle _textStyle(double size, [FontWeight? weight, Color? color]) {
    return TextStyle(
      color: color ?? Colors.white,
      fontSize: size,
      fontFamily: 'Poppins',
      fontWeight: weight ?? FontWeight.w400,
    );
  }
}