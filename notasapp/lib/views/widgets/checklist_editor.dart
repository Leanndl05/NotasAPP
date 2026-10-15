import 'package:flutter/material.dart';
import '../../models/checklist_item.dart';

class ChecklistEditor extends StatefulWidget {
  final List<ChecklistItem> items;
  final Color textColor;
  final ValueChanged<List<ChecklistItem>> onChanged;

  const ChecklistEditor({
    super.key,
    required this.items,
    required this.textColor,
    required this.onChanged,
  });

  @override
  State<ChecklistEditor> createState() => _ChecklistEditorState();
}

class _ChecklistEditorState extends State<ChecklistEditor> {
  final TextEditingController _addItemController = TextEditingController();
  final FocusNode _addItemFocusNode = FocusNode();

  void _addItem([String? text]) {
    final value = (text ?? _addItemController.text).trim();
    if (value.isEmpty) return;

    final newItem = ChecklistItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: value,
      isDone: false,
    );

    final updated = List<ChecklistItem>.from(widget.items)..add(newItem);
    widget.onChanged(updated);
    _addItemController.clear();
    _addItemFocusNode.requestFocus();
  }

  void _toggleItem(int index) {
    final updated = List<ChecklistItem>.from(widget.items);
    updated[index] = updated[index].copyWith(isDone: !updated[index].isDone);
    widget.onChanged(updated);
  }

  void _updateItemText(int index, String newText) {
    final updated = List<ChecklistItem>.from(widget.items);
    updated[index] = updated[index].copyWith(text: newText);
    widget.onChanged(updated);
  }

  void _removeItem(int index) {
    final updated = List<ChecklistItem>.from(widget.items)..removeAt(index);
    widget.onChanged(updated);
  }

  @override
  void dispose() {
    _addItemController.dispose();
    _addItemFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.items.length;
    final completed = widget.items.where((i) => i.isDone).length;
    final progress = total > 0 ? completed / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.checklist_rounded,
                  size: 20,
                  color: widget.textColor.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 8),
                Text(
                  'Lista de tareas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.textColor,
                  ),
                ),
              ],
            ),
            if (total > 0)
              Text(
                '$completed / $total',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.textColor.withValues(alpha: 0.7),
                ),
              ),
          ],
        ),

        if (total > 0) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: widget.textColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? Colors.green : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ] else
          const SizedBox(height: 12),

        // List of items
        ...widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Custom check box
                IconButton(
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  icon: Icon(
                    item.isDone
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    color: item.isDone
                        ? Colors.green
                        : widget.textColor.withValues(alpha: 0.7),
                  ),
                  onPressed: () => _toggleItem(index),
                ),
                const SizedBox(width: 4),

                // Item text editor
                Expanded(
                  child: TextFormField(
                    initialValue: item.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: item.isDone
                          ? widget.textColor.withValues(alpha: 0.5)
                          : widget.textColor,
                      decoration: item.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    onChanged: (text) => _updateItemText(index, text),
                  ),
                ),

                // Delete item button
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: widget.textColor.withValues(alpha: 0.5),
                  ),
                  tooltip: 'Eliminar elemento',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () => _removeItem(index),
                ),
              ],
            ),
          );
        }),

        // Quick add item input
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              IconButton(
                iconSize: 22,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: widget.textColor.withValues(alpha: 0.7),
                ),
                onPressed: () => _addItem(),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: _addItemController,
                  focusNode: _addItemFocusNode,
                  style: TextStyle(
                    fontSize: 15,
                    color: widget.textColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Añadir un elemento a la lista...',
                    hintStyle: TextStyle(
                      fontSize: 15,
                      color: widget.textColor.withValues(alpha: 0.45),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (val) => _addItem(val),
                ),
              ),
              if (_addItemController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.arrow_upward_rounded, size: 20),
                  onPressed: () => _addItem(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
