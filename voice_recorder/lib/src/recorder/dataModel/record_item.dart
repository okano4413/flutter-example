class RecordItem {
  final int id;
  final String title;
  final String path;
  final Duration? duration;
  final int createTimestamp;
  final int updateTimestamp;
  RecordItem(this.id, this.path,this.title, {this.duration, required this.createTimestamp, required this.updateTimestamp});

  factory RecordItem.fromMap(Map<String, dynamic> json) {
    return RecordItem(
      json['id'],
      json['file_path'],
      json['title'],
      createTimestamp: int.parse(json['created_at']),
      updateTimestamp: int.parse(json['updated_at']),
    );
  }
}