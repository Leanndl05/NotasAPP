import 'dart:async';
import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../models/user_model.dart';
import '../services/firestore_notes_service.dart';

class NotesController extends ChangeNotifier {
  final FirestoreNotesService _firestoreService;
  StreamSubscription<List<NoteModel>>? _notesSubscription;

  AppUser? _user;
  List<NoteModel> _notes = [];
  bool _isLoading = false;
  String _searchQuery = '';
  int? _selectedColorFilter;
  bool _isGridView = true;

  NoteModel? _lastDeletedNote;
  int? _lastDeletedIndex;

  NotesController({
    FirestoreNotesService? firestoreService,
    AppUser? initialUser,
  }) : _firestoreService = firestoreService ?? FirestoreNotesService() {
    if (initialUser != null) {
      setUser(initialUser);
    }
  }

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  int? get selectedColorFilter => _selectedColorFilter;
  bool get isGridView => _isGridView;
  List<NoteModel> get allNotes => _notes;
  String? get firestoreError => _firestoreService.lastError;
  bool get isFirebaseAvailable => _firestoreService.isFirebaseAvailable;

  List<NoteModel> get filteredNotes {
    final query = _searchQuery.trim().toLowerCase();

    final result = _notes.where((note) {
      final matchesColor = _selectedColorFilter == null ||
          note.colorValue == _selectedColorFilter;

      if (!matchesColor) return false;

      if (query.isEmpty) return true;

      final titleMatch = note.title.toLowerCase().contains(query);
      final contentMatch = note.content.toLowerCase().contains(query);
      final checklistMatch = note.checklist.any(
        (item) => item.text.toLowerCase().contains(query),
      );

      return titleMatch || contentMatch || checklistMatch;
    }).toList();

    // Sort: pinned first, then by updatedAt descending
    result.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return result;
  }

  Future<void> setUser(AppUser? user) async {
    _notesSubscription?.cancel();
    _notesSubscription = null;
    _user = user;

    if (user == null) {
      _notes = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.initialize();
      _notes = await _firestoreService.loadNotes(user.uid);
      notifyListeners();

      // Listen to real-time updates from Firestore if available
      if (_firestoreService.isFirebaseAvailable) {
        _notesSubscription = _firestoreService.streamNotes(user.uid).listen(
          (updatedNotes) {
            _notes = updatedNotes;
            notifyListeners();
          },
          onError: (_) {},
        );
      }
    } catch (_) {
      _notes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote(NoteModel note) async {
    if (_user == null) return;
    _notes.insert(0, note);
    notifyListeners();
    await _firestoreService.saveNote(_user!.uid, note);
  }

  Future<void> updateNote(NoteModel updatedNote) async {
    if (_user == null) return;
    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote.copyWith(updatedAt: DateTime.now());
      notifyListeners();
      await _firestoreService.saveNote(_user!.uid, _notes[index]);
    }
  }

  Future<void> deleteNote(String id) async {
    if (_user == null) return;
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _lastDeletedNote = _notes[index];
      _lastDeletedIndex = index;
      _notes.removeAt(index);
      notifyListeners();
      await _firestoreService.deleteNote(_user!.uid, id);
    }
  }

  Future<void> undoDelete() async {
    if (_user == null || _lastDeletedNote == null) return;
    final index = (_lastDeletedIndex != null &&
            _lastDeletedIndex! <= _notes.length)
        ? _lastDeletedIndex!
        : 0;
    final noteToRestore = _lastDeletedNote!;
    _notes.insert(index, noteToRestore);
    _lastDeletedNote = null;
    _lastDeletedIndex = null;
    notifyListeners();
    await _firestoreService.saveNote(_user!.uid, noteToRestore);
  }

  Future<void> changeNoteColor(String id, int colorValue) async {
    if (_user == null) return;
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        colorValue: colorValue,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      await _firestoreService.updateNoteColor(_user!.uid, id, colorValue);
    }
  }

  Future<void> togglePin(String id) async {
    if (_user == null) return;
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        isPinned: !_notes[index].isPinned,
      );
      notifyListeners();
      await _firestoreService.saveNote(_user!.uid, _notes[index]);
    }
  }

  Future<void> toggleChecklistItem(String noteId, String itemId) async {
    if (_user == null) return;
    final noteIndex = _notes.indexWhere((n) => n.id == noteId);
    if (noteIndex != -1) {
      final note = _notes[noteIndex];
      final updatedChecklist = note.checklist.map((item) {
        if (item.id == itemId) {
          return item.copyWith(isDone: !item.isDone);
        }
        return item;
      }).toList();

      _notes[noteIndex] = note.copyWith(
        checklist: updatedChecklist,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      await _firestoreService.saveNote(_user!.uid, _notes[noteIndex]);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setColorFilter(int? colorValue) {
    if (_selectedColorFilter == colorValue) {
      _selectedColorFilter = null;
    } else {
      _selectedColorFilter = colorValue;
    }
    notifyListeners();
  }

  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  @override
  void dispose() {
    _notesSubscription?.cancel();
    super.dispose();
  }
}
