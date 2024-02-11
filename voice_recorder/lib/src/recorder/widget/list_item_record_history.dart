import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voice_recorder/src/recorder/dataModel/record_item.dart';
import 'package:voice_recorder/src/recorder/use_case/record_use_case.dart';
import 'package:voice_recorder/src/utils/my_audio_player.dart';

// ignore: must_be_immutable
class ListItemRecordHistory extends StatefulWidget {
  final RecordItem recordItem;
  bool isExpanded = false;
  final Function(String, bool) onExpanded;
  ListItemRecordHistory({
    Key? key,
    required this.isExpanded,
    required this.recordItem,
    required this.onExpanded,
  }) : super(key: key);
  @override
  _ListItemRecordHistoryState createState() => _ListItemRecordHistoryState();
}

class _ListItemRecordHistoryState extends State<ListItemRecordHistory> {
  MyAudioPlayer _player = MyAudioPlayer();
  Duration _duration = Duration.zero;
  final _usecase = Get.put(RecordUseCase());
  @override
  void initState() {
    super.initState();
    _player.onAudioDurationChanged.listen((event) {
      if (!mounted) {
        return;
      }
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
    return Card(child: Obx(() {
      var isPlaying =
          _usecase.currentFile.value?.path == widget.recordItem.path;
      return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: Key(keyString),
            initiallyExpanded: widget.isExpanded,
            title: Text(widget.recordItem.title),
            leading: widget.isExpanded
                ? null
                : IconButton(
                    icon: Icon(
                      isPlaying ? Icons.stop : Icons.play_arrow,
                    ),
                    onPressed: () => {_onPlayButtonClick(isPlaying)},
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
          ));
    }));
  }

  void _onPlayButtonClick(bool isPlaying) async {
    if (isPlaying) {
      _usecase.stopAudio();
    } else {
      _usecase.playAudio(widget.recordItem);
      widget.onExpanded(widget.recordItem.path, true);
    }
  }

  void _onPauseButtonClick(bool isPlaying) async {
    if (isPlaying) {
      _usecase.pauseAudio(widget.recordItem);
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
            child: ProgressBar(
              progress: Duration(milliseconds: position.inMilliseconds),
              total: Duration(milliseconds: _duration.inMilliseconds),
              onSeek: (duration) {
                _player.seek(duration);
              },
            ));
      }),
    );
  }

  Widget _controllerButtons() {
    bool isPlaying = _usecase.isPlayingAudioPath(widget.recordItem.path);
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
          icon: Icon((isPlaying) ? Icons.pause : Icons.play_arrow),
          onPressed: () => {
            (isPlaying)
                ? _onPauseButtonClick(isPlaying)
                : _onPlayButtonClick(isPlaying)
          },
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
