import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/api.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_toast.dart';

class FileOvertimeScreen extends StatefulWidget {
  const FileOvertimeScreen({super.key});

  @override
  State<FileOvertimeScreen> createState() => _FileOvertimeScreenState();
}

class _FileOvertimeScreenState extends State<FileOvertimeScreen> {
  final Dio _dio = ApiConfig.createDio();
  DateTime? _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final _reasonCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_date == null || _startTime == null || _endTime == null || _reasonCtrl.text.trim().isEmpty) {
      AppToast.warning(context, 'Please fill all fields');
      return;
    }

    setState(() => _loading = true);
    final nav = Navigator.of(context);

    try {
      await _dio.post('/overtime', data: {
        'date': DateFormat('yyyy-MM-dd').format(_date!),
        'planned_start': '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}',
        'planned_end': '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
        'reason': _reasonCtrl.text.trim(),
      });
      if (!mounted) return;
      AppToast.success(context, 'Overtime request filed', message: 'Awaiting manager approval.');
      nav.pop();
    } on DioException catch (e) {
      if (!mounted) return;
      AppToast.error(context, 'Request failed', message: e.response?.data?['message']);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File Overtime')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  InkWell(
                    onTap: () async {
                      final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 30)), lastDate: DateTime.now().add(const Duration(days: 30)));
                      if (d != null) setState(() => _date = d);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Date', border: OutlineInputBorder()),
                      child: Text(_date != null ? DateFormat('MMM dd, yyyy').format(_date!) : 'Select date'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 18, minute: 0));
                            if (t != null) setState(() => _startTime = t);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Start Time', border: OutlineInputBorder()),
                            child: Text(_startTime?.format(context) ?? 'Select'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 21, minute: 0));
                            if (t != null) setState(() => _endTime = t);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'End Time', border: OutlineInputBorder()),
                            child: Text(_endTime?.format(context) ?? 'Select'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: _reasonCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder(), alignLabelWithHint: true)),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
