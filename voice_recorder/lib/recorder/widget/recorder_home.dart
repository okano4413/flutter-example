// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:voice_recorder/database/db.dart';
import 'package:voice_recorder/recorder/dataModel/record_item.dart';
import 'package:voice_recorder/recorder/widget/record_controller.dart';
import 'package:voice_recorder/utils/my_audio_player.dart';
import 'list_item_record_history.dart';
import 'package:get/get.dart';
import 'package:voice_recorder/recorder/provider/record_item_list_controller.dart';

class RecorderHome extends StatefulWidget {
  @override
  _RecorderHomeState createState() => _RecorderHomeState();
}

class _RecorderHomeState extends State<RecorderHome> {
  //SpeechToText
  // SpeechToText _speechToText = SpeechToText();
  // bool _speechEnabled = false;
  // String _lastWords = "";
  final MyAudioPlayer _player = MyAudioPlayer();
  // bool _isRecording = false;
  RecordItem? _currentFile;
  String? _expandedItemPath;
  final _controller = Get.put(RecordItemListController());
  @override
  void initState() {
    super.initState();
    _initAudioListener();
    
    // _initSpeech();
  }

  void _initAudioListener() {
    _player.setCompletionListener(() => {
      setState(() {
        _currentFile = null;
      })
    });

    // _player.onAudioDurationChanged.listen((event) {
    //   if (currentFile?.path == _player.currentFilePath) {
    //     var item = _recordedItems.firstWhere((element) => element.path == currentFile?.path);
    //     item.duration = event;
    //     setState(() {});
    //   }
    // });

  }

  // SpeechToText
  /// This has to happen only once per app
  // void _initSpeech() async {
  //   _speechEnabled = await _speechToText.initialize(onStatus: _onStatus, onError: _onError);
  //   setState(() {});
  // }

  // void _onStatus(String status) {
  //   print(status);
  // }

  // void _onError(dynamic error) {
  //   print(error.toString());
  // }
  // //end SpeechToText

  // void _onSpeechResult(SpeechRecognitionResult result) {
  //   setState(() {
  //     _lastWords = result.recognizedWords;
  //     print(_lastWords);
  //   });
  // }

  // void _onClickAudioItem(String path) async{
  //   //タップされたアイテムが再生中のアイテムだった場合停止する
  //   if (isPlaying && path == currentFilePath) {
  //     _stopAudio();
  //     return;
  //   }
  //   //違うアイテムがタップされた場合は再生する
  //   _playAudio(path);
  // }

  void _playAudio(RecordItem item) async{
    // await player.setSource(AssetSource("001-sibutomo.mp3"));
    String path = item.path;
    if (_player.isPlaying && !_player.isPlayingAudioPath(path)) {
      _stopAudio();
    }
    await _player.play(path);
    setState(() {
      _currentFile = item;
    });
  }

  void _stopAudio() async{
    await _player.stop();
    setState(() {
      _currentFile = null;
    });
  }

  void _onPauseAudio(RecordItem item) async {
    if (_currentFile == null || item.path != _currentFile!.path) {
      return;
    }
    _player.pause();
    setState(() {});
  }

  void _onExpandedItem(String path, bool isExpanded) {
    if (_expandedItemPath == null) {
      setState(() {
        _expandedItemPath = path;
      });
    } else if (_expandedItemPath == path && !isExpanded) {
      setState(() {
        _expandedItemPath = null;
      });
    } else if (_expandedItemPath != path && isExpanded) {
      setState(() {
        _expandedItemPath = path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      appBar: AppBar(
        title: const Text('Recorder Home',
        ),

      ),
      body:Column(
        children: [
          Expanded(child: ListView.builder(
            shrinkWrap: true,
            // key: Key('builder {$expandedItemPath}'),
            itemCount: _controller.recordItemList.length,
            itemBuilder: (contet, index){
              RecordItem item = _controller.recordItemList[index];
            return ListItemRecordHistory(
              isExpanded: _expandedItemPath == item.path,
              isPlaying: _player.isPlayingAudioPath(item.path),
              recordItem:item,
              onPlayAudio: _playAudio , 
              onStopAudio: _stopAudio,
              onPause: _onPauseAudio,
              onExpanded: _onExpandedItem) ;
          },)),
          RecordController(
            isPlaying: _player.isPlaying,
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          if (value == 0) {
            Navigator.pushNamed(context, '/recorder');
          } else if (value == 1) {
            Navigator.pushNamed(context, '/recorder');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.record_voice_over),
            label: '録音',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notes),
            label: '文字起こし',
            backgroundColor: Colors.blue,
          ),
        ],
      )
    )) ;
  }
}
