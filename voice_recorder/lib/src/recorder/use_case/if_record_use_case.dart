abstract class RecordUseCaseInterface {
  bool isRecording();
  Future<int> onStartRecord();
  Future<int> onStopRecord();
}
