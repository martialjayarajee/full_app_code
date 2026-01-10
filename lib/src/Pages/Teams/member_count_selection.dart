// import 'package:TURF_TOWN_/src/Pages/Teams/team_members.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
//
// class MemberCountSelection extends StatefulWidget {
//   final String teamName;
//
//   const MemberCountSelection({super.key, required this.teamName});
//
//   @override
//   State<MemberCountSelection> createState() => _MemberCountSelectionState();
// }
//
// class _MemberCountSelectionState extends State<MemberCountSelection> {
//   int? selectedMemberCount;
//
//   @override
//     final h = MediaQuery.of(context).size.height;
//
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Color(0xFF140088), Colors.black],
//             stops: [0.0, 0.2],
//           ),
//         ),
//         child: SafeArea(
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               final w = constraints.maxWidth;
//               final h = constraints.maxHeight;
//
//               return Stack(
//                 children: [
//                   // Header
//                   Positioned(
//                     top: w * 0.04,
//                     left: w * 0.04,
//                     right: w * 0.04,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text.rich(
//                           TextSpan(
//                             children: [
//                               TextSpan(
//                                 text: 'Cricket ',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: w * 0.1,
//                                   fontFamily: 'Poppins',
//                                   fontWeight: FontWeight.w400,
//                                 ),
//                               ),
//                               TextSpan(
//                                 text: 'Scorer',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: w * 0.05,
//                                   fontFamily: 'Poppins',
//                                   fontWeight: FontWeight.w400,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Row(
//                           children: [
//                             SvgPicture.asset(
//                               'assets/images/ix_support.svg',
//                               width: w * 0.065,
//                               height: w * 0.065,
//                               colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
//                             ),
//                             SizedBox(width: w * 0.025),
//                             Opacity(
//                               opacity: 0.90,
//                               child: SvgPicture.asset(
//                                 'assets/images/Group.svg',
//                                 width: w * 0.065,
//                                 height: w * 0.065,
//                                 colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Centered Dialog
//                   Center(
//                     child: Container(
//                       width: w * 0.85,
//                       padding: EdgeInsets.symmetric(
//                         horizontal: w * 0.06,
//                         vertical: h * 0.04,
//                       ),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF3C3C3E),
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withValues(alpha: 0.3),
//                             blurRadius: 20,
//                             offset: const Offset(0, 10),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             'Select Member Count',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: w * 0.06,
//                               fontFamily: 'Poppins',
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           SizedBox(height: h * 0.035),
//
//                           // Dropdown
//                           Container(
//                             padding: EdgeInsets.symmetric(horizontal: w * 0.04),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF2C2C2E),
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(
//                                 color: const Color(0xFF5C5C5E),
//                                 width: 1,
//                               ),
//                             ),
//                             child: DropdownButtonHideUnderline(
//                               child: DropdownButton<int>(
//                                 value: selectedMemberCount,
//                                 hint: Text(
//                                   'Select number of members',
//                                   style: TextStyle(
//                                     color: Colors.white.withValues(alpha: 0.5),
//                                     fontSize: w * 0.04,
//                                     fontFamily: 'Poppins',
//                                   ),
//                                 ),
//                                 isExpanded: true,
//                                 dropdownColor: const Color(0xFF2C2C2E),
//                                 icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
//                                 items: List.generate(11, (index) => index + 1).map((int value) {
//                                   return DropdownMenuItem<int>(
//                                     value: value,
//                                     child: Text(
//                                       '$value ${value == 1 ? 'Member' : 'Members'}',
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 16,
//                                         fontFamily: 'Poppins',
//                                       ),
//                                     ),
//                                   );
//                                 }).toList(),
//                                 onChanged: (int? newValue) {
//                                   setState(() {
//                                     selectedMemberCount = newValue;
//                                   });
//                                 },
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: h * 0.035),
//
//                           // Add Team Members Button
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               onPressed: selectedMemberCount == null
//                                   ? null
//                                   : () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => TeamMemberPage(
//                                             teamName: widget.teamName,
//                                             memberCount: selectedMemberCount!,
//                                             isFirstTeam: true,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFF00C4FF),
//                                 disabledBackgroundColor: const Color(0xFF00C4FF).withOpacity(0.5),
//                                 padding: EdgeInsets.symmetric(
//                                   vertical: w * 0.04,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(25),
//                                 ),
//                                 elevation: 0,
//                               ),
//                               child: Text(
//                                 'Add Team Members',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: w * 0.045,
//                                   fontFamily: 'Poppins',
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }