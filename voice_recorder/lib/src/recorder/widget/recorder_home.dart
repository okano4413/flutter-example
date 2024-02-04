// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:voice_recorder/assets/i18n/strings.g.dart';
import 'package:voice_recorder/src/recorder/dataModel/record_item.dart';
import 'package:voice_recorder/src/recorder/record_use_case.dart';
import 'package:voice_recorder/src/recorder/widget/record_controller.dart';
import 'list_item_record_history.dart';
import 'package:get/get.dart';
import 'package:voice_recorder/src/recorder/provider/record_item_list_controller.dart';

class RecorderHome extends StatefulWidget {
  @override
  _RecorderHomeState createState() => _RecorderHomeState();
}

class _RecorderHomeState extends State<RecorderHome> {
  //SpeechToText
  // SpeechToText _speechToText = SpeechToText();
  // bool _speechEnabled = false;
  // String _lastWords = "";
  String? _expandedItemPath;
  final _controller = Get.put(RecordItemListController());

  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    // _initSpeech();
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
          title: Text(_getTitle()),
        ),
        body: Column(
          children: [
            (_selectedIndex == 0) ? _recordWidget() : _transcribeWidget(),
            RecordController()
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (value) {
            setState(() {
              _selectedIndex = value;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.record_voice_over),
              label: t.record,
              backgroundColor: Colors.blue,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notes),
              label: t.transcribe,
              backgroundColor: Colors.blue,
            ),
          ],
        )));
  }

  Widget _recordWidget() {
    return Expanded(
        child: Container(
            color: Colors.grey[200],
            child: ListView.builder(
              shrinkWrap: true,
              // key: Key('builder {$expandedItemPath}'),
              itemCount: _controller.recordItemList.length,
              itemBuilder: (context, index) {
                RecordItem item = _controller.recordItemList[index];
                return ListItemRecordHistory(
                    isExpanded: _expandedItemPath == item.path,
                    recordItem: item,
                    onExpanded: _onExpandedItem);
              },
            )));
  }

  Widget _transcribeWidget() {
    return Expanded(
      child: Container(
        child: Text('transcribe'),
      ),
    );
  }

  String _getTitle() {
    if (_selectedIndex == 0) {
      return t.record;
    } else {
      return t.transcribe;
    }
  }
}
