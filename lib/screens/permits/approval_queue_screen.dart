import 'package:flutter/material.dart';
import 'package:wps/screens/permits/permit_detail_screen.dart';
import '../../models/permit.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/status_chip.dart';

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
