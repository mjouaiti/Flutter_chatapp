import 'package:flutter/material.dart';

import 'dart:convert'; 

import 'dart:io' show Platform;
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'message_model.dart';
import 'reply_model.dart';
import 'sent_model.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';


class EventLog extends StatefulWidget {
  EventLog();

  @override
  State<EventLog> createState() => _EventLogState();
}


class _EventLogState extends State<EventLog>{
  final String url = "http://localhost:5005/webhooks/rest/webhook";
  String text = "";
      
  _networkReply(String message,String sender,String time) async{
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      String datetime = tsdate.year.toString() + "_" + tsdate.month.toString() + "_" + 
                        tsdate.day.toString() + "-" + tsdate.hour.toString() + 
                        "_" + tsdate.minute.toString() + "_" + tsdate.second.toString();
      print(datetime);
      Sent sentMessage = Sent(sender,datetime + message);
      var _jsonMessage = jsonEncode(sentMessage);
       Map<String, String> requestHeaders = {
       'Content-type': 'application/json'
     };
      print(_jsonMessage);
      var response =await http.post(Uri.parse(url),body: _jsonMessage,headers: requestHeaders);
      var statusCode = response.statusCode;
      print(statusCode);
      if(statusCode==200){
        setState(() {
          text = message + "has been logged successfully, thanks!";        });
      }
  }
  
  @override
  Widget build(BuildContext context) {

      return Scaffold(
      appBar: AppBar(
        // backgroundColor: Color.red,
        backgroundColor: Color.fromARGB(255, 201, 155, 244),
        title: Text(
          "Event Log",
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
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(onPressed: () {
            // _EventLogState.getNext();
            print('button pressed');
            _networkReply('Hospitalisation', "", "");
          }, child: const Text('Hospitalisation'),
          ),
          ElevatedButton(onPressed: () {
            // _EventLogState.getNext();
            print('button pressed');
            _networkReply('Fall', "", "");
          }, child: const Text('Fall'),
          ),
          ElevatedButton(onPressed: () {
            // _EventLogState.getNext();
            print('button pressed');
            _networkReply('Illness', "", "");
          }, child: const Text('Illness'),
          ),
          ElevatedButton(onPressed: () {
            // _EventLogState.getNext();
            print('button pressed');
            _networkReply('Change in care arrangements', "", "");
          }, child: const Text('Change in care arrangements'),
          ),
          Text(text,
        softWrap: true,
      ),
          ]
        )
      ),
      );
  }
    @override void dispose() {
    super.dispose();
  }
}