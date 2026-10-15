import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/notes_controller.dart';
import '../../models/note_model.dart';
import 'note_editor_screen.dart';
import 'widgets/note_card.dart';

class HomeScreen extends StatefulWidget {
  final NotesController controller;
  final AuthController? authController;

  const HomeScreen({
    super.key,
    required this.controller,
    this.authController,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openEditor({NoteModel? note}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => NoteEditorScreen(
          note: note,
          onSave: (savedNote) {
            if (note == null) {
              widget.controller.addNote(savedNote);
            } else {
              widget.controller.updateNote(savedNote);
            }
          },
          onDelete: note != null
              ? () {
                  _deleteNoteWithUndo(note);
                }
              : null,
        ),
      ),
    );
  }

  void _deleteNoteWithUndo(NoteModel note) {
    widget.controller.deleteNote(note.id);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nota "${note.title.isNotEmpty ? note.title : 'Sin título'}" eliminada'),
        action: SnackBarAction(
          label: 'DESHACER',
          onPressed: () {
            widget.controller.undoDelete();
          },
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _confirmDeleteCard(NoteModel note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar nota?'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${note.title.isNotEmpty ? note.title : 'esta nota'}"?',
        ),
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
      _deleteNoteWithUndo(note);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final notes = widget.controller.filteredNotes;
        final hasActiveFilter = widget.controller.selectedColorFilter != null ||
            widget.controller.searchQuery.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 2,
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Buscar en títulos, notas o listas...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    onChanged: (val) => widget.controller.setSearchQuery(val),
                  )
                : const Row(
                    children: [
                      Icon(Icons.note_alt_outlined, size: 26),
                      SizedBox(width: 10),
                      Text(
                        'Mis Notas',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
            actions: [
              // Search toggle
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                tooltip: _isSearching ? 'Cerrar búsqueda' : 'Buscar',
                onPressed: () {
                  setState(() {
                    if (_isSearching) {
                      _isSearching = false;
                      _searchController.clear();
                      widget.controller.setSearchQuery('');
                    } else {
                      _isSearching = true;
                    }
                  });
                },
              ),
              // View mode toggle (Grid / List)
              IconButton(
                icon: Icon(
                  widget.controller.isGridView
                      ? Icons.view_agenda_outlined
                      : Icons.grid_view_outlined,
                ),
                tooltip: widget.controller.isGridView
                    ? 'Vista en lista'
                    : 'Vista en cuadrícula',
                onPressed: widget.controller.toggleViewMode,
              ),
              if (widget.authController != null &&
                  widget.authController!.currentUser != null) ...[
                PopupMenuButton<String>(
                  tooltip: 'Mi Cuenta',
                  icon: CircleAvatar(
                    radius: 15,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      widget.authController!.currentUser!.email.isNotEmpty
                          ? widget.authController!.currentUser!.email[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  onSelected: (val) async {
                    if (val == 'logout') {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('¿Cerrar sesión?'),
                          content: Text(
                            'Se cerrará la sesión de ${widget.authController!.currentUser!.email}.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton.tonal(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Cerrar sesión'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        await widget.authController!.logout();
                      }
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Conectado como:',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          Text(
                            widget.authController!.currentUser!.email,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                widget.authController!.isFirebaseAvailable
                                    ? Icons.cloud_done_rounded
                                    : Icons.cloud_off_rounded,
                                size: 14,
                                color: widget.authController!.isFirebaseAvailable
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.authController!.isFirebaseAvailable
                                    ? 'Firebase Cloud Sync'
                                    : 'Modo local sin conexión',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: widget.authController!.isFirebaseAvailable
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout_rounded, size: 20, color: Colors.red),
                          SizedBox(width: 10),
                          Text(
                            'Cerrar sesión',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(width: 4),
            ],
          ),
          body: Column(
            children: [
              // Firestore status banner if there is a sync error
              if (widget.controller.firestoreError != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Aviso Firestore: ${widget.controller.firestoreError}',
                          style: const TextStyle(fontSize: 12, color: Colors.orange),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

              // Color Filter Chips Bar
              _buildColorFilterBar(),

              // Notes Content
              Expanded(
                child: widget.controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : notes.isEmpty
                        ? _buildEmptyState(hasActiveFilter)
                        : _buildNotesList(notes),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openEditor(),
            icon: const Icon(Icons.add),
            label: const Text(
              'Nueva Nota',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorFilterBar() {
    final selectedFilter = widget.controller.selectedColorFilter;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: const Text('Todos'),
              selected: selectedFilter == null,
              onSelected: (_) => widget.controller.setColorFilter(null),
              visualDensity: VisualDensity.compact,
            ),
          ),
          ...AppColors.noteColors.map((colorOption) {
            final isSelected = selectedFilter == colorOption.value;
            final bg = isDark ? colorOption.darkColor : colorOption.lightColor;

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                avatar: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: bg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                ),
                label: Text(colorOption.name),
                selected: isSelected,
                onSelected: (_) =>
                    widget.controller.setColorFilter(colorOption.value),
                visualDensity: VisualDensity.compact,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool hasFilter) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilter
                  ? Icons.search_off_rounded
                  : Icons.sticky_note_2_outlined,
              size: 72,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilter
                  ? 'No se encontraron notas'
                  : 'Aún no tienes notas creadas',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'Intenta buscar con otros términos o cambia el filtro de color.'
                  : 'Presiona el botón "+ Nueva Nota" para escribir ideas o crear tus listas de tareas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.withValues(alpha: 0.8),
              ),
            ),
            if (hasFilter) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _isSearching = false;
                    widget.controller.setSearchQuery('');
                    widget.controller.setColorFilter(null);
                  });
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpiar filtros'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesList(List<NoteModel> notes) {
    final isGrid = widget.controller.isGridView;

    if (!isGrid) {
      // 1-column list view
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
        itemCount: notes.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final note = notes[index];
          return NoteCard(
            note: note,
            onTap: () => _openEditor(note: note),
            onDelete: () => _confirmDeleteCard(note),
            onTogglePin: () => widget.controller.togglePin(note.id),
            onColorChanged: (newColor) =>
                widget.controller.changeNoteColor(note.id, newColor),
          );
        },
      );
    }

    // Multi-column staggered masonry layout (adaptive heights without clipping)
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 3 : 2;
        final List<List<NoteModel>> columns =
            List.generate(crossAxisCount, (_) => []);

        for (int i = 0; i < notes.length; i++) {
          columns[i % crossAxisCount].add(notes[i]);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(crossAxisCount, (colIndex) {
              final colNotes = columns[colIndex];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: colIndex < crossAxisCount - 1 ? 12 : 0,
                  ),
                  child: Column(
                    children: colNotes.map((note) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: NoteCard(
                          note: note,
                          onTap: () => _openEditor(note: note),
                          onDelete: () => _confirmDeleteCard(note),
                          onTogglePin: () => widget.controller.togglePin(note.id),
                          onColorChanged: (newColor) => widget.controller
                              .changeNoteColor(note.id, newColor),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
