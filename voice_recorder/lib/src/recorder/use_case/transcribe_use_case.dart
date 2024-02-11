import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_recorder/src/recorder/use_case/if_record_use_case.dart';

class TranscribeUseCase extends GetxController
    implements RecordUseCaseInterface {
  static TranscribeUseCase? _singletonInstace;
  //SpeechToText
  final SpeechToText _speechToText = SpeechToText();
  bool _initialized = false;
  var speechEnabled = false;
  var recognitionLogs = RxString("");
  var lastWords = RxString("");
  final isTranscribing = RxBool(false);

  TranscribeUseCase._() {
    _initSpeech();
  }

  static TranscribeUseCase getSharedInstance() {
    _singletonInstace ??= TranscribeUseCase._();
    return _singletonInstace!;
  }

  // SpeechToText
  // This has to happen only once per app
  void _initSpeech() async {
    if (_initialized) return;
    print("Initializing SpeechToText...");
    speechEnabled =
        await _speechToText.initialize(onStatus: _onStatus, onError: _onError);
    if (speechEnabled) {
      lastWords.value = "Press the button and start speaking";
    } else {
      lastWords.value = "Speech recognition is not available";
    }
    _initialized = true;
  }

  void _onStatus(String status) {
    debugPrint(status);
    if (status == "done") {
      //auto stop recognition
      recognitionLogs.value += "\n$lastWords";
      lastWords.value = "";
      onStopRecord();
    }
  }

  void _onError(dynamic error) {
    debugPrint(error.toString());
  }
  //end SpeechToText

  void _onSpeechResult(SpeechRecognitionResult result) {
    lastWords.value = result.recognizedWords;
    debugPrint("onSpeechResult: ${result.recognizedWords}");
  }

  @override
  Future<int> onStartRecord() async {
    if (!speechEnabled) return -1;
    isTranscribing.toggle();
    _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 30),
    );
    return 0;
  }

  @override
  Future<int> onStopRecord() async {
    if (!speechEnabled) return -1;
    isTranscribing.toggle();
    _speechToText.stop();
    return 0;
  }

  @override
  bool isRecording() {
    return isTranscribing.value;
  }
}
