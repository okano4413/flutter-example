import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voice_recorder/src/recorder/use_case/if_record_use_case.dart';
import 'package:voice_recorder/src/recorder/use_case/record_use_case.dart';
import 'package:voice_recorder/src/recorder/use_case/transcribe_use_case.dart';

enum RecordMode { record, transcribe }

class RecordController extends StatefulWidget {
  RecordController({Key? key, required this.mode}) : super(key: key);
  RecordMode mode;
  @override
  RecordControllerState createState() => RecordControllerState();
}

class RecordControllerState extends State<RecordController> {
  final _recordUsecase = Get.put(RecordUseCase());
  final _transcribeUsecase = Get.put(TranscribeUseCase.getSharedInstance());
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.grey[200],
        child: Center(
            child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: Obx(() => ElevatedButton(
                      onPressed: () {
                        final usecase = _getUseCase();
                        if (usecase.isRecording()) {
                          usecase.onStopRecord();
                        } else {
                          usecase.onStartRecord();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: (_getUseCase().isRecording())
                            ? Colors.red
                            : Colors.grey,
                        shape: const CircleBorder(
                            side: BorderSide(color: Colors.white, width: 5)),
                        minimumSize: const Size(100, 100),
                        shadowColor: Colors.black,
                      ),
                      child: const Icon(Icons.mic, size: 50),
                    )))));
  }

  RecordUseCaseInterface _getUseCase() {
    if (widget.mode == RecordMode.transcribe) {
      return _transcribeUsecase;
    }
    return _recordUsecase;
  }
}
