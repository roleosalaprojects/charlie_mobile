import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/leave_provider.dart';
import '../../utils/helpers.dart';

class FileLeaveScreen extends StatefulWidget {
  const FileLeaveScreen({super.key});

  @override
  State<FileLeaveScreen> createState() => _FileLeaveScreenState();
}

class _FileLeaveScreenState extends State<FileLeaveScreen> {
  int? _selectedTypeId;
  DateTime? _startDate;
  DateTime? _endDate;
  final _reasonCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lp = context.read<LeaveProvider>();
      if (lp.types.isEmpty) lp.fetchTypes();

      // Check if a date was passed as argument
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is DateTime) {
        setState(() {
          _startDate = args;
          _endDate = args;
        });
      }
    });
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart ? (_startDate ?? DateTime.now().add(const Duration(days: 1))) : (_endDate ?? _startDate ?? DateTime.now().add(const Duration(days: 1)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) _endDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedTypeId == null || _startDate == null || _endDate == null || _reasonCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields'), backgroundColor: AppColors.danger),
      );
      return;
    }

    final lp = context.read<LeaveProvider>();
    final fmt = DateFormat('yyyy-MM-dd');
    final ok = await lp.fileLeave(
      leaveTypeId: _selectedTypeId!,
      startDate: fmt.format(_startDate!),
      endDate: fmt.format(_endDate!),
      reason: _reasonCtrl.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave application filed!'), backgroundColor: AppColors.success),
      );
      lp.fetchBalances();
      lp.fetchApplications(refresh: true);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lp.error ?? 'Failed'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LeaveProvider>();
    final fmt = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('File Leave')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  // Leave type
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Leave Type', border: OutlineInputBorder()),
                    items: lp.types.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                    onChanged: (v) => setState(() => _selectedTypeId = v),
                  ),
                  const SizedBox(height: 16),

                  // Dates
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickDate(true),
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Start Date', border: OutlineInputBorder()),
                            child: Text(_startDate != null ? fmt.format(_startDate!) : 'Select', style: const TextStyle(fontSize: 14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickDate(false),
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'End Date', border: OutlineInputBorder()),
                            child: Text(_endDate != null ? fmt.format(_endDate!) : 'Select', style: const TextStyle(fontSize: 14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Reason
                  TextField(
                    controller: _reasonCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder(), alignLabelWithHint: true),
                  ),
                ],
              ),
            ),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: lp.loading ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: lp.loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Submit Leave Application'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
