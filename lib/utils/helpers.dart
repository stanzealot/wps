import '../models/user.dart';

String getRoleString(UserRole role) {
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

String formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
