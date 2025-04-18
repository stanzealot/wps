import '../models/user.dart';

enum PermitStatus { pending, approved, inProgress, completed, rejected }

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
