// import 'package:flutter/material.dart';
// import 'package:chat_bubbles/chat_bubbles.dart';

// class dynamicWidget extends StatelessWidget {
//   Widget Question = BubbleNormal();
//   Widget Answer = BubbleNormal();

//   @override
//   Widget build(BuildContext context) {

//     return Stack(
//       children: [
//         SingleChildScrollView(
//           child: Column(
//             children: <Widget>[
//           Row(
//             children: <Widget>[
//             BubbleNormal(
//                 text: 'bubble normal with tail',
//                 isSender: false,
//                 color: Color(0xFF1B97F3),
//                 tail: true,
//                 controller: Question,
//                 textStyle: TextStyle(
//                   fontSize: 20,
//                   color: Colors.white,
//                 ),
//               ),
//               Container(
//                 width: 100,
//                 padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
//                   child: new TextFormField(
//                   controller: Price,
//                     decoration: const InputDecoration(
//                         labelText: 'Price', 
//                         border: OutlineInputBorder()
//                   ),
//                   keyboardType: TextInputType.number,
//                 ),
//               )
//             ],
//           )
//         ],
//       ),
//     );
//   }

// }