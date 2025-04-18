import 'package:flutter/material.dart';
import '../../models/permit.dart';
import '../../models/user.dart';
import '../../services/mock_data_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/status_chip.dart';

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
          if (_shouldShowAdminActions())
            PopupMenuButton<String>(
              onSelected: (value) => _handlePopupAction(value, context),
              itemBuilder: (context) => _buildPopupMenuItems(),
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

  bool _shouldShowAdminActions() {
    return currentUser.role == UserRole.admin ||
        currentUser.role == UserRole.safetyOfficer ||
        currentUser.role == UserRole.supervisor;
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems() {
    return [
      if (widget.permit.status == PermitStatus.pending)
        const PopupMenuItem(
          value: 'edit',
          child: Text('Edit Permit'),
        ),
      const PopupMenuItem(
        value: 'delete',
        child: Text('Delete Permit'),
      ),
    ];
  }

  void _handlePopupAction(String value, BuildContext context) {
    switch (value) {
      case 'edit':
        _editPermit();
        break;
      case 'delete':
        _deletePermit(context);
        break;
    }
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
                  StatusChip(status: widget.permit.status),
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.permit.approvedDate != null)
                      Text(
                        formatDate(widget.permit.approvedDate!),
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
            _buildDetailRow('Start Date', formatDate(widget.permit.startDate)),
            _buildDetailRow('End Date', formatDate(widget.permit.endDate)),
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
            Column(
              children: widget.permit.hazards
                  .map((hazard) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text(hazard),
                          ],
                        ),
                      ))
                  .toList(),
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
            Column(
              children: widget.permit.precautions
                  .map((precaution) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(precaution),
                          ],
                        ),
                      ))
                  .toList(),
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
    if (widget.permit.status == PermitStatus.pending) {
      return _buildPendingActions();
    } else if (widget.permit.status == PermitStatus.approved &&
        currentUser.role == UserRole.worker &&
        widget.permit.requesterId == currentUser.id) {
      return _buildStartWorkButton();
    } else if (widget.permit.status == PermitStatus.inProgress &&
        currentUser.role == UserRole.worker &&
        widget.permit.requesterId == currentUser.id) {
      return _buildCompleteWorkButton();
    }
    return Container();
  }

  Widget _buildPendingActions() {
    if (currentUser.role == UserRole.supervisor ||
        currentUser.role == UserRole.safetyOfficer ||
        currentUser.role == UserRole.admin) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: _showApprovalDialog,
              child: const Text('Approve'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: _showRejectionDialog,
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
              onPressed: _editPermit,
              child: const Text('Edit'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => _deletePermit(context),
              child: const Text('Withdraw'),
            ),
          ),
        ],
      );
    }
    return Container();
  }

  Widget _buildStartWorkButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() => widget.permit.status = PermitStatus.inProgress);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Work started')),
        );
      },
      child: const Text('Start Work'),
    );
  }

  Widget _buildCompleteWorkButton() {
    return ElevatedButton(
      onPressed: _showCompletionDialog,
      child: const Text('Complete Work'),
    );
  }

  void _showApprovalDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildApprovalDialog(context),
    );
  }

  AlertDialog _buildApprovalDialog(BuildContext context) {
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
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () => _approvePermit(context),
          child: const Text('Approve'),
        ),
      ],
    );
  }

  void _approvePermit(BuildContext context) {
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
  }

  void _showRejectionDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildRejectionDialog(context),
    );
  }

  AlertDialog _buildRejectionDialog(BuildContext context) {
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
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => _rejectPermit(context),
          child: const Text('Reject'),
        ),
      ],
    );
  }

  void _rejectPermit(BuildContext context) {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a reason for rejection')),
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
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildCompletionDialog(context),
    );
  }

  AlertDialog _buildCompletionDialog(BuildContext context) {
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
          onPressed: () => _completeWork(context),
          child: const Text('Complete'),
        ),
      ],
    );
  }

  void _completeWork(BuildContext context) {
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
  }

  void _editPermit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Edit permit functionality would open here')),
    );
  }

  void _deletePermit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildDeleteDialog(context),
    );
  }

  AlertDialog _buildDeleteDialog(BuildContext context) {
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
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => _confirmDelete(context),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    mockPermits.remove(widget.permit);
    Navigator.pop(context);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Permit deleted successfully'),
        backgroundColor: Colors.red,
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
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getRequesterName() {
    final requester = mockUsers.firstWhere(
      (user) => user.id == widget.permit.requesterId,
      orElse: () => User(id: 'unknown', name: 'Unknown', role: UserRole.worker),
    );
    return requester.name;
  }
}
