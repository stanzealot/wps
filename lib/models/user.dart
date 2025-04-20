enum UserRole { worker, supervisor, safetyOfficer, admin }

class User {
  final String id;
  String name;
  UserRole role;

  User({required this.id, required this.name, required this.role});
}
