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
// import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';

// import 'package:whisper_dart/whisper_dart.dart';
// import "package:whisper_dart/scheme/scheme.dart";

import 'dart:ffi';
import 'package:ffi/ffi.dart';

const theSource = AudioSource.microphone;


class plwdQuestionnaire extends StatefulWidget {

  plwdQuestionnaire();
  @override
  State<plwdQuestionnaire> createState() => _plwdQuestionnaireState();
}

enum TtsState { playing, stopped, paused, continued }

class _plwdQuestionnaireState extends State<plwdQuestionnaire> {

  late List<Message> messages ;
  final String url = "http://localhost:5005/webhooks/rest/webhook";
  final String url_whisper = 'http://localhost:3000';

  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  String? _newVoiceText;

  // stt.SpeechToText _speech = stt.SpeechToText();
  FlutterTts flutterTts = FlutterTts();

  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  double _confidence = 1.0;

  TtsState ttsState = TtsState.stopped;

  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  Codec _codec = Codec.aacMP4;
  bool _mRecorderIsInited = false;
  String _mPath = '/Users/Melanie/Downloads/tau_file.mp4';

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  @override
  void initState() { 
    initTts();
    initRecorder();

    var mess = "Hey! How may I assist you?";
    _newVoiceText = mess;
    _speak();

    messages =[ Message(text: mess, time: "123", isMe: false)] ;
    // _speech = stt.SpeechToText();
    super.initState();
  }

  Future<void> initRecorder() async{
    if (!kIsWeb) {
      var status = await Permission.microphone.status;
      print(status);
      status = await Permission.microphone.request();
      print(status);

      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _mRecorder!.openRecorder();
    if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.opusWebM;
      _mPath = 'tau_file.webm';
      if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
        _mRecorderIsInited = true;
        return;
      }
    }
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    if (isAndroid) {
      flutterTts.setInitHandler(() {
        setState(() {
          print("TTS Initialized");
        });
      });
    }

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        print("Paused");
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        print("Continued");
        ttsState = TtsState.continued;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.awaitSynthCompletion(true);
  }

  Future _stop() async{
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

    Future<dynamic> _getLanguages() async => await flutterTts.getLanguages;

  Future<dynamic> _getEngines() async => await flutterTts.getEngines;

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText!.isNotEmpty) {
        await flutterTts.speak(_newVoiceText!);
      }
    }
  }

  void _listen(String lang) async {
    if (!_isListening) {
      setState(() => _isListening = true);
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      String datetime = tsdate.year.toString() + "_" + tsdate.month.toString() + "_" + 
                        tsdate.day.toString() + "-" + tsdate.hour.toString() + 
                        "_" + tsdate.minute.toString() + "_" + tsdate.second.toString();
      print(datetime);
      _mPath = "/Users/Melanie/Downloads/" + datetime + ".mp4";
      print(_mPath);
      _mRecorder!.startRecorder(
      toFile: _mPath,
      codec: _codec,
      audioSource: theSource,
      ).then((value) async {
        
      });
    } else{
      await _mRecorder!.stopRecorder().then((value) {});

      var res = await _whisper_server("Time");
      print(res);
      controller.text = res;

      // messages.add(Message(
      //   text: _text,
      //   time: "Time",
      //   isMe: true
      //   ));
      //  messages.add(Message(text: "loading", time: "123", isMe: true));
      // _networkReply(_text, "", "Time");
      
      setState(() {_isListening = false;_text = 'Press the button and start speaking';
                  controller.text = res!;});
    }
  }
      

  final controller = TextEditingController();

  _networkReply(String message,String sender,String time) async{
      Sent sentMessage = Sent(sender,message);
      var _jsonMessage = jsonEncode(sentMessage);
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
        var parsedResponse = ReplyArray.fromJson(jsonResponse);
        var list = parsedResponse.replies;
        setState(() {
          messages.removeLast();
          messages.add(Message(text: list[0].text, time: time,isMe: false));
        });
        _newVoiceText = list[0].text;
        _speak();
      }
  }

  Future _whisper_server(String time) async{
    var request = http.MultipartRequest('POST', Uri.parse(url_whisper));
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        _mPath,
      contentType: MediaType('application', 'audio/wav'),
      )
    );
    var resp = await request.send();
    print(resp);
    var res = await http.Response.fromStream(resp);
    print(res);
    return res.body.replaceAll('"', '').trim();
  }


  _buildMessage(Message message, bool isMe) {
    final Container msg = Container(
      margin: isMe
          ? EdgeInsets.only(
            right: 8.0,
              top: 8.0,
              bottom: 8.0,
              left: 80.0,
            )
          : EdgeInsets.only(
            left: 8.0,
              top: 8.0,
              bottom: 8.0,
              right: 80.0
            ),
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
      width: MediaQuery.of(context).size.width * 0.70,
      decoration: BoxDecoration(
        color: isMe ? Color.fromARGB(255, 196, 72, 72) : Color.fromARGB(255, 81, 0, 0),
        borderRadius: isMe
            ? BorderRadius.only(
                topLeft: Radius.circular(15.0),
                bottomLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
              )
            : BorderRadius.only(
                topRight: Radius.circular(15.0),
                bottomRight: Radius.circular(15.0),
                bottomLeft: Radius.circular(15.0),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            message.text,
            style: TextStyle(
              color: Color(0xffF5F7DC),
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    
    return msg;
  }
  
  @override
  Widget build(BuildContext context) {

    

      return Scaffold(
      backgroundColor: Color.fromARGB(255, 244, 155, 155),
      appBar: AppBar(
        // backgroundColor: Color.red,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          "PLwD Questionnaire",
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 250, 249, 251),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                  child: ListView.builder(
                    reverse: false,
                    padding: EdgeInsets.only(top: 15.0),
                    itemCount: messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      Message message = messages[index];
                      bool isMe = message.isMe;
                      if(message.text=="loading") return  SpinKitWave(color: Color(0xffF5F7DC), type: SpinKitWaveType.start,size: 25.0,);
                        
                      else
                      return _buildMessage(message, isMe);
                    },
                  ),
                ),
              ),
            ),
             Text(_text,
            style: TextStyle(color: Color(0xffF5F7DC),)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  icon: _isListening? CircularProgressIndicator(strokeWidth: 2,):Icon(Icons.mic),
                  label: Text(
                    _isListening? "Stop":"Speak in English"
                  ),
                  onPressed: ()=>_listen("en"),
                ),
              ],
            ),
           
            Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 90.0,
      color: Color.fromARGB(255, 244, 155, 155),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
                style: TextStyle(color: Color(0xffF5F7DC),),
              controller: controller,
              onSubmitted: (text) {
              messages.add(Message(text: text, time: "123", isMe: true));
              messages.add(Message(text: "loading", time: "123", isMe: true));
              controller.clear();
              _networkReply(text, "", "Time");
              setState(() {});
            },
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration.collapsed(
                hintText: 'Send a message...',
                hintStyle: TextStyle(color: Color.fromARGB(161, 118, 0, 0),)
              ),
            ),
          ),
          // IconButton(
          //   icon: _isListening? Icon(Icons.stop):Icon(Icons.mic),
          //   iconSize: 25.0,
          //   color:_isListening?Colors.red: Color(0xffF5F7DC) ,
          //   onPressed:()=>_listen(1)
          // ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25.0,
            color:Color(0xffF5F7DC) ,
            onPressed: () {
              messages.add(Message(
                text: controller.text,
                time: "Time",
                isMe: true
                ));
                messages.add(Message(text: "loading", time: "123", isMe: true));
                _networkReply(controller.text, "", "Time");
                controller.clear();
              setState(() {
                
              });
            
            }
          ),
        ],
      ),
    ),
          ],
        ),
      ),
    );
  }
    @override void dispose() {
    super.dispose();
    controller.dispose();
  }
}