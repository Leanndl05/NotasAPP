import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/checklist_item.dart';
import '../models/note_model.dart';

class NotesService {
  static const String _storageKey = 'user_notes_list';
  static const String _initKey = 'app_has_initial_data';

  Future<List<NoteModel>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasInit = prefs.getBool(_initKey) ?? false;

    if (!hasInit) {
      // Create initial sample notes
      final initialNotes = _getInitialSampleNotes();
      await saveNotes(initialNotes);
      await prefs.setBool(_initKey, true);
      return initialNotes;
    }

    final String? notesJson = prefs.getString(_storageKey);
    if (notesJson == null || notesJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(notesJson) as List<dynamic>;
      return decoded
          .map((item) => NoteModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveNotes(List<NoteModel> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList =
        notes.map((n) => n.toJson()).toList();
    final String encoded = jsonEncode(jsonList);
    return await prefs.setString(_storageKey, encoded);
  }

  List<NoteModel> _getInitialSampleNotes() {
    final now = DateTime.now();
    return [
      NoteModel(
        id: 'sample-1',
        title: '¡Bienvenido a tu bloc de notas! 📝',
        content:
            'Esta aplicación te permite organizar tus ideas fácilmente.\n\n'
            '• Crea notas de texto libre.\n'
            '• Diseña listas de tareas (checklists).\n'
            '• Cambia el color de cada nota para organizarte mejor.\n'
            '• Edita o borra en cualquier momento.',
        colorValue: 0xFFFFF176, // Amarillo pastel
        isPinned: true,
        createdAt: now.subtract(const Duration(minutes: 30)),
        updatedAt: now.subtract(const Duration(minutes: 30)),
      ),
      NoteModel(
        id: 'sample-2',
        title: 'Lista de compras 🛒',
        content: 'Recordar llevar bolsa ecológica.',
        checklist: [
          const ChecklistItem(id: 'c1', text: 'Leche y huevos', isDone: true),
          const ChecklistItem(id: 'c2', text: 'Café en grano', isDone: true),
          const ChecklistItem(id: 'c3', text: 'Frutas (manzanas, plátanos)', isDone: false),
          const ChecklistItem(id: 'c4', text: 'Pan integral', isDone: false),
          const ChecklistItem(id: 'c5', text: 'Yogur natural', isDone: false),
        ],
        colorValue: 0xFFAED581, // Verde claro
        isPinned: false,
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      NoteModel(
        id: 'sample-3',
        title: 'Ideas para el proyecto 🚀',
        content:
            'Diseñar una interfaz limpia e intuitiva, accesible para Android e iOS.',
        checklist: [
          const ChecklistItem(id: 'i1', text: 'Definir paleta de colores', isDone: true),
          const ChecklistItem(id: 'i2', text: 'Crear componente de checklist', isDone: true),
          const ChecklistItem(id: 'i3', text: 'Habilitar cambio de colores dinámico', isDone: false),
        ],
        colorValue: 0xFF90CAF9, // Celeste pastel
        isPinned: false,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}
