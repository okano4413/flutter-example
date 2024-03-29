import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:voice_recorder/src/recorder/dataModel/record_item.dart';
import 'package:voice_recorder/src/recorder/provider/record_item_list_controller.dart';
import 'package:voice_recorder/src/recorder/use_case/if_record_use_case.dart';
import 'package:voice_recorder/src/utils/my_audio_player.dart';

class RecordUseCase extends GetxController implements RecordUseCaseInterface {
  final _record = Record();
  final _isRecording = RxBool(false);
  final _controller = Get.put(RecordItemListController());
  final MyAudioPlayer _player = MyAudioPlayer();
  final currentFile = Rx<RecordItem?>(null);

  int errorOK = 0;
  int errorRecording = 100;
  int errorNoPermission = 101;
  RecordUseCase() {
    _player.setCompletionListener(() => {currentFile.value = null});
  }

  Future<void> playAudio(RecordItem item) async {
    if (_isRecording.isTrue) {
      await onStopRecord();
    }

    String path = item.path;
    if (_player.isPlaying && !_player.isPlayingAudioPath(path)) {
      await stopAudio();
    }
    await _player.play(path);
    currentFile.value = item;
  }

  Future<void> stopAudio() async {
    if (_isRecording.isTrue) {
      await onStopRecord();
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

  @override
  Future<int> onStartRecord() async {
    if (_isRecording.value) return errorRecording;
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
      _isRecording.toggle();
      return errorOK;
    }
    return errorNoPermission;
  }

  @override
  Future<int> onStopRecord() async {
    var outputPath = await _record.stop();
    debugPrint(outputPath);
    _isRecording.toggle();
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

  @override
  bool isRecording() {
    return _isRecording.value;
  }
}
