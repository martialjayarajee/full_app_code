import 'package:flutter/material.dart';
import '../Providers/score_card_logic.dart';
import '../CommonParameters/AppBackGround1/Appbg2.dart';
import '../widgets/buttons.dart';
import '../widgets/Circular_button.dart';

class ScoreCardUI extends StatefulWidget {
  final ScoreCardLogic logic;

  const ScoreCardUI({super.key, required this.logic});

  @override
  State<ScoreCardUI> createState() => _ScoreCardUIState();
}

class _ScoreCardUIState extends State<ScoreCardUI> {
  bool _isExtrasMenuOpen = false;
  bool _showExtraRunsDialog = false;
  String _extraType = '';

  void _toggleExtrasMenu() {
    setState(() => _isExtrasMenuOpen = !_isExtrasMenuOpen);
  }

  void _handleExtra(String type) {
    _toggleExtrasMenu();
    if (type == 'BYE' || type == 'LB') {
      setState(() {
        _extraType = type;
        _showExtraRunsDialog = true;
      });
    } else {
      _processExtra(type, 0);
    }
  }

  void _processExtra(String type, int runs) {
    setState(() {
      switch (type) {
        case 'WD':
          widget.logic.addWide(runs: 1 + runs);
          break;
        case 'NB':
          widget.logic.addNoBall(battingRuns: runs);
          break;
        case 'BYE':
          widget.logic.addByes(runs);
          break;
        case 'LB':
          widget.logic.addLegByes(runs);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: Stack(
        children: [
          Appbg2(),

          Column(
            children: [
              SizedBox(height: height * 0.1),
              Text(
                'Score Board',
                style: TextStyle(
                    fontSize: width * 0.055,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: height * 0.02),

              // 1. Header Card (Score, CRR, NRR)
              _buildInfoCard(
                size,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _teamStats(width),
                    _scoreDisplay(width),
                  ],
                ),
              ),
              SizedBox(height: height * 0.02),

              // 2. Batsman Table Card
              _buildDataTableCard(
                  width, "Batsman", ["R", "B", "4s", "6s", "SR"], [
                _buildBatsmanRow(
                    width, widget.logic.batsman1, widget.logic.strikerIndex == 0),
                _buildBatsmanRow(
                    width, widget.logic.batsman2, widget.logic.strikerIndex == 1),
              ]),
              SizedBox(height: height * 0.01),

              // 3. Bowler Table Card
              _buildDataTableCard(width, "Bowler", ["O", "R", "W", "ER"], [
                _buildBowlerRow(width, widget.logic.currentBowler),
              ]),
              SizedBox(height: height * 0.01),

              // 4. Ball History List
              _buildHorizontalBallHistory(width, height),

              // 5. Score Buttons
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _scoreButton('4', height * 0.1, 4),
                  _scoreButton('3', height * 0.07, 3),
                  _scoreButton('1', height * 0.04, 1),
                  _scoreButton('0', height * 0.01, 0),
                  _scoreButton('2', height * 0.04, 2),
                  _scoreButton('5', height * 0.07, 5),
                  _scoreButton('6', height * 0.1, 6),
                ],
              ),
              GradientCircleButton(
                  label: 'W',
                  onPressed: () {
                    setState(() => widget.logic.addWicket());
                  }),
            ],
          ),

          if (_isExtrasMenuOpen)
            GestureDetector(
                onTap: _toggleExtrasMenu,
                child: Container(color: Colors.black.withOpacity(0.6))),

          _extraButton('Byes', 'BYE', width, height, 0.22, 0.05),
          _extraButton('Leg Byes', 'LB', width, height, 0.14, 0.25),
          _extraButton('Wide', 'WD', width, height, 0.06, 0.45),
          _extraButton('No Ball', 'NB', width, height, 0.01, 0.65),

          _buildPositionedFAB(
              width, height, Alignment.bottomLeft, 'Extras', _toggleExtrasMenu, null),
          _buildPositionedFAB(width, height, Alignment.bottomRight, 'Undo', () {
            setState(() => widget.logic.undoLastAction());
          }, Icons.undo),

          // Extra Runs Dialog
          if (_showExtraRunsDialog) _buildExtraRunsDialog(width, height),
        ],
      ),
    );
  }

  Widget _buildExtraRunsDialog(double width, double height) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showExtraRunsDialog = false),
        child: Container(
          color: Colors.black.withOpacity(0.7),
          child: Center(
            child: Container(
              width: width * 0.8,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2126),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _extraType == 'BYE' ? 'Byes Runs' : 'Leg Byes Runs',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int i = 1; i <= 4; i++)
                        ElevatedButton(
                          onPressed: () {
                            _processExtra(_extraType, i);
                            setState(() => _showExtraRunsDialog = false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(20),
                          ),
                          child: Text(
                            '$i',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataTableCard(
      double width, String header, List<String> columns, List<Widget> rows) {
    return Container(
      width: width * 0.9,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2126),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF2A2E35),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text(header,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))),
                ...columns.map((col) => Expanded(
                  child: Text(col,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
                )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }

  Widget _buildBatsmanRow(
      double width, Map<String, dynamic> data, bool isOnStrike) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text("${data['name']}${isOnStrike ? '*' : ''}",
                  style: TextStyle(
                      color: isOnStrike ? Colors.white : Colors.white70,
                      fontWeight:
                      isOnStrike ? FontWeight.bold : FontWeight.normal))),
          Expanded(
              child: Text("${data['runs']}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70))),
          Expanded(
              child: Text("${data['balls']}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70))),
          Expanded(
              child: Text("${data['fours']}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70))),
          Expanded(
              child: Text("${data['sixes']}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70))),
          Expanded(
            child: Text(
              (data['sr'] as num).toStringAsFixed(2),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBowlerRow(double width, Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text("${data['name']}",
                  style: const TextStyle(color: Colors.white))),
          Expanded(
              child: Text("${widget.logic.overs}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70))),
          Expanded(
              child: Text("${widget.logic.runsConceded}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70))),
          Expanded(
              child: Text("${widget.logic.wicketsTaken}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70))),
          Expanded(
              child: Text("${widget.logic.economyRate.toStringAsFixed(2)}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }

  Widget _teamStats(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('IND',
            style: TextStyle(
                color: Colors.white,
                fontSize: width * 0.08,
                fontWeight: FontWeight.w400)),
        Text(
            'Extras: ${widget.logic.wides + widget.logic.noBalls + widget.logic.byes + widget.logic.legByes}',
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Text('Overs: ${widget.logic.overs}',
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }

  Widget _scoreDisplay(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('${widget.logic.totalRuns}-${widget.logic.wickets}',
            style: TextStyle(
                color: Colors.white,
                fontSize: width * 0.1,
                fontWeight: FontWeight.w400)),
        Text('(${widget.logic.overs})',
            style: const TextStyle(color: Colors.white70, fontSize: 16)),
      ],
    );
  }

  Widget _buildInfoCard(Size size, Widget child, {double height = 0}) {
    return Container(
      width: size.width * 0.9,
      height: height == 0 ? size.height * 0.15 : height,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
          color: const Color(0xFF1E2126),
          borderRadius: BorderRadius.circular(25)),
      child: child,
    );
  }

  Widget _buildPositionedFAB(double width, double height, Alignment align,
      String label, VoidCallback press, IconData? icon) {
    return Positioned(
      left: align == Alignment.bottomLeft ? width * 0.05 : null,
      right: align == Alignment.bottomRight ? width * 0.05 : null,
      bottom: height * 0.03,
      child: SizedBox(
        width: width * 0.12,
        height: width * 0.12,
        child: FloatingActionButton(
          heroTag: label,
          onPressed: press,
          backgroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: icon != null
              ? Icon(icon, color: const Color(0xFF2A313B))
              : Text(label,
              style: const TextStyle(
                  color: Color(0xFF2A313B),
                  fontWeight: FontWeight.bold,
                  fontSize: 10)),
        ),
      ),
    );
  }

  Widget _scoreButton(String label, double top, int run) {
    return Padding(
        padding: EdgeInsets.only(top: top),
        child: GradientButton(
            label: label,
            onPressed: () {
              setState(() => widget.logic.addRuns(run));
            }));
  }

  Widget _extraButton(String label, String type, double width, double height,
      double bottom, double left) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: _isExtrasMenuOpen ? width * left : width * 0.05,
      bottom: _isExtrasMenuOpen ? height * bottom : height * 0.03,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isExtrasMenuOpen ? 1 : 0,
        child: Visibility(
          visible: _isExtrasMenuOpen,
          child: ElevatedButton(
            onPressed: () => _handleExtra(type),
            style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.all(16)),
            child: Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10)),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalBallHistory(double width, double height) {
    return Container(
      width: width * 0.9,
      height: height * 0.06,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2126), Color(0xFF2A2E35)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Text(
            "OVER",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const VerticalDivider(
              color: Colors.white24, indent: 10, endIndent: 10, width: 20),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                children: widget.logic.ballHistory.isEmpty
                    ? [
                  const Text("Waiting for delivery...",
                      style:
                      TextStyle(color: Colors.white38, fontSize: 12))
                ]
                    : widget.logic.ballHistory.map((ball) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildBallIcon(ball, width),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBallIcon(String ball, double width) {
    Color ballColor;
    if (ball == 'W') {
      ballColor = Colors.redAccent;
    } else if (ball == '4' || ball == '6') {
      ballColor = Colors.greenAccent;
    } else if (ball.contains('WD') ||
        ball.contains('NB') ||
        ball.contains('B+') ||
        ball.contains('LB+')) {
      ballColor = Colors.amberAccent;
    } else {
      ballColor = Colors.white;
    }

    return Container(
      width: width * 0.09,
      height: width * 0.09,
      decoration: BoxDecoration(
        color: ballColor.withOpacity(0.10),
        shape: BoxShape.circle,
        border: Border.all(color: ballColor.withOpacity(0.6), width: 0.5),
      ),
      child: Center(
        child: Text(
          ball,
          style: TextStyle(
            color: ballColor,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}