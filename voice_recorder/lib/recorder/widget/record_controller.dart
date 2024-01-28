import 'package:flutter/material.dart';
import 'package:voice_recorder/database/db.dart';
import 'package:voice_recorder/recorder/dataModel/record_item.dart';
import 'package:record/record.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_saver/file_saver.dart';
import 'package:get/get.dart';
import 'package:voice_recorder/recorder/provider/record_item_list_controller.dart';

class RecordController extends StatefulWidget {
  bool isPlaying;
  RecordController({Key? key, this.isPlaying = false}) : super(key: key);

  @override
  _RecordControllerState createState() => _RecordControllerState();
}

class _RecordControllerState extends State<RecordController> {
  var isRecording = false;
  var record = Record();
  // MyDatabase? _database;
  final _controller = Get.put(RecordItemListController());

  @override
  void initState() {
    super.initState();
    // _initDatabase();
  }

  // void _initDatabase() async {
  //   _database ??=  await MyDatabase.getInstance();
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
              child:
                Padding(
                  padding:const EdgeInsets.only(top: 20,bottom: 20),
                  child:ElevatedButton(
                    onPressed:(){
                      if (widget.isPlaying) {
                        return;
                      }
                      if (isRecording) {
                        _stopRecord();
                      } else {
                        _startRecord();
                      }
                    }, 
                    style:ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: (isRecording)?Colors.red:Colors.grey,
                      shape: const CircleBorder(side: BorderSide(color: Colors.white,width: 5)),
                      minimumSize: const Size(100, 100),
                      shadowColor: Colors.black,
                    ),
                    child: const Text(" "),
              ),)
                
              
            );
  }

   void _startRecord() async{
    if (isRecording) return;
    if (await record.hasPermission()) {
      // Start recording
      final path = await filePath;
      await record.start(
        path: path,
        encoder: AudioEncoder.aacLc, // by default
        bitRate: 128000, // by default
        samplingRate: 44100, // by default
      );
      
      setState(() {
        isRecording = true;  
      });
    }
  }

  void _stopRecord() async {
    var outputPath = await record.stop();
    print(outputPath);
    if (outputPath != null)  {
      File file = File(outputPath);
      String title = getCurrentTime();
      String path = await FileSaver.instance.saveFile(
        name:title,
        file:file,
        mimeType: MimeType.aac,
      );
      int id = await _controller.addRecordItem(path, title);
      // int id = await _database!.insertRecord(path, title);
      // RecordItem item = await _database!.getRecord(id);
      // widget.onRecorded(item);
    }

    isRecording = false;
    setState(() {});
  }

  Future<String> get filePath async{
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    var file = File('$path/${DateTime.now().millisecondsSinceEpoch}.aac}');
    return file.path;
  }

  String getCurrentTime() {
    var now = DateTime.now();
    return "${now.year.toString()}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}-${now.hour.toString().padLeft(2,'0')}-${now.minute.toString().padLeft(2,'0')}-${now.second.toString().padLeft(2,'0')}";
  }
}