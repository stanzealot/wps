import 'package:flutter/material.dart';
import 'package:wps/screens/permits/permit_detail_screen.dart';
import '../../models/user.dart';
import '../../models/permit.dart';
import '../../services/mock_data_service.dart';
import '../../utils/helpers.dart';

class AdminControlPanel extends StatefulWidget {
  const AdminControlPanel({Key? key}) : super(key: key);

  @override
  State<AdminControlPanel> createState() => _AdminControlPanelState();
}

class _AdminControlPanelState extends State<AdminControlPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  final List<User> _users = List.from(mockUsers);
  final List<Permit> _allPermits = List.from(mockPermits);
  final _newUserFormKey = GlobalKey<FormState>();
  final _newUserNameController = TextEditingController();
  final _newUserEmailController = TextEditingController();
  UserRole _newUserRole = UserRole.worker;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _newUserNameController.dispose();
    _newUserEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Users'),
            Tab(text: 'Settings'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDashboardTab(),
              _buildUsersTab(),
              _buildSettingsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardTab() {
    // Count permits by status
    final pendingCount =
        _allPermits.where((p) => p.status == PermitStatus.pending).length;
    final approvedCount =
        _allPermits.where((p) => p.status == PermitStatus.approved).length;
    final inProgressCount =
        _allPermits.where((p) => p.status == PermitStatus.inProgress).length;
    final completedCount =
        _allPermits.where((p) => p.status == PermitStatus.completed).length;
    final rejectedCount =
        _allPermits.where((p) => p.status == PermitStatus.rejected).length;
    final totalCount = _allPermits.length;

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isLoading = true;
        });

        // Simulate API call
        await Future.delayed(const Duration(milliseconds: 800));

        setState(() {
          _isLoading = false;
        });
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // System stats row
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'System Overview',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  // Simulate refresh
                                  Future.delayed(
                                      const Duration(milliseconds: 800), () {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  });
                                },
                        ),
                      ],
                    ),
                    if (_isLoading)
                      const LinearProgressIndicator()
                    else
                      const SizedBox(height: 4),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn(
                            'Total', totalCount.toString(), Colors.blue),
                        _buildStatColumn(
                            'Pending', pendingCount.toString(), Colors.orange),
                        _buildStatColumn(
                            'Approved', approvedCount.toString(), Colors.green),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn('In Progress',
                            inProgressCount.toString(), Colors.purple),
                        _buildStatColumn('Completed', completedCount.toString(),
                            Colors.teal),
                        _buildStatColumn(
                            'Rejected', rejectedCount.toString(), Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Recent Activity
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Activity',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 5, // Show last 5 actions
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        // Mock activity data
                        final activities = [
                          'Jane Smith approved permit PTW-001',
                          'Mike Johnson rejected permit PTW-004',
                          'John Doe submitted new permit PTW-006',
                          'Sarah Williams completed permit PTW-002',
                          'System maintenance scheduled for next week',
                        ];

                        final times = [
                          '10 minutes ago',
                          '1 hour ago',
                          '3 hours ago',
                          'Yesterday',
                          '2 days ago',
                        ];

                        final icons = [
                          Icons.check_circle,
                          Icons.cancel,
                          Icons.add_circle,
                          Icons.task_alt,
                          Icons.settings,
                        ];

                        final colors = [
                          Colors.green,
                          Colors.red,
                          Colors.blue,
                          Colors.teal,
                          Colors.grey,
                        ];

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colors[index].withOpacity(0.2),
                            child: Icon(icons[index], color: colors[index]),
                          ),
                          title: Text(activities[index]),
                          subtitle: Text(times[index]),
                          dense: true,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Would show full activity log in a real app
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Full activity log would be shown here'),
                            ),
                          );
                        },
                        child: const Text('View All Activity'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Quick Actions
            Card(
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
                        _buildActionButton(
                          icon: Icons.people,
                          label: 'Add User',
                          onPressed: () => _showAddUserDialog(),
                        ),
                        _buildActionButton(
                          icon: Icons.assessment,
                          label: 'Reports',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Reports generation would open here')),
                            );
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.backup,
                          label: 'Backup',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('System backup initiated')),
                            );
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.settings_backup_restore,
                          label: 'Restore',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Restore options would appear here')),
                            );
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.notifications_active,
                          label: 'Notify All',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Notification sent to all users')),
                            );
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.lock_reset,
                          label: 'Reset Passwords',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Password reset options would appear here')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Pending Approvals
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pending Approvals',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton(
                          onPressed: () {
                            // Would navigate to full approvals screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Navigating to full approvals screen')),
                            );
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPendingApprovalsList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingApprovalsList() {
    final pendingPermits =
        _allPermits.where((p) => p.status == PermitStatus.pending).toList();

    if (pendingPermits.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No pending approvals'),
        ),
      );
    }

    // Show only last 3 pending permits
    final recentPending = pendingPermits.length > 3
        ? pendingPermits.sublist(0, 3)
        : pendingPermits;

    return Column(
      children: recentPending.map((permit) {
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PermitDetailScreen(permit: permit),
              ),
            ).then((_) => setState(() {}));
          },
        );
      }).toList(),
    );
  }

  void _approvePermit(Permit permit) {
    setState(() {
      permit.status = PermitStatus.approved;
      permit.approvedBy = currentUser.name;
      permit.approvedDate = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Permit ${permit.id} approved'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectPermit(Permit permit) {
    setState(() {
      permit.status = PermitStatus.rejected;
      permit.comments = 'Rejected by admin';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Permit ${permit.id} rejected'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildUsersTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'User Management',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add User'),
                onPressed: () => _showAddUserDialog(),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(user.name.substring(0, 1)),
                  ),
                  title: Text(user.name),
                  subtitle: Text(_getRoleString(user.role)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showEditUserDialog(user),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            size: 20, color: Colors.red),
                        onPressed: () => _showDeleteUserDialog(user),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    bool notificationsEnabled = true;
    bool darkModeEnabled = false;
    bool analyticsEnabled = true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    value: notificationsEnabled,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Notifications ${value ? 'enabled' : 'disabled'}')),
                      );
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: darkModeEnabled,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('App restart required for theme change')),
                      );
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Analytics Collection'),
                    value: analyticsEnabled,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Analytics ${value ? 'enabled' : 'disabled'}')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'System Maintenance',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.backup),
                    title: const Text('Backup Database'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Database backup initiated')),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings_backup_restore),
                    title: const Text('Restore Database'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Restore options would appear here')),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Clear Cache'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Cache cleared successfully')),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.update),
                    title: const Text('Check for Updates'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Checking for updates...')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Danger Zone',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.red),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading:
                        const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('Reset System',
                        style: TextStyle(color: Colors.red)),
                    subtitle: const Text(
                        'This will delete all data and reset to factory settings'),
                    onTap: () => _showResetSystemDialog(),
                  ),
                  const Divider(color: Colors.red),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app, color: Colors.red),
                    title: const Text('Logout All Users',
                        style: TextStyle(color: Colors.red)),
                    subtitle:
                        const Text('Force all users to logout immediately'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'All users will be logged out on their next action')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildActionButton({
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

  void _showAddUserDialog() {
    _newUserNameController.clear();
    _newUserEmailController.clear();
    _newUserRole = UserRole.worker;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New User'),
          content: Form(
            key: _newUserFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _newUserNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter user full name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newUserEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter user email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<UserRole>(
                    value: _newUserRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                    ),
                    items: UserRole.values.map((role) {
                      return DropdownMenuItem<UserRole>(
                        value: role,
                        child: Text(_getRoleString(role)),
                      );
                    }).toList(),
                    onChanged: (UserRole? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _newUserRole = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_newUserFormKey.currentState!.validate()) {
                  final newUser = User(
                    id: 'user${_users.length + 1}',
                    name: _newUserNameController.text,
                    role: _newUserRole,
                  );
                  setState(() {
                    _users.add(newUser);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User added successfully')),
                  );
                }
              },
              child: const Text('Add User'),
            ),
          ],
        );
      },
    );
  }

  void _showEditUserDialog(User user) {
    final nameController = TextEditingController(text: user.name);
    UserRole selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                ),
                items: UserRole.values.map((role) {
                  return DropdownMenuItem<UserRole>(
                    value: role,
                    child: Text(_getRoleString(role)),
                  );
                }).toList(),
                onChanged: (UserRole? newValue) {
                  if (newValue != null) {
                    selectedRole = newValue;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    user.name = nameController.text;
                    user.role = selectedRole;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User updated successfully')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteUserDialog(User user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: Text(
              'Are you sure you want to delete ${user.name}? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                setState(() {
                  _users.remove(user);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('User ${user.name} deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showResetSystemDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset System'),
          content: const Text(
              'This will delete ALL data and reset the system to factory settings. Are you absolutely sure?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('System reset would occur here in a real app'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('Reset System'),
            ),
          ],
        );
      },
    );
  }

  String _getRoleString(UserRole role) {
    switch (role) {
      case UserRole.worker:
        return 'Worker';
      case UserRole.supervisor:
        return 'Supervisor';
      case UserRole.safetyOfficer:
        return 'Safety Officer';
      case UserRole.admin:
        return 'Administrator';
    }
  }
}
