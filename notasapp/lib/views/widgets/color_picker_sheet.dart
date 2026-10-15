import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class ColorPickerSheet extends StatelessWidget {
  final int currentColorValue;
  final ValueChanged<int> onColorSelected;

  const ColorPickerSheet({
    super.key,
    required this.currentColorValue,
    required this.onColorSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required int currentColorValue,
    required ValueChanged<int> onColorSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ColorPickerSheet(
        currentColorValue: currentColorValue,
        onColorSelected: onColorSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242731) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.palette_outlined, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Elige un color para la nota',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppColors.noteColors.map((colorOption) {
                final isSelected = currentColorValue == colorOption.value;
                final displayColor = isDark
                    ? colorOption.darkColor
                    : colorOption.lightColor;
                final isDefault = colorOption.value == AppColors.defaultColorValue;

                return GestureDetector(
                  onTap: () {
                    onColorSelected(colorOption.value);
                    Navigator.pop(context);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: displayColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : (isDefault
                                    ? Colors.grey.withValues(alpha: 0.4)
                                    : Colors.transparent),
                            width: isSelected ? 3 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 24,
                                color: AppColors.getTextColor(displayColor, isDark),
                              )
                            : (isDefault
                                ? Icon(
                                    Icons.format_color_reset_outlined,
                                    size: 20,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  )
                                : null),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        colorOption.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
