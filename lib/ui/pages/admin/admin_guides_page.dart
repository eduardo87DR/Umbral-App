// admin_guides_page.dart (versión final con importación)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dungeon_admin/providers/auth_provider.dart';
import '../../../../providers/guides_provider.dart';
import '../../../../models/guide.dart';
import '../../widgets/admin_guide_card.dart';
import '../../widgets/guide_form_dialog.dart';
import '../../widgets/search_app_bar.dart';
import '../../widgets/pagination_controls.dart';
import '../../widgets/guide_preview_dialog.dart';

class AdminGuidesPage extends ConsumerStatefulWidget {
  const AdminGuidesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminGuidesPage> createState() => _AdminGuidesPageState();
}

class _AdminGuidesPageState extends ConsumerState<AdminGuidesPage> {
  String _query = '';
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _showOnlyMine = false;

  List<Guide> _localList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncLocal());
  }

  void _syncLocal() {
    final async = ref.read(guidesListProvider);
    async.whenData((list) {
      setState(() {
        _localList = list;
      });
    });
  }

  Future<void> _refresh() async {
    await ref.read(guidesListProvider.notifier).load();
    _syncLocal();
  }

  List<Guide> _filteredList() {
    var list = _localList;
    if (_showOnlyMine) {
      final me = ref.read(authStateProvider).value;
      if (me != null) list = list.where((g) => g.authorId == me.id).toList();
    }
    if (_query.trim().isEmpty) return list;
    final q = _query.toLowerCase();
    return list.where((g) => g.title.toLowerCase().contains(q) || g.content.toLowerCase().contains(q)).toList();
  }

  List<Guide> _pagedList() {
    final filtered = _filteredList();
    final start = _currentPage * _pageSize;
    final end = start + _pageSize;
    if (start >= filtered.length) return [];
    return filtered.sublist(start, end.clamp(0, filtered.length));
  }

  int get _totalPages {
    final filtered = _filteredList();
    return (filtered.length / _pageSize).ceil();
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _openForm({Guide? guide}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => GuideFormDialog(guide: guide),
    );
    if (result == true) {
      await _refresh();
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Eliminar guía', style: TextStyle(color: Colors.amberAccent)),
        content: const Text('¿Estás seguro? Esta acción es irreversible.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(guidesListProvider.notifier).delete(id);
                await _refresh();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text('Guía eliminada')));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showPreview(Guide g) {
    showDialog(
      context: context,
      builder: (_) => GuidePreviewDialog(guide: g),
    );
  }

  void _handleQueryChanged(String query) {
    setState(() {
      _query = query;
      _currentPage = 0;
    });
  }

  void _handleToggleMine() {
    setState(() {
      _showOnlyMine = !_showOnlyMine;
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final guidesAsync = ref.watch(guidesListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: SearchAppBar(
        query: _query,
        showOnlyMine: _showOnlyMine,
        onQueryChanged: _handleQueryChanged,
        onToggleMine: _handleToggleMine,
        onCreateGuide: () => _openForm(),
        onRefresh: _refresh,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B0B0B), Color(0xFF171718)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: guidesAsync.when(
          data: (list) {
            // sincronizamos la lista local
            _localList = list;
            final paged = _pagedList();
            final filteredTotal = _filteredList().length;
            final totalPages = _totalPages;

            if (paged.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refresh,
                color: Colors.amberAccent,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
                  children: [
                    const SizedBox(height: 10),
                    const Center(child: Text('No hay guías que coincidan con tu búsqueda.', style: TextStyle(color: Colors.white70))),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Crear primera guía'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent, foregroundColor: Colors.black),
                        onPressed: () => _openForm(),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    color: Colors.amberAccent,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: paged.length,
                      itemBuilder: (context, idx) {
                        final g = paged[idx];
                        return AdminGuideCard(
                          guide: g,
                          onEdit: () => _openForm(guide: g),
                          onDelete: () => _confirmDelete(g.id),
                          onPreview: () => _showPreview(g),
                        );
                      },
                    ),
                  ),
                ),
                // Paginación real en la parte inferior
                if (totalPages > 1) 
                  PaginationControls(
                    currentPage: _currentPage,
                    totalPages: totalPages,
                    totalItems: filteredTotal,
                    pageSize: _pageSize,
                    onPageChanged: _goToPage,
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: Colors.amberAccent)),
          error: (err, _) => Center(child: Text('Error cargando guías: $err', style: const TextStyle(color: Colors.redAccent))),
        ),
      ),
    );
  }
}