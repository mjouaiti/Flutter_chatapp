import 'package:flutter/material.dart';

import 'dart:convert'; 

import 'dart:io' show Platform;
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:path_provider/path_provider.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';
// import 'package:audioplayers/audio_cache.dart';

class ViewClass extends StatelessWidget {
  const ViewClass({
    super.key,
    required this.item,
  });

  final String item;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(item),
    );
  }
}

class recordingList extends StatefulWidget {

  recordingList();
  @override
  State<recordingList> createState() => _recordingListState();
}


class _recordingListState extends State<recordingList> {

  final String url = "http://localhost:5005/webhooks/rest/webhook";
  final String url_whisper = 'http://localhost:3000';
  // static AudioPlayer player = new AudioPlayer();
  // const alarmAudioPath = "sound_alarm.mp3";

  List<ListItem> items = List<ListItem>.generate(
        1000,
        (i) => i % 6 == 0
            ? HeadingItem('Heading $i')
            : MessageItem('Sender $i', 'Message body $i'),
      );

  _networkReply(String message,String sender,String time) async{
      var _jsonMessage = "";
       Map<String, String> requestHeaders = {
       'Content-type': 'application/json'
     };
      print(_jsonMessage);
      var jsonResponse;
      var response =await http.post(Uri.parse(url),body: _jsonMessage,headers: requestHeaders);
      var statusCode = response.statusCode;
      print(statusCode);
      if(statusCode==200){
        jsonResponse = json.decode(response.body);
      }
  }

  Future _whisper_server(String time) async{
    var request = http.MultipartRequest('POST', Uri.parse(url_whisper));
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        "",
      contentType: MediaType('application', 'audio/wav'),
      )
    );
    var resp = await request.send();
    print(resp);
    var res = await http.Response.fromStream(resp);
    print(res);
    return res.body.replaceAll('"', '').trim();
  }

  @override
  Widget build(BuildContext context) {

    const title = 'Mixed List';
    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(title),
        ),
        body: ListView.builder(
          // Let the ListView know how many items it needs to build.
          itemCount: items.length,
          // Provide a builder function. This is where the magic happens.
          // Convert each item into a widget based on the type of item it is.
          itemBuilder: (context, index) {
            final item = items[index];

            return ListTile(
              title: item.buildTitle(context),
              subtitle: item.buildSubtitle(context),
            );
          },
        ),
      ),
    );
  }

  Widget customBuild(BuildContext context, AsyncSnapshot snapshot){
    List<String> values = snapshot.data;
    return new Container(
      child: new Expanded(
        child: new ListView.builder(
          itemCount: values.length,
          itemBuilder: (context, index){
            return new ViewClass(item: values[index]);
          },
        ),
      )
    );
  }

Future<List<FileSystemEntity>>_inFutureList() async{
    Directory dir = Directory('.');
    List<FileSystemEntity> entries = dir.listSync(recursive: false).toList();
    return entries;
  }
  

    @override void dispose() {
    super.dispose();
  }
}

abstract class ListItem {
  /// The title line to show in a list item.
  Widget buildTitle(BuildContext context);

  /// The subtitle line, if any, to show in a list item.
  Widget buildSubtitle(BuildContext context);
}

/// A ListItem that contains data to display a heading.
class HeadingItem implements ListItem {
  final String heading;

  HeadingItem(this.heading);

  @override
  Widget buildTitle(BuildContext context) {
    return Row(children: <Widget>[
      Text(
      heading,
      style: Theme.of(context).textTheme.headlineSmall,
    ),
    IconButton(
            icon: Icon(Icons.play_arrow),
            iconSize: 30.0,
            color: Colors.white,
            onPressed: () {

      // player.play(heading);
    }
    ),
    IconButton(
            icon: Icon(Icons.delete),
            iconSize: 30.0,
            color: Colors.white,
            onPressed: () {

      // send remove command;
    }
    ),
    ],)
    ;

    
  }

  @override
  Widget buildSubtitle(BuildContext context) => const SizedBox.shrink();
}

/// A ListItem that contains data to display a message.
class MessageItem implements ListItem {
  final String sender;
  final String body;

  MessageItem(this.sender, this.body);

  @override
  Widget buildTitle(BuildContext context)
  {
    return Row(children: <Widget>[
      Text(
      sender,
      style: Theme.of(context).textTheme.headlineSmall,
    ),
    IconButton(
            icon: Icon(Icons.play_arrow),
            iconSize: 30.0,
            color: Colors.white,
            onPressed: () {

      // player.play(heading);
    }
    ),
    IconButton(
            icon: Icon(Icons.delete),
            iconSize: 30.0,
            color: Colors.white,
            onPressed: () {

      // send remove command;
    }
    ),
    ],)
    ;

    
   }// => Text(sender);

  @override
  Widget buildSubtitle(BuildContext context) => Text(body);
}