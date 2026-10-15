import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/checklist_item.dart';
import '../../models/note_model.dart';
import 'widgets/checklist_editor.dart';
import 'widgets/color_picker_sheet.dart';

class NoteEditorScreen extends StatefulWidget {
  final NoteModel? note;
  final ValueChanged<NoteModel> onSave;
  final VoidCallback? onDelete;

  const NoteEditorScreen({
    super.key,
    this.note,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late List<ChecklistItem> _checklist;
  late int _currentColorValue;
  late bool _isPinned;
  late final DateTime _createdAt;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    _titleController = TextEditingController(text: note?.title ?? '');
    _contentController = TextEditingController(text: note?.content ?? '');
    _checklist = note != null ? List<ChecklistItem>.from(note.checklist) : [];
    _currentColorValue = note?.colorValue ?? AppColors.defaultColorValue;
    _isPinned = note?.isPinned ?? false;
    _createdAt = note?.createdAt ?? DateTime.now();

    _titleController.addListener(_markChanged);
    _contentController.addListener(_markChanged);
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  void _saveAndExit() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    // If note is completely empty and wasn't previously created, do not save
    if (title.isEmpty && content.isEmpty && _checklist.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final note = NoteModel(
      id: widget.note?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      content: content,
      checklist: _checklist,
      colorValue: _currentColorValue,
      isPinned: _isPinned,
      createdAt: _createdAt,
      updatedAt: DateTime.now(),
    );

    widget.onSave(note);
    Navigator.of(context).pop();
  }

  void _openColorPicker() {
    ColorPickerSheet.show(
      context,
      currentColorValue: _currentColorValue,
      onColorSelected: (newColor) {
        setState(() {
          _currentColorValue = newColor;
          _hasChanges = true;
        });
      },
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar nota?'),
        content: const Text('Esta acción eliminará la nota de forma permanente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.15),
              foregroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      widget.onDelete?.call();
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        AppColors.getBackgroundColor(_currentColorValue, isDark);
    final textColor = AppColors.getTextColor(backgroundColor, isDark);
    final subtitleColor = AppColors.getSubtitleColor(backgroundColor, isDark);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _saveAndExit();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        color: backgroundColor,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
              tooltip: 'Volver y guardar',
              onPressed: _saveAndExit,
            ),
            actions: [
              // Pin toggle
              IconButton(
                icon: Icon(
                  _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: _isPinned
                      ? Theme.of(context).colorScheme.primary
                      : textColor,
                ),
                tooltip: _isPinned ? 'Desfijar' : 'Fijar nota',
                onPressed: () {
                  setState(() {
                    _isPinned = !_isPinned;
                    _hasChanges = true;
                  });
                },
              ),

              // Color picker
              IconButton(
                icon: Icon(Icons.palette_outlined, color: textColor),
                tooltip: 'Cambiar color',
                onPressed: _openColorPicker,
              ),

              // Delete button (only if editing existing note)
              if (widget.note != null && widget.onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: textColor),
                  tooltip: 'Eliminar nota',
                  onPressed: _confirmDelete,
                ),

              // Save button
              IconButton(
                icon: Icon(Icons.check_rounded, color: textColor, size: 28),
                tooltip: 'Guardar',
                onPressed: _saveAndExit,
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title TextField
                  TextField(
                    controller: _titleController,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Título de la nota...',
                      hintStyle: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: subtitleColor.withValues(alpha: 0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),

                  const SizedBox(height: 12),
                  Divider(
                    color: textColor.withValues(alpha: 0.1),
                    height: 1,
                  ),
                  const SizedBox(height: 16),

                  // Content TextField (Free writing)
                  TextField(
                    controller: _contentController,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: textColor,
                    ),
                    maxLines: null,
                    minLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu nota aquí...',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: subtitleColor.withValues(alpha: 0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),

                  const SizedBox(height: 24),
                  Divider(
                    color: textColor.withValues(alpha: 0.1),
                    height: 1,
                  ),
                  const SizedBox(height: 16),

                  // Checklist Editor Section
                  ChecklistEditor(
                    items: _checklist,
                    textColor: textColor,
                    onChanged: (updatedList) {
                      setState(() {
                        _checklist = updatedList;
                        _hasChanges = true;
                      });
                    },
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                top: BorderSide(
                  color: textColor.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add_task_rounded, color: textColor),
                  tooltip: 'Añadir tarea a la lista',
                  onPressed: () {
                    final newItem = ChecklistItem(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      text: '',
                      isDone: false,
                    );
                    setState(() {
                      _checklist.add(newItem);
                      _hasChanges = true;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.palette_outlined, color: textColor),
                  tooltip: 'Color de fondo',
                  onPressed: _openColorPicker,
                ),
                const Spacer(),
                Text(
                  widget.note == null ? 'Nueva nota' : 'Editando nota',
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
