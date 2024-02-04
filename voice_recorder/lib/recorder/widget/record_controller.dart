import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voice_recorder/recorder/record_use_case.dart';

class RecordController extends StatefulWidget {
  RecordController({Key? key}) : super(key: key);

  @override
  _RecordControllerState createState() => _RecordControllerState();
}

class _RecordControllerState extends State<RecordController> {
  final _usecase = Get.put(RecordUseCase());
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Obx(() => ElevatedButton(
                  onPressed: () {
                    if (_usecase.isRecording.value) {
                      _usecase.stopRecord();
                    } else {
                      _usecase.startRecord();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor:
                        (_usecase.isRecording.value) ? Colors.red : Colors.grey,
                    shape: const CircleBorder(
                        side: BorderSide(color: Colors.white, width: 5)),
                    minimumSize: const Size(100, 100),
                    shadowColor: Colors.black,
                  ),
                  child: const Text(" "),
                ))));
  }
}
