import 'package:flutter/material.dart';
import 'dart:async'; // For debouncing

void main() {
  runApp(const PermitToWorkApp());
}

class PermitToWorkApp extends StatelessWidget {
  const PermitToWorkApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Permit to Work System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// Data Models
enum PermitStatus { pending, approved, inProgress, completed, rejected }

enum UserRole { worker, supervisor, safetyOfficer, admin }

class User {
  final String id;
  String name;
  UserRole role;

  User({required this.id, required this.name, required this.role});
}

class Permit {
  final String id;
  final String workTitle;
  final String location;
  final String requesterId;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> hazards;
  final List<String> precautions;
  PermitStatus status;
  String? approvedBy;
  DateTime? approvedDate;
  String? comments;

  Permit({
    required this.id,
    required this.workTitle,
    required this.location,
    required this.requesterId,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.hazards,
    required this.precautions,
    this.status = PermitStatus.pending,
    this.approvedBy,
    this.approvedDate,
    this.comments,
  });
}

// Mock Data
// Updated mock users with different roles
final List<User> mockUsers = [
  User(id: 'user1', name: 'John Doe', role: UserRole.worker),
  User(id: 'user2', name: 'Jane Smith', role: UserRole.supervisor),
  User(id: 'user3', name: 'Mike Johnson', role: UserRole.safetyOfficer),
  User(id: 'user4', name: 'Sarah Williams', role: UserRole.admin),
];
// final currentUser = User(id: 'user1', name: 'John Doe', role: UserRole.worker);

// Replace CurrentUser with this variable that will be set during login
User currentUser = mockUsers[0]; // Default to first user

final List<Permit> mockPermits = [
  Permit(
    id: 'PTW-001',
    workTitle: 'Electrical Panel Maintenance',
    location: 'Building A, Floor 2',
    requesterId: 'user1',
    description: 'Replacing circuit breakers in main electrical panel',
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 1)),
    hazards: ['Electrical shock', 'Short circuit'],
    precautions: [
      'Isolate power',
      'Use safety equipment',
      'Follow lockout procedures'
    ],
    status: PermitStatus.pending,
  ),
  Permit(
    id: 'PTW-002',
    workTitle: 'Hot Work - Welding',
    location: 'Building B, Ground Floor',
    requesterId: 'user1',
    description: 'Welding pipe connections in the boiler room',
    startDate: DateTime.now().subtract(const Duration(days: 1)),
    endDate: DateTime.now().add(const Duration(days: 2)),
    hazards: ['Fire', 'Burns', 'Toxic fumes'],
    precautions: ['Fire extinguisher', 'Ventilation', 'Fire watch'],
    status: PermitStatus.approved,
    approvedBy: 'Jane Smith',
    approvedDate: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  Permit(
    id: 'PTW-003',
    workTitle: 'Height Work - Roof Inspection',
    location: 'Main Office Roof',
    requesterId: 'user1',
    description: 'Annual inspection of roof structure and HVAC units',
    startDate: DateTime.now().add(const Duration(days: 3)),
    endDate: DateTime.now().add(const Duration(days: 3)),
    hazards: ['Fall from height', 'Dropping objects'],
    precautions: ['Fall arrest system', 'Tool tethering', 'Barricades below'],
    status: PermitStatus.inProgress,
    approvedBy: 'Mike Johnson',
    approvedDate: DateTime.now().subtract(const Duration(days: 1)),
  ),
];

// Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _selectedUserId;

  @override
  void initState() {
    super.initState();
    // Initialize with first user
    _selectedUserId = mockUsers[0].id;
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call with delay
      Timer(const Duration(seconds: 1), () {
        // Find the selected user from mock data
        final selectedUser = mockUsers.firstWhere(
          (user) => user.id == _selectedUserId,
          orElse: () => mockUsers[0],
        );

        // Set the current user for the app
        currentUser = selectedUser;

        setState(() {
          _isLoading = false;
        });

        // Navigate to dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.assignment,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Permit to Work System',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // User selection dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Login as',
                      prefixIcon: Icon(Icons.person),
                    ),
                    value: _selectedUserId,
                    items: mockUsers.map((User user) {
                      return DropdownMenuItem<String>(
                        value: user.id,
                        child:
                            Text('${user.name} (${_getRoleString(user.role)})'),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedUserId = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a user';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'Enter your username',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Would handle forgot password in a real app
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Password reset functionality would go here'),
                          ),
                        );
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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

// Dashboard Screen
// Updated Dashboard Screen with role-based navigation
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;
  late List<BottomNavigationBarItem> _navigationItems;

  @override
  void initState() {
    super.initState();
    _setupNavigationByRole();
  }

  void _setupNavigationByRole() {
    // Common screens for all roles
    _widgetOptions = <Widget>[
      const PermitsListScreen(),
    ];

    _navigationItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.list),
        label: 'My Permits',
      ),
    ];

    // Workers can create new permits
    if (currentUser.role == UserRole.worker) {
      _widgetOptions.add(const CreatePermitScreen());
      _navigationItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.add_circle),
        label: 'New Permit',
      ));
    }

    // Supervisors and safety officers see approval queue
    if (currentUser.role == UserRole.supervisor ||
        currentUser.role == UserRole.safetyOfficer) {
      _widgetOptions.add(const ApprovalQueueScreen());
      _navigationItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.approval),
        label: 'Approvals',
      ));
    }

    // Add profile screen for all users
    _widgetOptions.add(const ProfileScreen());
    _navigationItems.add(const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ));

    // Add admin dashboard for admins
    if (currentUser.role == UserRole.admin) {
      // _widgetOptions.add(const AdminControlPanel());
      _navigationItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.admin_panel_settings),
        label: 'Admin',
      ));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PTW System - ${_getRoleString(currentUser.role)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Would show notifications in a real app
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Notifications would appear here')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Confirm logout
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: _navigationItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Needed for 4+ items
      ),
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

// Permits List Screen
class PermitsListScreen extends StatefulWidget {
  const PermitsListScreen({Key? key}) : super(key: key);

  @override
  State<PermitsListScreen> createState() => _PermitsListScreenState();
}

class _PermitsListScreenState extends State<PermitsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'In Progress'),
            Tab(text: 'Completed'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPermitList(PermitStatus.pending),
              _buildPermitList(PermitStatus.approved),
              _buildPermitList(PermitStatus.inProgress),
              _buildPermitList(PermitStatus.completed),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPermitList(PermitStatus status) {
    final permits =
        mockPermits.where((permit) => permit.status == status).toList();

    return permits.isEmpty
        ? const Center(child: Text('No permits found'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: permits.length,
            itemBuilder: (context, index) {
              final permit = permits[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    permit.workTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Location: ${permit.location}'),
                      Text(
                          'Date: ${_formatDate(permit.startDate)} - ${_formatDate(permit.endDate)}'),
                      const SizedBox(height: 8),
                      _buildStatusChip(permit.status),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PermitDetailScreen(permit: permit),
                      ),
                    ).then((_) {
                      // Refresh the list when coming back from details
                      setState(() {});
                    });
                  },
                ),
              );
            },
          );
  }

  Widget _buildStatusChip(PermitStatus status) {
    Color chipColor;
    String statusText;

    switch (status) {
      case PermitStatus.pending:
        chipColor = Colors.orange;
        statusText = 'Pending';
        break;
      case PermitStatus.approved:
        chipColor = Colors.blue;
        statusText = 'Approved';
        break;
      case PermitStatus.inProgress:
        chipColor = Colors.purple;
        statusText = 'In Progress';
        break;
      case PermitStatus.completed:
        chipColor = Colors.green;
        statusText = 'Completed';
        break;
      case PermitStatus.rejected:
        chipColor = Colors.red;
        statusText = 'Rejected';
        break;
    }

    return Chip(
      label: Text(
        statusText,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: chipColor,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Permit Detail Screen
class PermitDetailScreen extends StatefulWidget {
  final Permit permit;

  const PermitDetailScreen({Key? key, required this.permit}) : super(key: key);

  @override
  State<PermitDetailScreen> createState() => _PermitDetailScreenState();
}

class _PermitDetailScreenState extends State<PermitDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permit ${widget.permit.id}'),
        actions: [
          if (currentUser.role == UserRole.admin ||
              currentUser.role == UserRole.safetyOfficer ||
              currentUser.role == UserRole.supervisor)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editPermit();
                } else if (value == 'delete') {
                  _deletePermit();
                }
              },
              itemBuilder: (context) => [
                if (widget.permit.status == PermitStatus.pending)
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit Permit'),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete Permit'),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusSection(),
            const SizedBox(height: 24),
            _buildPermitDetails(),
            const SizedBox(height: 24),
            _buildHazardsSection(),
            const SizedBox(height: 24),
            _buildPrecautionsSection(),
            if (widget.permit.comments != null) ...[
              const SizedBox(height: 24),
              _buildCommentsSection(),
            ],
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Status',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusChip(widget.permit.status),
                ],
              ),
            ),
            if (widget.permit.approvedBy != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Approved By',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.permit.approvedBy!,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (widget.permit.approvedDate != null)
                      Text(
                        _formatDateTime(widget.permit.approvedDate!),
                        style: const TextStyle(fontSize: 14),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermitDetails() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Permit Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Work Title', widget.permit.workTitle),
            _buildDetailRow('Location', widget.permit.location),
            _buildDetailRow('Requested By', _getRequesterName()),
            _buildDetailRow('Start Date', _formatDate(widget.permit.startDate)),
            _buildDetailRow('End Date', _formatDate(widget.permit.endDate)),
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.permit.description),
          ],
        ),
      ),
    );
  }

  Widget _buildHazardsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hazards Identified',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.permit.hazards.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(widget.permit.hazards[index]),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrecautionsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Safety Precautions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.permit.precautions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(widget.permit.precautions[index]),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.permit.comments!),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    // Different actions based on permit status and user role
    if (widget.permit.status == PermitStatus.pending) {
      if (currentUser.role == UserRole.supervisor ||
          currentUser.role == UserRole.safetyOfficer ||
          currentUser.role == UserRole.admin) {
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () => _showApprovalDialog(),
                child: const Text('Approve'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () => _showRejectionDialog(),
                child: const Text('Reject'),
              ),
            ),
          ],
        );
      } else if (currentUser.role == UserRole.worker &&
          widget.permit.requesterId == currentUser.id) {
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _editPermit(),
                child: const Text('Edit'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () => _deletePermit(),
                child: const Text('Withdraw'),
              ),
            ),
          ],
        );
      }
    } else if (widget.permit.status == PermitStatus.approved &&
        currentUser.role == UserRole.worker &&
        widget.permit.requesterId == currentUser.id) {
      return ElevatedButton(
        onPressed: () {
          setState(() {
            widget.permit.status = PermitStatus.inProgress;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Work started')),
          );
        },
        child: const Text('Start Work'),
      );
    } else if (widget.permit.status == PermitStatus.inProgress &&
        currentUser.role == UserRole.worker &&
        widget.permit.requesterId == currentUser.id) {
      return ElevatedButton(
        onPressed: () => _showCompletionDialog(),
        child: const Text('Complete Work'),
      );
    }

    return Container(); // No action buttons for other statuses
  }

  void _showApprovalDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Approve Permit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Are you sure you want to approve this permit?'),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Comments (Optional)',
                  hintText: 'Add any special instructions',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                setState(() {
                  widget.permit.status = PermitStatus.approved;
                  widget.permit.approvedBy = currentUser.name;
                  widget.permit.approvedDate = DateTime.now();
                  if (_commentController.text.isNotEmpty) {
                    widget.permit.comments = _commentController.text;
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Permit approved successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );
  }

  void _showRejectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject Permit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Are you sure you want to reject this permit?'),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Reason for Rejection',
                  hintText: 'Provide a reason for rejecting this permit',
                ),
                maxLines: 3,
              ),
            ],
          ),
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
                if (_commentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please provide a reason for rejection'),
                    ),
                  );
                  return;
                }

                setState(() {
                  widget.permit.status = PermitStatus.rejected;
                  widget.permit.comments = _commentController.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Permit rejected'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Complete Work'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Confirm that all work has been completed safely and the area has been left in a safe condition.'),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Completion Notes',
                  hintText: 'Add any notes about the completed work',
                ),
                maxLines: 3,
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
                setState(() {
                  widget.permit.status = PermitStatus.completed;
                  if (_commentController.text.isNotEmpty) {
                    widget.permit.comments = _commentController.text;
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Work completed successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Complete'),
            ),
          ],
        );
      },
    );
  }

  void _editPermit() {
    // In a real app, we would navigate to an edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Edit permit functionality would open here')),
    );
  }

  void _deletePermit() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Permit'),
          content: const Text(
              'Are you sure you want to delete this permit? This action cannot be undone.'),
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
                mockPermits.remove(widget.permit);
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Permit deleted successfully'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(PermitStatus status) {
    Color chipColor;
    String statusText;

    switch (status) {
      case PermitStatus.pending:
        chipColor = Colors.orange;
        statusText = 'Pending';
        break;
      case PermitStatus.approved:
        chipColor = Colors.blue;
        statusText = 'Approved';
        break;
      case PermitStatus.inProgress:
        chipColor = Colors.purple;
        statusText = 'In Progress';
        break;
      case PermitStatus.completed:
        chipColor = Colors.green;
        statusText = 'Completed';
        break;
      case PermitStatus.rejected:
        chipColor = Colors.red;
        statusText = 'Rejected';
        break;
    }

    return Chip(
      label: Text(
        statusText,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: chipColor,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getRequesterName() {
    final requester = mockUsers.firstWhere(
      (user) => user.id == widget.permit.requesterId,
      orElse: () => User(id: 'unknown', name: 'Unknown', role: UserRole.worker),
    );
    return requester.name;
  }
}

// Create Permit Screen
class CreatePermitScreen extends StatefulWidget {
  const CreatePermitScreen({Key? key}) : super(key: key);

  @override
  State<CreatePermitScreen> createState() => _CreatePermitScreenState();
}

class _CreatePermitScreenState extends State<CreatePermitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workTitleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));

  final List<String> _selectedHazards = [];
  final List<String> _selectedPrecautions = [];

  final List<String> _availableHazards = [
    'Electrical',
    'Fire',
    'Chemical',
    'Height work',
    'Confined space',
    'Hot work',
    'Machinery',
    'Toxic materials',
    'Heavy lifting',
    'Slips and trips',
  ];

  final List<String> _availablePrecautions = [
    'PPE required',
    'Area isolation',
    'Fire extinguisher',
    'First aid kit',
    'Lockout/Tagout',
    'Ventilation',
    'Safety harness',
    'Gas detection',
    'Training required',
    'Supervision required',
    'Emergency response plan',
  ];

  @override
  void dispose() {
    _workTitleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create New Permit Request',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _workTitleController,
              decoration: const InputDecoration(
                labelText: 'Work Title',
                hintText: 'Enter the title of the work',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a work title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'Enter the work location',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the work to be performed',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildDateSection(),
            const SizedBox(height: 24),
            _buildHazardsSection(),
            const SizedBox(height: 24),
            _buildPrecautionsSection(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitPermit,
              child: const Text('Submit Permit Request'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Work Period',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text('Start Date'),
                subtitle: Text(_formatDate(_startDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _startDate = pickedDate;
                      // Ensure end date is after start date
                      if (_endDate.isBefore(_startDate)) {
                        _endDate = _startDate.add(const Duration(days: 1));
                      }
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text('End Date'),
                subtitle: Text(_formatDate(_endDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _endDate,
                    firstDate: _startDate,
                    lastDate: _startDate.add(const Duration(days: 30)),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _endDate = pickedDate;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHazardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Hazards Identified',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Hazard'),
              onPressed: () => _showHazardSelectionDialog(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedHazards.isEmpty)
          const Text(
            'No hazards selected. Please identify any potential hazards.',
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedHazards.map((hazard) {
              return Chip(
                label: Text(hazard),
                backgroundColor: Colors.orange[100],
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _selectedHazards.remove(hazard);
                  });
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildPrecautionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Safety Precautions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Precaution'),
              onPressed: () => _showPrecautionSelectionDialog(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedPrecautions.isEmpty)
          const Text(
            'No precautions selected. Please add required safety measures.',
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedPrecautions.map((precaution) {
              return Chip(
                label: Text(precaution),
                backgroundColor: Colors.green[100],
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _selectedPrecautions.remove(precaution);
                  });
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  void _showHazardSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Hazards'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _availableHazards.map((hazard) {
                final isSelected = _selectedHazards.contains(hazard);
                return CheckboxListTile(
                  title: Text(hazard),
                  value: isSelected,
                  onChanged: (selected) {
                    setState(() {
                      if (selected == true && !isSelected) {
                        _selectedHazards.add(hazard);
                      } else if (selected == false && isSelected) {
                        _selectedHazards.remove(hazard);
                      }
                    });
                    Navigator.pop(context);
                    _showHazardSelectionDialog();
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _showPrecautionSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Precautions'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _availablePrecautions.map((precaution) {
                final isSelected = _selectedPrecautions.contains(precaution);
                return CheckboxListTile(
                  title: Text(precaution),
                  value: isSelected,
                  onChanged: (selected) {
                    setState(() {
                      if (selected == true && !isSelected) {
                        _selectedPrecautions.add(precaution);
                      } else if (selected == false && isSelected) {
                        _selectedPrecautions.remove(precaution);
                      }
                    });
                    Navigator.pop(context);
                    _showPrecautionSelectionDialog();
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _submitPermit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedHazards.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please identify at least one hazard')),
        );
        return;
      }

      if (_selectedPrecautions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select at least one safety precaution')),
        );
        return;
      }

      // In a real app, this would be sent to an API
      final newPermit = Permit(
        id: 'PTW-${mockPermits.length + 1}'.padLeft(7, '0'),
        workTitle: _workTitleController.text,
        location: _locationController.text,
        requesterId: currentUser.id,
        description: _descriptionController.text,
        startDate: _startDate,
        endDate: _endDate,
        hazards: _selectedHazards,
        precautions: _selectedPrecautions,
        status: PermitStatus.pending,
      );

      // Add to our mock list
      mockPermits.add(newPermit);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permit request submitted successfully')),
      );

      // Reset form
      _workTitleController.clear();
      _locationController.clear();
      _descriptionController.clear();
      setState(() {
        _startDate = DateTime.now();
        _endDate = DateTime.now().add(const Duration(days: 1));
        _selectedHazards.clear();
        _selectedPrecautions.clear();
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Profile Screen
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, size: 64, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            currentUser.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            _getRoleString(currentUser.role),
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          _buildStatCard(context),
          const SizedBox(height: 32),
          _buildPreferencesCard(context),
          if (currentUser.role == UserRole.admin ||
              currentUser.role == UserRole.safetyOfficer ||
              currentUser.role == UserRole.supervisor) ...[
            const SizedBox(height: 32),
            _buildAdminQuickActions(context),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context) {
    final pendingPermits = mockPermits
        .where((p) =>
            p.status == PermitStatus.pending && p.requesterId == currentUser.id)
        .length;
    final activePermits = mockPermits
        .where((p) =>
            (p.status == PermitStatus.approved ||
                p.status == PermitStatus.inProgress) &&
            p.requesterId == currentUser.id)
        .length;
    final completedPermits = mockPermits
        .where((p) =>
            p.status == PermitStatus.completed &&
            p.requesterId == currentUser.id)
        .length;
    final approvalsPending = currentUser.role != UserRole.worker
        ? mockPermits.where((p) => p.status == PermitStatus.pending).length
        : 0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(context, 'Pending',
                      pendingPermits.toString(), Colors.orange),
                ),
                Expanded(
                  child: _buildStatItem(
                      context, 'Active', activePermits.toString(), Colors.blue),
                ),
                Expanded(
                  child: _buildStatItem(context, 'Completed',
                      completedPermits.toString(), Colors.green),
                ),
                if (currentUser.role != UserRole.worker)
                  Expanded(
                    child: _buildStatItem(context, 'Approvals',
                        approvalsPending.toString(), Colors.purple),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminQuickActions(BuildContext context) {
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                          settings: const RouteSettings(
                            arguments: {'tabIndex': 1},
                          ),
                        ),
                      );
                    },
                  ),
                if (currentUser.role == UserRole.supervisor ||
                    currentUser.role == UserRole.safetyOfficer ||
                    currentUser.role == UserRole.admin)
                  _buildQuickActionButton(
                    icon: Icons.approval,
                    label: 'Approvals',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                          settings: const RouteSettings(
                            arguments: {'tabIndex': 1},
                          ),
                        ),
                      );
                    },
                  ),
                if (currentUser.role == UserRole.admin)
                  _buildQuickActionButton(
                    icon: Icons.settings,
                    label: 'System Settings',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                          settings: const RouteSettings(
                            arguments: {'tabIndex': 2},
                          ),
                        ),
                      );
                    },
                  ),
                _buildQuickActionButton(
                  icon: Icons.help,
                  label: 'Help',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Help center would open here')),
                    );
                  },
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

  Widget _buildPreferencesCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Notifications'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Notifications ${value ? 'enabled' : 'disabled'}'),
                  ),
                );
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('App restart required for theme change')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Change Password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showChangePasswordDialog();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

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
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter current password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter new password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                  ),
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
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
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password changed successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Change Password'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, String value, Color color) {
    return Column(
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
          style: const TextStyle(color: Colors.grey),
        ),
      ],
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

// Admin Dashboard Screen
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(),
            const SizedBox(height: 24),
            _buildPendingApprovals(),
            const SizedBox(height: 24),
            _buildUserManagement(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalPermits = mockPermits.length;
    final pendingApprovals =
        mockPermits.where((p) => p.status == PermitStatus.pending).length;
    final activeWork =
        mockPermits.where((p) => p.status == PermitStatus.inProgress).length;

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
            Expanded(
              child: _buildSummaryCard(
                'Total Permits',
                totalPermits.toString(),
                Colors.blue,
                Icons.assignment,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Pending Approvals',
                pendingApprovals.toString(),
                Colors.orange,
                Icons.pending_actions,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Active Work',
                activeWork.toString(),
                Colors.green,
                Icons.construction,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, Color color, IconData icon) {
    return Card(
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
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingApprovals() {
    final pendingPermits =
        mockPermits.where((p) => p.status == PermitStatus.pending).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pending Approvals',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        pendingPermits.isEmpty
            ? const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text('No pending approvals'),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pendingPermits.length,
                itemBuilder: (context, index) {
                  final permit = pendingPermits[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(permit.workTitle),
                      subtitle: Text('Location: ${permit.location}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle,
                                color: Colors.green),
                            onPressed: () {
                              setState(() {
                                permit.status = PermitStatus.approved;
                                permit.approvedBy = currentUser.name;
                                permit.approvedDate = DateTime.now();
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Permit approved')),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                permit.status = PermitStatus.rejected;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Permit rejected')),
                              );
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PermitDetailScreen(permit: permit),
                          ),
                        ).then((_) {
                          setState(() {});
                        });
                      },
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildUserManagement() {
    // Mock user list
    final users = [
      User(id: 'user1', name: 'John Doe', role: UserRole.worker),
      User(id: 'user2', name: 'Jane Smith', role: UserRole.supervisor),
      User(id: 'user3', name: 'Mike Johnson', role: UserRole.safetyOfficer),
      User(id: 'user4', name: 'Sarah Williams', role: UserRole.admin),
    ];

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
              onPressed: () {
                // Would open add user dialog in a real app
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: users.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(user.name.substring(0, 1)),
                ),
                title: Text(user.name),
                subtitle: Text(_getRoleString(user.role)),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Would open edit user dialog in a real app
                  },
                ),
              );
            },
          ),
        ),
      ],
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

//

// Approval Queue Screen for Supervisors and Safety Officers
class ApprovalQueueScreen extends StatefulWidget {
  const ApprovalQueueScreen({Key? key}) : super(key: key);

  @override
  State<ApprovalQueueScreen> createState() => _ApprovalQueueScreenState();
}

class _ApprovalQueueScreenState extends State<ApprovalQueueScreen> {
  final List<Permit> _pendingPermits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingPermits();
  }

  void _loadPendingPermits() {
    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _pendingPermits.clear();
        _pendingPermits.addAll(
          mockPermits.where((permit) => permit.status == PermitStatus.pending),
        );
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pendingPermits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'No pending approvals',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('All permit requests have been processed'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                _loadPendingPermits();
              },
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isLoading = true;
        });
        _loadPendingPermits();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingPermits.length,
        itemBuilder: (context, index) {
          final permit = _pendingPermits[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    permit.workTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('ID: ${permit.id}'),
                      Text('Location: ${permit.location}'),
                      Text(
                          'Date: ${_formatDate(permit.startDate)} - ${_formatDate(permit.endDate)}'),
                    ],
                  ),
                  trailing: _buildStatusChip(permit.status),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      Text(
                        'Description: ${permit.description}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hazards: ${permit.hazards.join(", ")}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceAround,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.visibility),
                      label: const Text('Details'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PermitDetailScreen(permit: permit),
                          ),
                        ).then((_) {
                          // Refresh when returning from details
                          _loadPendingPermits();
                        });
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () => _showApprovalDialog(permit),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.cancel),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => _showRejectionDialog(permit),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showApprovalDialog(Permit permit) {
    final commentsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Permit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Permit ID: ${permit.id}'),
            Text('Title: ${permit.workTitle}'),
            const SizedBox(height: 16),
            TextField(
              controller: commentsController,
              decoration: const InputDecoration(
                labelText: 'Comments (Optional)',
                hintText: 'Add any special instructions or comments',
              ),
              maxLines: 3,
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
              setState(() {
                permit.status = PermitStatus.approved;
                permit.approvedBy = currentUser.name;
                permit.approvedDate = DateTime.now();
                permit.comments = commentsController.text.isNotEmpty
                    ? commentsController.text
                    : null;

                // Remove from the pending list
                _pendingPermits.remove(permit);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Permit ${permit.id} approved successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectionDialog(Permit permit) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Permit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Permit ID: ${permit.id}'),
            Text('Title: ${permit.workTitle}'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for Rejection',
                hintText: 'Provide a reason for rejecting this permit',
              ),
              maxLines: 3,
            ),
          ],
        ),
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
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason for rejection'),
                  ),
                );
                return;
              }

              setState(() {
                permit.status = PermitStatus.rejected;
                permit.comments = reasonController.text;

                // Remove from the pending list
                _pendingPermits.remove(permit);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Permit ${permit.id} rejected'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(PermitStatus status) {
    Color chipColor;
    String statusText;

    switch (status) {
      case PermitStatus.pending:
        chipColor = Colors.orange;
        statusText = 'Pending';
        break;
      case PermitStatus.approved:
        chipColor = Colors.blue;
        statusText = 'Approved';
        break;
      case PermitStatus.inProgress:
        chipColor = Colors.purple;
        statusText = 'In Progress';
        break;
      case PermitStatus.completed:
        chipColor = Colors.green;
        statusText = 'Completed';
        break;
      case PermitStatus.rejected:
        chipColor = Colors.red;
        statusText = 'Rejected';
        break;
    }

    return Chip(
      label: Text(
        statusText,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: chipColor,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Admin control paneel

// Enhanced Admin Dashboard
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
