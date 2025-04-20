import 'package:flutter/material.dart';
import '../../models/permit.dart';
import '../../services/mock_data_service.dart';

class CreatePermitScreen extends StatefulWidget {
  final VoidCallback? onPermitCreated;
  const CreatePermitScreen({Key? key, this.onPermitCreated}) : super(key: key);

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

      // Call the callback if it exists
      if (widget.onPermitCreated != null) {
        widget.onPermitCreated!();
      }

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
