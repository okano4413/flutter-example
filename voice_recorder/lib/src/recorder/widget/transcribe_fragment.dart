import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voice_recorder/src/recorder/use_case/transcribe_use_case.dart';

class TranscribeFragment extends StatefulWidget {
  @override
  TrasnscribeFragmentState createState() => TrasnscribeFragmentState();
}

class TrasnscribeFragmentState extends State<TranscribeFragment> {
  final usecase = Get.put(TranscribeUseCase.getSharedInstance());

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Expanded(
          child: Column(children: [
        Text(usecase.recognitionLogs.value),
        Text(usecase.lastWords.value)
      ]));
    });
  }
}
