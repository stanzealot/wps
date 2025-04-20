import 'package:flutter/material.dart';
import '../../models/permit.dart';
import '../../models/user.dart';
import '../../services/mock_data_service.dart';
import '../../utils/helpers.dart';
import '../../app/routes.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSystemOverview(),
            const SizedBox(height: 24),
            _buildPendingApprovalsSection(),
            const SizedBox(height: 24),
            _buildUserManagementSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemOverview() {
    final stats = _calculateSystemStats();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Overview',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(
              title: 'Total Permits',
              value: stats.totalPermits.toString(),
              color: Colors.blue,
              icon: Icons.assignment,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              title: 'Pending Approvals',
              value: stats.pendingApprovals.toString(),
              color: Colors.orange,
              icon: Icons.pending_actions,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              title: 'Active Work',
              value: stats.activeWork.toString(),
              color: Colors.green,
              icon: Icons.construction,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPendingApprovalsSection() {
    final pendingPermits = _getPendingPermits();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pending Approvals',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (pendingPermits.isNotEmpty)
              TextButton(
                onPressed: () => _viewAllApprovals(),
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        pendingPermits.isEmpty
            ? _buildEmptyState('No pending approvals')
            : _buildApprovalsList(pendingPermits),
      ],
    );
  }

  Widget _buildUserManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'User Management',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add User'),
              onPressed: _showAddUserDialog,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildUsersList(),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
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
                title,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApprovalsList(List<Permit> permits) {
    return Card(
      elevation: 2,
      child: Column(
        children:
            permits.map((permit) => _buildApprovalListItem(permit)).toList(),
      ),
    );
  }

  Widget _buildApprovalListItem(Permit permit) {
    return ListTile(
      title: Text(permit.workTitle),
      subtitle: Text('Location: ${permit.location}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () => _approvePermit(permit),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => _rejectPermit(permit),
          ),
        ],
      ),
      onTap: () => _viewPermitDetails(permit),
    );
  }

  Widget _buildUsersList() {
    return Card(
      elevation: 2,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: mockUsers.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final user = mockUsers[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(user.name.substring(0, 1)),
            ),
            title: Text(user.name),
            subtitle: Text(getRoleString(user.role)),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditUserDialog(user),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(message),
        ),
      ),
    );
  }

  // Helper methods
  _SystemStats _calculateSystemStats() {
    return _SystemStats(
      totalPermits: mockPermits.length,
      pendingApprovals:
          mockPermits.where((p) => p.status == PermitStatus.pending).length,
      activeWork:
          mockPermits.where((p) => p.status == PermitStatus.inProgress).length,
    );
  }

  List<Permit> _getPendingPermits() {
    return mockPermits
        .where((p) => p.status == PermitStatus.pending)
        .take(5) // Show only first 5 for the dashboard
        .toList();
  }

  // Action handlers
  void _approvePermit(Permit permit) {
    setState(() {
      permit.status = PermitStatus.approved;
      permit.approvedBy = currentUser.name;
      permit.approvedDate = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Permit approved'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectPermit(Permit permit) {
    setState(() {
      permit.status = PermitStatus.rejected;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Permit rejected'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _viewPermitDetails(Permit permit) {
    Navigator.pushNamed(
      context,
      Routes.permitDetail,
      arguments: permit,
    ).then((_) => setState(() {}));
  }

  void _viewAllApprovals() {
    Navigator.pushNamed(context, Routes.approvalQueue);
  }

  void _showAddUserDialog() {
    // Implement add user dialog
  }

  void _showEditUserDialog(User user) {
    // Implement edit user dialog
  }
}

class _SystemStats {
  final int totalPermits;
  final int pendingApprovals;
  final int activeWork;

  _SystemStats({
    required this.totalPermits,
    required this.pendingApprovals,
    required this.activeWork,
  });
}
