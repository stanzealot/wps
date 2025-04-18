import 'package:flutter/material.dart';
import '../models/permit.dart';

class StatusChip extends StatelessWidget {
  final PermitStatus status;

  const StatusChip({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}
