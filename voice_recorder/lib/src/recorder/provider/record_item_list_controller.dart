import 'package:get/get.dart';
import 'package:voice_recorder/src/database/db.dart';
import 'package:voice_recorder/src/recorder/dataModel/record_item.dart';

class RecordItemListController extends GetxController {
  final _recordItemList = <RecordItem>[].obs;
  List<RecordItem> get recordItemList => _recordItemList.toList();
  MyDatabase? _database;

  @override
  void onInit() {
    super.onInit();
    _loadRecordItemList();
  }

  void _loadRecordItemList() async {
    _database ??= await MyDatabase.getInstance();
    final recordItemList = await _database!.getRecords();
    _recordItemList.value = recordItemList;
  }

  Future<int> addRecordItem(String path, String title) async {
    int id = await _database!.insertRecord(path, title);
    _loadRecordItemList();
    return id;
  }

  void removeRecordItem(RecordItem recordItem) async {
    await _database!.deleteRecord(recordItem.id);
    _recordItemList.remove(recordItem);
  }
}
