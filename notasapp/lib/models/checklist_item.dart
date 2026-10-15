class ChecklistItem {
  final String id;
  final String text;
  final bool isDone;

  const ChecklistItem({
    required this.id,
    required this.text,
    this.isDone = false,
  });

  ChecklistItem copyWith({
    String? id,
    String? text,
    bool? isDone,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isDone': isDone,
    };
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      text: json['text'] as String? ?? '',
      isDone: json['isDone'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChecklistItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          isDone == other.isDone;

  @override
  int get hashCode => id.hashCode ^ text.hashCode ^ isDone.hashCode;
}
