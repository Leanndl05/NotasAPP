import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/note_model.dart';
import 'color_picker_sheet.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;
  final ValueChanged<int> onColorChanged;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
    required this.onTogglePin,
    required this.onColorChanged,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes}m';
    }

    final hour = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');

    if (difference.inDays < 1 && now.day == date.day) {
      return '$hour:$min';
    }

    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    final month = months[date.month - 1];

    if (now.year == date.year) {
      return '${date.day} $month, $hour:$min';
    } else {
      return '${date.day} $month ${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = AppColors.getBackgroundColor(note.colorValue, isDark);
    final textColor = AppColors.getTextColor(cardBgColor, isDark);
    final subtitleColor = AppColors.getSubtitleColor(cardBgColor, isDark);
    final isDefaultColor = note.colorValue == AppColors.defaultColorValue;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: cardBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDefaultColor
              ? (isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.1))
              : Colors.black.withValues(alpha: 0.06),
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Title & Pin
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title.isNotEmpty ? note.title : 'Sin título',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: note.title.isNotEmpty
                            ? textColor
                            : textColor.withValues(alpha: 0.5),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isPinned)
                    IconButton(
                      icon: const Icon(Icons.push_pin, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      color: Theme.of(context).colorScheme.primary,
                      tooltip: 'Desfijar',
                      onPressed: onTogglePin,
                    ),
                ],
              ),

              // Content snippet
              if (note.content.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  note.content,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: subtitleColor,
                    height: 1.35,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Checklist preview snippet
              if (note.checklist.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 14,
                            color: subtitleColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${note.completedChecklistCount}/${note.totalChecklistCount} completados',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ...note.checklist.take(3).map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 1.5),
                          child: Row(
                            children: [
                              Icon(
                                item.isDone
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                size: 13,
                                color: item.isDone ? Colors.green : subtitleColor,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.text,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: item.isDone
                                        ? subtitleColor.withValues(alpha: 0.6)
                                        : textColor,
                                    decoration: item.isDone
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (note.checklist.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            '+ ${note.checklist.length - 3} más...',
                            style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: subtitleColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Bottom card bar: Date and Quick Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _formatDate(note.updatedAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: subtitleColor.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Change color button directly on the card
                      IconButton(
                        icon: const Icon(Icons.palette_outlined, size: 18),
                        tooltip: 'Cambiar color',
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 30, minHeight: 30),
                        color: subtitleColor,
                        onPressed: () {
                          ColorPickerSheet.show(
                            context,
                            currentColorValue: note.colorValue,
                            onColorSelected: onColorChanged,
                          );
                        },
                      ),
                      // Delete note button
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        tooltip: 'Eliminar nota',
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 30, minHeight: 30),
                        color: subtitleColor,
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
