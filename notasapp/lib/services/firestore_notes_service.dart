import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/checklist_item.dart';
import '../models/note_model.dart';

class FirestoreNotesService {
  FirebaseFirestore? _firestore;
  bool _isFirebaseAvailable = false;
  String? _lastError;

  bool get isFirebaseAvailable => _isFirebaseAvailable;
  String? get lastError => _lastError;

  Future<void> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _firestore = FirebaseFirestore.instance;
        _isFirebaseAvailable = true;
        _lastError = null;
        debugPrint('🔥 [Firebase] Firestore inicializado correctamente con la app: ${Firebase.app().name}');
      } else {
        _isFirebaseAvailable = false;
        _lastError = 'Firebase no está inicializado en esta plataforma.';
        debugPrint('⚠️ [Firebase] Firebase.apps está vacío. Se utilizará almacenamiento local.');
      }
    } catch (e) {
      _isFirebaseAvailable = false;
      _lastError = e.toString();
      debugPrint('❌ [Firebase] Error inicializando Firestore: $e');
    }
  }

  CollectionReference<Map<String, dynamic>>? _notesCollection(String userId) {
    if (!_isFirebaseAvailable || _firestore == null) return null;
    return _firestore!.collection('users').doc(userId).collection('notes');
  }

  String _localKey(String userId) => 'user_notes_$userId';

  // Real-time stream of notes for the specific user
  Stream<List<NoteModel>> streamNotes(String userId) {
    final collection = _notesCollection(userId);

    if (collection != null) {
      return collection.snapshots().map((snapshot) {
        debugPrint('🔥 [Firestore] Recibidas ${snapshot.docs.length} notas en tiempo real para $userId');
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return NoteModel.fromJson(data);
        }).toList();
      }).handleError((error) {
        _lastError = error.toString();
        debugPrint('❌ [Firestore Stream Error]: $error');
      });
    } else {
      // Local stream fallback
      return Stream.fromFuture(loadNotesLocal(userId));
    }
  }

  Future<List<NoteModel>> loadNotes(String userId) async {
    final collection = _notesCollection(userId);

    if (collection != null) {
      try {
        debugPrint('🔥 [Firestore] Cargando notas de la nube para $userId...');
        final snapshot = await collection.get();
        _lastError = null;
        if (snapshot.docs.isEmpty) {
          // Check local cache first, or seed initial notes
          final local = await loadNotesLocal(userId);
          if (local.isNotEmpty) {
            for (final note in local) {
              await saveNote(userId, note);
            }
            return local;
          }
          final initial = _getInitialUserNotes();
          for (final note in initial) {
            await saveNote(userId, note);
          }
          return initial;
        }
        final notes = snapshot.docs.map((d) => NoteModel.fromJson(d.data())).toList();
        await _persistLocalList(userId, notes);
        return notes;
      } catch (e) {
        _lastError = e.toString();
        debugPrint('❌ [Firestore get Error]: $e');
        return await loadNotesLocal(userId);
      }
    } else {
      return await loadNotesLocal(userId);
    }
  }

  Future<void> saveNote(String userId, NoteModel note) async {
    // 1. Save to Cloud Firestore
    final collection = _notesCollection(userId);
    if (collection != null) {
      try {
        debugPrint('🔥 [Firestore] Subiendo nota a users/$userId/notes/${note.id}');
        await collection.doc(note.id).set(note.toJson(), SetOptions(merge: true));
        _lastError = null;
        debugPrint('✅ [Firestore] Nota guardada con éxito en Firestore');
      } catch (e) {
        _lastError = e.toString();
        debugPrint('❌ [Firestore saveNote Error]: $e');
      }
    } else {
      debugPrint('⚠️ [Firestore] Colección no disponible. Guardando únicamente en caché local.');
    }

    // 2. Also save to local cache for offline access
    await _saveToLocalCache(userId, note);
  }

  Future<void> deleteNote(String userId, String noteId) async {
    // 1. Delete from Cloud Firestore
    final collection = _notesCollection(userId);
    if (collection != null) {
      try {
        debugPrint('🔥 [Firestore] Eliminando nota users/$userId/notes/$noteId');
        await collection.doc(noteId).delete();
        _lastError = null;
      } catch (e) {
        _lastError = e.toString();
        debugPrint('❌ [Firestore deleteNote Error]: $e');
      }
    }

    // 2. Delete from local cache
    final notes = await loadNotesLocal(userId);
    notes.removeWhere((n) => n.id == noteId);
    await _persistLocalList(userId, notes);
  }

  Future<void> updateNoteColor(String userId, String noteId, int colorValue) async {
    final collection = _notesCollection(userId);
    if (collection != null) {
      try {
        debugPrint('🔥 [Firestore] Actualizando color en users/$userId/notes/$noteId');
        await collection.doc(noteId).update({
          'colorValue': colorValue,
          'updatedAt': DateTime.now().toIso8601String(),
        });
        _lastError = null;
      } catch (e) {
        _lastError = e.toString();
        debugPrint('❌ [Firestore updateNoteColor Error]: $e');
      }
    }

    final notes = await loadNotesLocal(userId);
    final index = notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      notes[index] = notes[index].copyWith(
        colorValue: colorValue,
        updatedAt: DateTime.now(),
      );
      await _persistLocalList(userId, notes);
    }
  }

  // --- Local storage helpers per user ---

  Future<List<NoteModel>> loadNotesLocal(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_localKey(userId));

    if (jsonStr == null || jsonStr.isEmpty) {
      final initialNotes = _getInitialUserNotes();
      await _persistLocalList(userId, initialNotes);
      return initialNotes;
    }

    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((e) => NoteModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveToLocalCache(String userId, NoteModel note) async {
    final notes = await loadNotesLocal(userId);
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notes[index] = note;
    } else {
      notes.insert(0, note);
    }
    await _persistLocalList(userId, notes);
  }

  Future<void> _persistLocalList(String userId, List<NoteModel> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = notes.map((n) => n.toJson()).toList();
    await prefs.setString(_localKey(userId), jsonEncode(jsonList));
  }

  List<NoteModel> _getInitialUserNotes() {
    final now = DateTime.now();
    return [
      NoteModel(
        id: 'welcome-${now.millisecondsSinceEpoch}',
        title: '¡Tu espacio personal en la nube! ☁️',
        content: 'Tus notas se guardan de forma segura y separada para tu usuario.\n\n'
            '• Accede desde cualquier celular con tu cuenta.\n'
            '• Escribe notas y organiza tareas con checklist.\n'
            '• Cambia de color tus notas para distinguirlas rápido.',
        colorValue: 0xFFFFF176, // Amarillo
        isPinned: true,
        checklist: [
          const ChecklistItem(id: 'c1', text: 'Crear mi primera nota personal', isDone: false),
          const ChecklistItem(id: 'c2', text: 'Probar cambiar de color', isDone: false),
        ],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
