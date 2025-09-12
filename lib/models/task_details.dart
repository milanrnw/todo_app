class TaskDetails {
  late final String? id;
  final String title;
  final String description;
  bool isDone;

  TaskDetails({
    required this.id,
    required this.title,
    required this.description,
    this.isDone = false,
  });

  factory TaskDetails.fromJson(Map<String, dynamic> json) => TaskDetails(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        isDone: json["isDone"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "isDone": isDone,
      };
}
