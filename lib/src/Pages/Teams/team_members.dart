import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'team_storage.dart';

class TeamMembersScreen extends StatefulWidget {
  final String teamName;

  const TeamMembersScreen({super.key, required this.teamName});

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen> {
  List<String> players = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    setState(() => isLoading = true);
    final team = await TeamStorage.getTeamByName(widget.teamName);
    if (mounted && team != null) {
      setState(() {
        players = team.players;
        isLoading = false;
      });
    } else if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void _showAddPlayerModal() {
    final TextEditingController playerNameController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
            decoration: BoxDecoration(
              color: const Color(0xFF3C3C3E),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Player',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width * 0.065,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: playerNameController,
                  autofocus: false,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                    fontFamily: 'Poppins',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter Player Name',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      fontFamily: 'Poppins',
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2C2C2E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
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
                        color: Color(0xFF2B7790),
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      String playerName = playerNameController.text.trim();
                      
                      if (playerName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a player name!'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      // Check for duplicate
                      if (players.contains(playerName)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Player already exists in this team!'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      Navigator.of(dialogContext).pop();
                      
                      // Add player to storage
                      await TeamStorage.addPlayerToTeam(widget.teamName, playerName);
                      
                      // Reload players
                      await _loadPlayers();
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$playerName added successfully!'),
                            backgroundColor: const Color(0xFF2B7790),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                      
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        playerNameController.dispose();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B7790),
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.04),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Add Player',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editPlayer(int index) {
    final TextEditingController editController = TextEditingController(text: players[index]);
    final String oldPlayerName = players[index];
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
            decoration: BoxDecoration(
              color: const Color(0xFF3C3C3E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit Player',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width * 0.065,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: editController,
                  autofocus: false,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                    fontFamily: 'Poppins',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter Player Name',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontFamily: 'Poppins',
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2C2C2E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
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
                        color: Color(0xFF2B7790),
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      String newPlayerName = editController.text.trim();
                      
                      if (newPlayerName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a player name!'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      // Check for duplicate (excluding current player)
                      if (players.contains(newPlayerName) && newPlayerName != oldPlayerName) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Player name already exists!'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      Navigator.of(dialogContext).pop();
                      
                      // Update player in storage
                      await TeamStorage.updatePlayerInTeam(widget.teamName, oldPlayerName, newPlayerName);
                      
                      // Reload players
                      await _loadPlayers();
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Player updated successfully!'),
                            backgroundColor: Color(0xFF2B7790),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                      
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        editController.dispose();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B7790),
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.04),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Update',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deletePlayer(int index) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF3C3C3E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Player',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${players[index]}"?',
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: 'Poppins',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final playerName = players[index];
                Navigator.of(dialogContext).pop();
                
                // Delete from storage
                await TeamStorage.removePlayerFromTeam(widget.teamName, playerName);
                
                // Reload players
                await _loadPlayers();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$playerName deleted successfully!'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF140088),
      appBar: AppBar(
        backgroundColor: const Color(0xFF140088),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.teamName,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF140088), Colors.black],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF2B7790),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;

                    return Column(
                      children: [
                        Expanded(
                          child: players.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 100),
                                    child: Text(
                                      'No players added yet.\nTap + to add a player.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: w * 0.045,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: w * 0.04,
                                    vertical: w * 0.02,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Players (${players.length})',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: w * 0.06,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: w * 0.04),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: players.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              key: ValueKey('player_$index'),
                                              margin: EdgeInsets.only(bottom: w * 0.03),
                                              padding: EdgeInsets.all(w * 0.04),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    const Color(0xFF2B7790).withOpacity(0.3),
                                                    const Color(0xFF1E1E1E).withOpacity(0.8),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(15),
                                                border: Border.all(
                                                  color: const Color(0xFF2B7790).withOpacity(0.5),
                                                  width: 1.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFF2B7790).withOpacity(0.2),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.all(w * 0.02),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF2B7790),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Icon(
                                                      Icons.person,
                                                      color: Colors.white,
                                                      size: w * 0.055,
                                                    ),
                                                  ),
                                                  SizedBox(width: w * 0.03),
                                                  
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          players[index],
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: w * 0.045,
                                                            fontFamily: 'Poppins',
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                        Text(
                                                          'Player ${index + 1}',
                                                          style: TextStyle(
                                                            color: Colors.white.withOpacity(0.6),
                                                            fontSize: w * 0.032,
                                                            fontFamily: 'Poppins',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  
                                                  GestureDetector(
                                                    onTap: () => _editPlayer(index),
                                                    child: Container(
                                                      padding: EdgeInsets.all(w * 0.02),
                                                      child: Icon(
                                                        Icons.edit_outlined,
                                                        color: const Color(0xFF2B7790),
                                                        size: w * 0.055,
                                                      ),
                                                    ),
                                                  ),
                                                  
                                                  SizedBox(width: w * 0.01),
                                                  
                                                  GestureDetector(
                                                    onTap: () => _deletePlayer(index),
                                                    child: Container(
                                                      padding: EdgeInsets.all(w * 0.02),
                                                      child: Icon(
                                                        Icons.delete_outline,
                                                        color: Colors.red,
                                                        size: w * 0.055,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlayerModal,
        backgroundColor: const Color(0xFF2B7790),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}