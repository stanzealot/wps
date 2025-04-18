import 'package:flutter/material.dart';

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
  final String name;
  final UserRole role;

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
final currentUser = User(id: 'user1', name: 'John Doe', role: UserRole.worker);

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
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
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
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Normally we would validate credentials here
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DashboardScreen()),
                  );
                },
                child: const Text('Login'),
              ),
            ],
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
}

// Dashboard Screen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const PermitsListScreen(),
    const CreatePermitScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permit to Work System'),
        actions: [
          if (currentUser.role != UserRole.worker)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminDashboardScreen()),
                );
              },
              tooltip: 'Admin Dashboard',
            ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'My Permits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'New Permit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permit ${widget.permit.id}'),
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
            if (widget.permit.status == PermitStatus.approved ||
                widget.permit.status == PermitStatus.inProgress ||
                widget.permit.status == PermitStatus.completed)
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
                      widget.permit.approvedBy ?? 'N/A',
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
            _buildDetailRow('Requested By', currentUser.name),
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

  Widget _buildActionButtons() {
    // Different actions based on permit status and user role
    if (widget.permit.status == PermitStatus.pending &&
        (currentUser.role == UserRole.supervisor ||
            currentUser.role == UserRole.safetyOfficer ||
            currentUser.role == UserRole.admin)) {
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
    } else if (widget.permit.status == PermitStatus.approved &&
        currentUser.role == UserRole.worker) {
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
        currentUser.role == UserRole.worker) {
      return ElevatedButton(
        onPressed: () => _showCompletionDialog(),
        child: const Text('Complete Work'),
      );
    } else {
      return Container(); // No action buttons for other statuses
    }
  }

  void _showApprovalDialog() {
    final commentsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Permit'),
        content: TextField(
          controller: commentsController,
          decoration: const InputDecoration(
            labelText: 'Comments (Optional)',
            hintText: 'Add any special instructions or comments',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.permit.status = PermitStatus.approved;
                widget.permit.approvedBy = currentUser.name;
                widget.permit.approvedDate = DateTime.now();
                widget.permit.comments = commentsController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Permit approved successfully')),
              );
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectionDialog() {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Permit'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason for Rejection',
            hintText: 'Provide a reason for rejecting this permit',
          ),
          maxLines: 3,
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
                      content: Text('Please provide a reason for rejection')),
                );
                return;
              }

              setState(() {
                widget.permit.status = PermitStatus.rejected;
                widget.permit.comments = reasonController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Permit rejected')),
              );
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Work'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Confirm that all work has been completed safely and the area has been left in a safe condition.'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
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
                if (notesController.text.isNotEmpty) {
                  widget.permit.comments = notesController.text;
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Work completed successfully')),
              );
            },
            child: const Text('Complete'),
          ),
        ],
      ),
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
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

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

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Permit Statistics',
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
              ],
            ),
          ],
        ),
      ),
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
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // Would save this preference in a real app
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Change Password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Would open change password dialog in a real app
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
