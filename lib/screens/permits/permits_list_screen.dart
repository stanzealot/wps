import 'package:flutter/material.dart';
import 'package:wps/screens/permits/permit_detail_screen.dart';
import '../../models/permit.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/status_chip.dart';

class PermitsListScreen extends StatefulWidget {
  const PermitsListScreen({Key? key}) : super(key: key);

  @override
  State<PermitsListScreen> createState() => _PermitsListScreenState();
}

class _PermitsListScreenState extends State<PermitsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Permit> _permits;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _permits = List.from(mockPermits);
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
