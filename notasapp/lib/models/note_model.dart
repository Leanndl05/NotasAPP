import '../constants/app_colors.dart';
import 'checklist_item.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final List<ChecklistItem> checklist;
  final int colorValue;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteModel({
    required this.id,
    this.title = '',
    this.content = '',
    List<ChecklistItem>? checklist,
    this.colorValue = AppColors.defaultColorValue,
    this.isPinned = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : checklist = checklist ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isEmpty =>
      title.trim().isEmpty && content.trim().isEmpty && checklist.isEmpty;

  int get totalChecklistCount => checklist.length;

  int get completedChecklistCount =>
      checklist.where((item) => item.isDone).length;

  double get checklistProgress =>
      totalChecklistCount == 0 ? 0 : completedChecklistCount / totalChecklistCount;

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    List<ChecklistItem>? checklist,
    int? colorValue,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      checklist: checklist ?? List.from(this.checklist),
      colorValue: colorValue ?? this.colorValue,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'checklist': checklist.map((item) => item.toJson()).toList(),
      'colorValue': colorValue,
      'isPinned': isPinned,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      checklist: (json['checklist'] as List<dynamic>?)
              ?.map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      colorValue: json['colorValue'] as int? ?? AppColors.defaultColorValue,
      isPinned: json['isPinned'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
