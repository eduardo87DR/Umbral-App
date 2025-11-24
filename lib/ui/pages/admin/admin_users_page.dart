// users_admin_page_refactored.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/users_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/ranking_provider.dart';
import '../../../models/user.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/user_card_widget.dart';
import '../../widgets/ranking_tile_widget.dart';
import '../../widgets/user_form_dialog.dart';
import '../../widgets/user_detail_dialog.dart';
import '../../widgets/confirmation_dialogs.dart';
import '../../widgets/role_selection_bottom_sheet.dart';
import '../../widgets/ranking_header_widget.dart';
import '../../widgets/snackbar_helper.dart';

class UsersAdminPage extends ConsumerStatefulWidget {
  const UsersAdminPage({super.key});

  @override
  ConsumerState<UsersAdminPage> createState() => _UsersAdminPageState();
}

class _UsersAdminPageState extends ConsumerState<UsersAdminPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usersListProvider.notifier).load();
      ref.read(adminRankingProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshData(BuildContext context) {
    ref.read(usersListProvider.notifier).load();
    ref.read(adminRankingProvider.notifier).load();
    SnackbarHelper.showInfo(context, "Datos actualizados");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(context),
      body: _buildTabView(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.card,
      elevation: 2,
      centerTitle: true,
      title: const Text(
        "Panel de Administración",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: AdminTheme.adminAccent,
        labelColor: AppTheme.textPrimary,
        unselectedLabelColor: Colors.white38,
        tabs: const [
          Tab(icon: Icon(Icons.people), text: "Gestión"),
          Tab(icon: Icon(Icons.leaderboard), text: "Ranking"),
        ],
      ),
      actions: [
        IconButton(
          tooltip: "Refrescar datos",
          icon: const Icon(Icons.refresh),
          onPressed: () => _refreshData(context),
        )
      ],
    );
  }

  Widget _buildTabView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildManagementTab(),
        _buildRankingTab(),
      ],
    );
  }

  Widget _buildManagementTab() {
    final usersAsync = ref.watch(usersListProvider);
    final currentUser = ref.watch(authStateProvider).valueOrNull;

    return usersAsync.when(
      loading: () => const LoadingWidget(message: "Cargando usuarios..."),
      error: (e, st) => _buildErrorWidget("Error: $e"),
      data: (list) => _buildUserList(list, currentUser),
    );
  }

  Widget _buildRankingTab() {
    final adminRankingAsync = ref.watch(adminRankingProvider);

    return adminRankingAsync.when(
      loading: () => const LoadingWidget(message: "Cargando ranking..."),
      error: (e, st) => _buildErrorWidget("Error: $e"),
      data: (list) => _buildRankingList(list),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: AppTheme.danger),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildUserList(List<User> list, User? currentUser) {
    final filtered = currentUser == null
        ? list
        : list.where((u) => u.id != currentUser.id).toList();

    if (filtered.isEmpty) {
      return const _EmptyStateWidget(message: "No hay usuarios para mostrar.");
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(usersListProvider.notifier).load(),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: filtered.length,
        itemBuilder: (_, i) => UserCardWidget(
          user: filtered[i],
          currentUser: currentUser,
          onViewDetails: () => _openUserDetail(context, filtered[i].id),
          onEdit: () => _openUserForm(context, user: filtered[i]),
          onDelete: () => _confirmDelete(context, ref, filtered[i]),
          onChangeRole: () => _chooseRole(context, ref, filtered[i]),
          onResetStats: () => _confirmResetStats(context, ref, filtered[i]),
        ),
      ),
    );
  }

  Widget _buildRankingList(List<dynamic> list) {
    if (list.isEmpty) {
      return const _EmptyStateWidget(
        message: "Aún no hay estadísticas disponibles.",
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RankingHeaderWidget(),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, idx) => RankingTileWidget(
                index: idx,
                item: list[idx],
                onViewDetails: () => _openUserDetail(
                  context, 
                  (list[idx].userId ?? list[idx].user_id) as int
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openUserDetail(BuildContext context, int userId) {
    showDialog(
      context: context,
      builder: (_) => UserDetailDialog(
        userId: userId,
        onResetStats: () async {
          await _resetUserStats(userId);
          _refreshData(context);
        },
      ),
    );
  }

  void _openUserForm(BuildContext context, {User? user}) {
    showDialog(
      context: context,
      builder: (_) => UserFormDialog(user: user),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, User user) {
    showDialog(
      context: context,
      builder: (_) => DeleteConfirmationDialog(
        user: user,
        onConfirm: () => _deleteUser(context, ref, user),
      ),
    );
  }

  void _confirmResetStats(BuildContext context, WidgetRef ref, User user) {
    showDialog(
      context: context,
      builder: (_) => ResetStatsConfirmationDialog(
        user: user,
        onConfirm: () => _resetUserStats(user.id),
      ),
    );
  }

  Future<void> _deleteUser(BuildContext context, WidgetRef ref, User user) async {
    final notifier = ref.read(usersListProvider.notifier);
    try {
      await notifier.deleteUser(user.id);
      _refreshData(context);
      SnackbarHelper.showSuccess(context, "Usuario \"${user.username}\" eliminado.");
    } catch (e) {
      SnackbarHelper.showError(context, "Error al eliminar: $e");
    }
  }

  Future<void> _resetUserStats(int userId) async {
    try {
      final api = ref.read(apiClientProvider);
      await api.post('/admin/users/$userId/reset_stats', {});
    } catch (e) {
      rethrow;
    }
  }

  void _chooseRole(BuildContext context, WidgetRef ref, User user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AdminTheme.adminCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => RoleSelectionBottomSheet(user: user),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  final String message;

  const _EmptyStateWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}