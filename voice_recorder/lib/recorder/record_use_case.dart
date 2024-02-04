import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:voice_recorder/recorder/dataModel/record_item.dart';
import 'package:voice_recorder/recorder/provider/record_item_list_controller.dart';
import 'package:voice_recorder/utils/my_audio_player.dart';

class RecordUseCase extends GetxController {
  final _record = Record();
  final isRecording = RxBool(false);
  final _controller = Get.put(RecordItemListController());
  final MyAudioPlayer _player = MyAudioPlayer();
  final currentFile = Rx<RecordItem?>(null);

  int errorOK = 0;
  int errorRecording = 100;
  int errorNoPermission = 101;
  RecordUseCase() {
    _player.setCompletionListener(() => {currentFile.value = null});
  }

  Future<int> startRecord() async {
    if (isRecording.value) return errorRecording;
    if (_player.isPlaying) {
      await stopAudio();
    }
    if (await _record.hasPermission()) {
      // Start recording
      final path = await _filePath;
      await _record.start(
        path: path,
        encoder: AudioEncoder.aacLc, // by default
        bitRate: 128000, // by default
        samplingRate: 44100, // by default
      );
      isRecording.toggle();
      return errorOK;
    }
    return errorNoPermission;
  }

  Future<int> stopRecord() async {
    var outputPath = await _record.stop();
    debugPrint(outputPath);
    isRecording.toggle();
    int id = -1;
    if (outputPath != null) {
      File file = File(outputPath);
      String title = _getCurrentTime();
      String path = await FileSaver.instance.saveFile(
        name: title,
        file: file,
        mimeType: MimeType.aac,
      );
      id = await _controller.addRecordItem(path, title);
    }
    return id;
  }

  Future<void> playAudio(RecordItem item) async {
    if (isRecording.isTrue) {
      await stopRecord();
    }

    String path = item.path;
    if (_player.isPlaying && !_player.isPlayingAudioPath(path)) {
      await stopAudio();
    }
    await _player.play(path);
    currentFile.value = item;
  }

  Future<void> stopAudio() async {
    if (isRecording.isTrue) {
      await stopRecord();
    }
    await _player.stop();
    currentFile.value = null;
  }

  Future<void> pauseAudio(RecordItem item) async {
    if (currentFile.value == null || item.path != currentFile.value!.path) {
      return;
    }
    _player.pause();
  }

  bool isPlayingAudioPath(String path) {
    return _player.isPlayingAudioPath(path);
  }

  Future<String> get _filePath async {
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    var file = File('$path/${DateTime.now().millisecondsSinceEpoch}.aac}');
    return file.path;
  }

  String _getCurrentTime() {
    var now = DateTime.now();
    return "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}";
  }
}
