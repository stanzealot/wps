import '../models/user.dart';
import '../models/permit.dart';

// Mock Users Data
final List<User> mockUsers = [
  User(id: 'user1', name: 'John Doe', role: UserRole.worker),
  User(id: 'user2', name: 'Jane Smith', role: UserRole.supervisor),
  User(id: 'user3', name: 'Mike Johnson', role: UserRole.safetyOfficer),
  User(id: 'user4', name: 'Sarah Williams', role: UserRole.admin),
];

// Current User (will be set during login)
User currentUser = mockUsers[0];

// Mock Permits Data
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
