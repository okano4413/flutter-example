// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:voice_recorder/assets/i18n/strings.g.dart';
import 'package:voice_recorder/src/recorder/widget/record_controller.dart';
import 'package:voice_recorder/src/recorder/widget/recorder_fragment.dart';
import 'package:voice_recorder/src/recorder/widget/transcribe_fragment.dart';

class RecorderHome extends StatefulWidget {
  @override
  RecorderHomeState createState() => RecorderHomeState();
}

class RecorderHomeState extends State<RecorderHome> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_getTitle()),
        ),
        body: Column(
          children: [
            (_selectedIndex == 0) ? RecorderFragment() : TranscribeFragment(),
            RecordController(
                mode: (_selectedIndex == 0)
                    ? RecordMode.record
                    : RecordMode.transcribe)
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
              icon: const Icon(Icons.record_voice_over),
              label: t.record,
              backgroundColor: Colors.blue,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.notes),
              label: t.transcribe,
              backgroundColor: Colors.blue,
            ),
          ],
        ));
  }

  String _getTitle() {
    if (_selectedIndex == 0) {
      return t.record;
    } else {
      return t.transcribe;
    }
  }
}
