import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:voice_recorder/recorder/dataModel/record_item.dart';
import 'package:voice_recorder/utils/my_audio_player.dart';


// ignore: must_be_immutable
class ListItemRecordHistory extends StatefulWidget {
  final RecordItem recordItem;
  bool isExpanded = false;
  bool isPlaying = false;
  final Function(RecordItem) onPlayAudio;
  final Function() onStopAudio;
  final Function(String, bool) onExpanded;
  final Function(RecordItem) onPause;
  ListItemRecordHistory({
    Key? key, 
    required this.isExpanded, 
    required this.isPlaying,
    required this.recordItem, 
    required this.onPlayAudio, 
    required this.onStopAudio,
    required this.onExpanded,
    required this.onPause}) : super(key: key);
  @override
  _ListItemRecordHistoryState createState() => _ListItemRecordHistoryState();

}
class _ListItemRecordHistoryState extends State<ListItemRecordHistory> {
  MyAudioPlayer _player = MyAudioPlayer();
  Duration _duration = Duration.zero;
  @override
  void initState() {
    super.initState();
    _player.onAudioDurationChanged.listen((event) {
      if (widget.recordItem.path == _player.currentFilePath) {
        setState(() {
          _duration = event;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String keyString = '${widget.recordItem.path}_${widget.isExpanded}';  
    return Card(child:
      ExpansionTile(
        key: Key(keyString),
        initiallyExpanded: widget.isExpanded,
        title: Text(widget.recordItem.title),
        leading: widget.isExpanded? null : IconButton(
          icon: Icon(widget.isPlaying ? Icons.stop : Icons.play_arrow,),
          onPressed: () => {
            _onPlayButtonClick()
          },
          iconSize: 40,
        ),
        onExpansionChanged: (expanded) {
          setState(() {
            widget.onExpanded(widget.recordItem.path, expanded);
          });
        },
        children: [
          _audioProgressBar(),
          _controllerButtons(),
        ],
      ), 
    );
  }

  void _onPlayButtonClick() async{
    if (widget.isPlaying) {
      widget.onStopAudio();
    } else {
      widget.onPlayAudio(widget.recordItem);
      widget.onExpanded(widget.recordItem.path, true);
    }
  }

  void _onPauseButtonClick() async {
    if (widget.isPlaying) {
      widget.onPause(widget.recordItem);
    }
  }

  Widget _audioProgressBar() {
    return StreamBuilder<Duration>(
      stream: _player.onAudioPositionChanged,
      builder: ((context, snPosition) {
        var position = snPosition.data ?? Duration.zero;
        if (widget.recordItem.path != _player.currentFilePath) {
          position = Duration.zero;
        }
        return Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child:ProgressBar(
          progress: Duration(milliseconds: position.inMilliseconds),
          total: Duration(milliseconds: _duration.inMilliseconds),
          onSeek: (duration) {
            _player.seek(duration);
          },
      ));
      }) ,
    );

  }

  Widget _controllerButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //初めに戻るボタン
        IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed: () => {},
          iconSize: 40,
        ),
        //再生/stopボタン
        IconButton(
          icon: Icon((widget.isPlaying)?Icons.pause:Icons.play_arrow),
          onPressed: () => {(widget.isPlaying)?_onPauseButtonClick():_onPlayButtonClick()},
          iconSize: 40,
        ),
        //次に進むボタン
        IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: () => {},
          iconSize: 40,
        ),
      ],
    );
  }
}