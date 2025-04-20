import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/mock_data_service.dart';
import '../../utils/helpers.dart';
import '../permits/permits_list_screen.dart';
import '../permits/create_permit_screen.dart';
import '../permits/approval_queue_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/admin_dashboard.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  late List<Widget> _screens;
  late List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();
    _initializeScreens();
  }

  void _initializeScreens() {
    // Initialize screens based on user role
    _screens = [
      const PermitsListScreen(), // Always show permits list first
    ];

    _navItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.list),
        label: 'My Permits',
      ),
    ];

    // Add Create Permit for workers
    if (currentUser.role == UserRole.worker) {
      _screens.add(CreatePermitScreen(
        onPermitCreated: () {
          // This will refresh the entire dashboard including permits list
          setState(() {
            _selectedIndex = 0; // Switch to My Permits tab
            _screens[0] = PermitsListScreen(key: UniqueKey()); // Force rebuild
          });
        },
      ));
      _navItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.add_circle),
        label: 'New Permit',
      ));
    }
    // Add Approvals for supervisors and safety officers
    if (currentUser.role == UserRole.supervisor ||
        currentUser.role == UserRole.safetyOfficer) {
      _screens.add(const ApprovalQueueScreen());
      _navItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.approval),
        label: 'Approvals',
      ));
    }

    // Add Profile for all users
    _screens.add(const ProfileScreen());
    _navItems.add(const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ));

    // Add Admin panel for admins
    if (currentUser.role == UserRole.admin) {
      _screens.add(const AdminDashboard());
      _navItems.add(const BottomNavigationBarItem(
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
        title: Text('PTW System - ${getRoleString(currentUser.role)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _showNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications would appear here')),
    );
  }

  void _confirmLogout() {
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
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
