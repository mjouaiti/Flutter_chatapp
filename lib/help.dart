import 'package:flutter_faq/flutter_faq.dart';

import 'package:flutter/material.dart';

import 'dart:convert'; 


class Help extends StatefulWidget {

  Help();
  @override
  State<Help> createState() => _HelpState();
}


class _HelpState extends State<Help> {
  @override
  void initState() { 
    
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Color.red,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          "FAQ",
          style: TextStyle(
            color: Color.fromARGB(225, 0, 0, 0),
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_horiz),
            iconSize: 30.0,
            color: Colors.white,
            onPressed: () {},
          ),
        ],
      ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            FAQ(
              question: "Question 1",
              answer: data,
            ),
            FAQ(question: "Question2", answer: data),
            FAQ(
              question: "Question 3",
              answer: data,
            ),
            FAQ(
              question: "Question 4",
              answer: data,
              showDivider: false,
            ),
            FAQ(
              question: "Question 5",
              answer: data,
            ),
            FAQ(
              question: "Question 6",
              answer: data,
            ),
            FAQ(
              question: "Question 7",
              answer: data,
              expandedIcon: const Icon(Icons.minimize),
              collapsedIcon: const Icon(Icons.add),
              showDivider: false,
              ansStyle: const TextStyle(color: Colors.blue, fontSize: 15),
              ansPadding: const EdgeInsets.all(50),
            ),
          ]),
        ),
      );
  }
  
    @override void dispose() {
    super.dispose();
  }
}

String data = """"
Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
""";