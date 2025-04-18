import 'package:flutter/material.dart';
import 'package:wps/models/permit.dart';
import '../../app/routes.dart';
import '../../models/user.dart';
import '../../services/mock_data_service.dart';
import '../../utils/helpers.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 32),
            _buildStatCard(),
            const SizedBox(height: 32),
            _buildPreferencesCard(),
            if (_shouldShowAdminActions()) ...[
              const SizedBox(height: 32),
              _buildAdminQuickActions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(
            Icons.person,
            size: 64,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          currentUser.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          getRoleString(currentUser.role),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard() {
    final stats = _calculateUserStats();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem(
                    'Pending', stats.pending.toString(), Colors.orange),
                _buildStatItem('Active', stats.active.toString(), Colors.blue),
                _buildStatItem(
                    'Completed', stats.completed.toString(), Colors.green),
                if (stats.approvalsPending != null)
                  _buildStatItem('Approvals', stats.approvalsPending.toString(),
                      Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Notifications'),
              value: _notificationsEnabled,
              onChanged: _handleNotificationsToggle,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: _darkModeEnabled,
              onChanged: _handleDarkModeToggle,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Change Password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showChangePasswordDialog,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminQuickActions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (currentUser.role == UserRole.admin)
                  _buildQuickActionButton(
                    icon: Icons.people,
                    label: 'Manage Users',
                    onPressed: () => _navigateToAdminPanel(tabIndex: 0),
                  ),
                if (_shouldShowApprovalActions())
                  _buildQuickActionButton(
                    icon: Icons.approval,
                    label: 'Approvals',
                    onPressed: () => _navigateToAdminPanel(tabIndex: 1),
                  ),
                if (currentUser.role == UserRole.admin)
                  _buildQuickActionButton(
                    icon: Icons.settings,
                    label: 'System Settings',
                    onPressed: () => _navigateToAdminPanel(tabIndex: 2),
                  ),
                _buildQuickActionButton(
                  icon: Icons.help,
                  label: 'Help',
                  onPressed: _showHelp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final _formKey = GlobalKey<FormState>();
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Current Password'),
                  validator: _validateCurrentPassword,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Password'),
                  validator: _validateNewPassword,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Confirm Password'),
                  validator: (value) => _validatePasswordConfirmation(
                      value, _newPasswordController.text),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _handlePasswordChange(context, _formKey),
              child: const Text('Change Password'),
            ),
          ],
        );
      },
    ).then((_) {
      _currentPasswordController.dispose();
      _newPasswordController.dispose();
      _confirmPasswordController.dispose();
    });
  }

  // Helper methods
  bool _shouldShowAdminActions() {
    return currentUser.role == UserRole.admin ||
        currentUser.role == UserRole.safetyOfficer ||
        currentUser.role == UserRole.supervisor;
  }

  bool _shouldShowApprovalActions() {
    return currentUser.role == UserRole.supervisor ||
        currentUser.role == UserRole.safetyOfficer ||
        currentUser.role == UserRole.admin;
  }

  _UserStats _calculateUserStats() {
    return _UserStats(
      pending: mockPermits
          .where((p) =>
              p.status == PermitStatus.pending &&
              p.requesterId == currentUser.id)
          .length,
      active: mockPermits
          .where((p) =>
              (p.status == PermitStatus.approved ||
                  p.status == PermitStatus.inProgress) &&
              p.requesterId == currentUser.id)
          .length,
      completed: mockPermits
          .where((p) =>
              p.status == PermitStatus.completed &&
              p.requesterId == currentUser.id)
          .length,
      approvalsPending: _shouldShowApprovalActions()
          ? mockPermits.where((p) => p.status == PermitStatus.pending).length
          : null,
    );
  }

  // Event handlers
  void _handleNotificationsToggle(bool value) {
    setState(() => _notificationsEnabled = value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Notifications ${value ? 'enabled' : 'disabled'}')),
    );
  }

  void _handleDarkModeToggle(bool value) {
    setState(() => _darkModeEnabled = value);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('App restart required for theme change')),
    );
  }

  void _handleLogout() {
    Navigator.pushReplacementNamed(context, Routes.login);
  }

  void _navigateToAdminPanel({required int tabIndex}) {
    Navigator.pushNamed(
      context,
      Routes.adminPanel,
      arguments: {'tabIndex': tabIndex},
    );
  }

  void _showHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help center would open here')),
    );
  }

  // Validation methods
  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter current password';
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter new password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validatePasswordConfirmation(String? value, String newPassword) {
    if (value != newPassword) return 'Passwords do not match';
    return null;
  }

  void _handlePasswordChange(
      BuildContext context, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class _UserStats {
  final int pending;
  final int active;
  final int completed;
  final int? approvalsPending;

  _UserStats({
    required this.pending,
    required this.active,
    required this.completed,
    this.approvalsPending,
  });
}
