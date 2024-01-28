import 'package:audioplayers/audioplayers.dart';

class MyAudioPlayer {
  static final MyAudioPlayer _instance = MyAudioPlayer._internal();
  factory MyAudioPlayer() => _instance;
  MyAudioPlayer._internal() {
    _audioPlayer.onPlayerComplete.listen((event) {
      onComplete();
    });
    _audioPlayer.onPositionChanged.listen((event) {
      
    });
  }
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Function()> completionListener = [];

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  String _currentFilePath = "";
  String get currentFilePath => _currentFilePath;

  bool isPlayingAudioPath(String path) => (isPlaying && currentFilePath == path);

  Future<void> play(String path) async{
    _currentFilePath = path;
    await _audioPlayer.setSource(DeviceFileSource(path));
    await _audioPlayer.resume();
    _isPlaying = true;
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    _currentFilePath = "";
  }

  void pause() {
    _audioPlayer.pause();
    _isPlaying = false;
  }

  Stream <Duration> get onAudioDurationChanged => _audioPlayer.onDurationChanged;    
  Stream<Duration> get onAudioPositionChanged => _audioPlayer.onPositionChanged;
   
  Future<void> seek(Duration duration) async {
    await _audioPlayer.seek(duration);
  }
  void setCompletionListener(Function() listener) {
    completionListener.add(listener);
  }

  void removeCompletionListener(Function() listener) {
    completionListener.remove(listener);
  }

  void onComplete() {
    _isPlaying = false;
    _currentFilePath = "";
    for (var listener in completionListener) {
      listener();
    }
  }
}