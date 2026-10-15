import 'package:flutter_test/flutter_test.dart';
import 'package:notasapp/controllers/notes_controller.dart';
import 'package:notasapp/main.dart';
import 'package:notasapp/models/checklist_item.dart';
import 'package:notasapp/models/note_model.dart';
import 'package:notasapp/models/user_model.dart';
import 'package:notasapp/services/firestore_notes_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFirestoreNotesService extends FirestoreNotesService {
  final Map<String, List<NoteModel>> userStorage = {};

  @override
  Future<void> initialize() async {}

  @override
  bool get isFirebaseAvailable => false;

  @override
  Future<List<NoteModel>> loadNotes(String userId) async {
    return List.from(userStorage[userId] ?? []);
  }

  @override
  Future<void> saveNote(String userId, NoteModel note) async {
    final list = userStorage.putIfAbsent(userId, () => []);
    final idx = list.indexWhere((n) => n.id == note.id);
    if (idx != -1) {
      list[idx] = note;
    } else {
      list.insert(0, note);
    }
  }

  @override
  Future<void> deleteNote(String userId, String noteId) async {
    userStorage[userId]?.removeWhere((n) => n.id == noteId);
  }

  @override
  Future<void> updateNoteColor(String userId, String noteId, int colorValue) async {
    final list = userStorage[userId];
    if (list != null) {
      final idx = list.indexWhere((n) => n.id == noteId);
      if (idx != -1) {
        list[idx] = list[idx].copyWith(colorValue: colorValue);
      }
    }
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('User Separation and NotesController Unit Tests', () {
    test('User 1 notes are strictly separated from User 2 notes', () async {
      final mockService = MockFirestoreNotesService();
      final controller = NotesController(firestoreService: mockService);

      const user1 = AppUser(uid: 'user_1', email: 'user1@test.com');
      const user2 = AppUser(uid: 'user_2', email: 'user2@test.com');

      // User 1 logs in and adds a note
      await controller.setUser(user1);
      final noteUser1 = NoteModel(
        id: 'n1',
        title: 'Nota de Usuario 1',
        content: 'Privado de User 1',
        colorValue: 0xFFFFF176,
      );
      await controller.addNote(noteUser1);
      expect(controller.allNotes.length, 1);
      expect(controller.allNotes.first.title, 'Nota de Usuario 1');

      // User 2 logs in -> cannot see User 1 notes
      await controller.setUser(user2);
      expect(controller.allNotes.length, 0);

      // User 2 creates their own note
      final noteUser2 = NoteModel(
        id: 'n2',
        title: 'Nota de Usuario 2',
        content: 'Checklist de User 2',
        checklist: [
          const ChecklistItem(id: 'c1', text: 'Tarea de U2', isDone: false),
        ],
        colorValue: 0xFFAED581,
      );
      await controller.addNote(noteUser2);
      expect(controller.allNotes.length, 1);
      expect(controller.allNotes.first.title, 'Nota de Usuario 2');

      // User 1 logs back in -> sees only their note
      await controller.setUser(user1);
      expect(controller.allNotes.length, 1);
      expect(controller.allNotes.first.title, 'Nota de Usuario 1');
      expect(controller.allNotes.first.content, 'Privado de User 1');
    });

    test('Checklist toggle and color changes persist', () async {
      final mockService = MockFirestoreNotesService();
      final controller = NotesController(firestoreService: mockService);
      const user = AppUser(uid: 'user_123', email: 'test@example.com');
      await controller.setUser(user);

      final note = NoteModel(
        id: 'note_abc',
        title: 'Lista de compras',
        checklist: [
          const ChecklistItem(id: 'item_1', text: 'Comprar manzanas', isDone: false),
        ],
        colorValue: 0xFFFFF176,
      );
      await controller.addNote(note);

      // Change color
      await controller.changeNoteColor('note_abc', 0xFF90CAF9);
      expect(controller.allNotes.first.colorValue, 0xFF90CAF9);

      // Toggle checklist item
      await controller.toggleChecklistItem('note_abc', 'item_1');
      expect(controller.allNotes.first.checklist.first.isDone, true);
    });
  });

  group('Widget Tests: Login and Navigation', () {
    testWidgets('Shows Login screen when not authenticated', (tester) async {
      await tester.pumpWidget(const NotasApp());
      await tester.pumpAndSettle();

      // Verify Login Screen elements
      expect(find.text('Notas App'), findsOneWidget);
      // "Iniciar Sesión" appears in the tab header and in the submit button
      expect(find.text('Iniciar Sesión'), findsNWidgets(2));
      expect(find.text('Registrarse'), findsOneWidget);
      expect(find.text('Correo Electrónico'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Acceso rápido sin registro (Modo Demo)'), findsOneWidget);
    });

    testWidgets('Tapping Demo login navigates to HomeScreen with Mis Notas', (tester) async {
      await tester.pumpWidget(const NotasApp());
      await tester.pumpAndSettle();

      // Ensure button is visible in scrollview then tap
      final demoButton = find.text('Acceso rápido sin registro (Modo Demo)');
      await tester.ensureVisible(demoButton);
      await tester.tap(demoButton);
      await tester.pumpAndSettle();

      // Verify HomeScreen is now displayed
      expect(find.text('Mis Notas'), findsOneWidget);
      expect(find.text('Nueva Nota'), findsOneWidget);
    });
  });
}
