import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voice_recorder/src/recorder/dataModel/record_item.dart';
import 'package:voice_recorder/src/recorder/provider/record_item_list_controller.dart';
import 'package:voice_recorder/src/recorder/widget/list_item_record_history.dart';

class RecorderFragment extends StatefulWidget {
  @override
  RecorderFragmentState createState() => RecorderFragmentState();
}

class RecorderFragmentState extends State<RecorderFragment> {
  final _controller = Get.put(RecordItemListController());
  String? _expandedItemPath;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Expanded(
        child: Container(
            color: Colors.grey[200],
            child: ListView.builder(
              shrinkWrap: true,
              // key: Key('builder {$expandedItemPath}'),
              itemCount: _controller.recordItemList.length,
              itemBuilder: (context, index) {
                RecordItem item = _controller.recordItemList[index];
                return ListItemRecordHistory(
                    isExpanded: _expandedItemPath == item.path,
                    recordItem: item,
                    onExpanded: _onExpandedItem);
              },
            ))));
  }

  void _onExpandedItem(String path, bool isExpanded) {
    if (_expandedItemPath == null) {
      setState(() {
        _expandedItemPath = path;
      });
    } else if (_expandedItemPath == path && !isExpanded) {
      setState(() {
        _expandedItemPath = null;
      });
    } else if (_expandedItemPath != path && isExpanded) {
      setState(() {
        _expandedItemPath = path;
      });
    }
  }
}
