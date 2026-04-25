import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../config/api.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_toast.dart';

class FileExpenseScreen extends StatefulWidget {
  const FileExpenseScreen({super.key});

  @override
  State<FileExpenseScreen> createState() => _FileExpenseScreenState();
}

class _FileExpenseScreenState extends State<FileExpenseScreen> {
  final Dio _dio = ApiConfig.createDio();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String? _category;
  DateTime? _date;
  XFile? _receipt;
  bool _loading = false;

  static const _categories = ['travel', 'meal', 'transportation', 'office_supplies', 'training', 'medical', 'communication', 'other'];

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickReceipt() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Camera'), onTap: () => Navigator.pop(ctx, ImageSource.camera)),
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('Gallery'), onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await ImagePicker().pickImage(source: source, maxWidth: 1200, imageQuality: 80);
    if (picked != null) setState(() => _receipt = picked);
  }

  Future<void> _submit() async {
    if (_category == null || _date == null || _descCtrl.text.trim().isEmpty || _amountCtrl.text.trim().isEmpty) {
      AppToast.warning(context, 'Please fill all fields');
      return;
    }

    setState(() => _loading = true);
    final nav = Navigator.of(context);

    try {
      final formData = FormData.fromMap({
        'category': _category,
        'expense_date': DateFormat('yyyy-MM-dd').format(_date!),
        'description': _descCtrl.text.trim(),
        'amount': _amountCtrl.text.trim(),
        if (_receipt != null) 'receipt': await MultipartFile.fromFile(_receipt!.path, filename: _receipt!.name),
      });
      await _dio.post('/expenses', data: formData, options: Options(contentType: 'multipart/form-data'));
      if (!mounted) return;
      AppToast.success(context, 'Expense claim submitted', message: 'Your manager will review it shortly.');
      nav.pop();
    } on DioException catch (e) {
      if (!mounted) return;
      AppToast.error(context, 'Submission failed', message: e.response?.data?['message']);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File Expense Claim')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.replaceAll('_', ' ').split(' ').map((w) => '${w[0].toUpperCase()}${w.substring(1)}').join(' ')))).toList(),
                    onChanged: (v) => setState(() => _category = v),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 90)), lastDate: DateTime.now());
                      if (d != null) setState(() => _date = d);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Expense Date', border: OutlineInputBorder()),
                      child: Text(_date != null ? DateFormat('MMM dd, yyyy').format(_date!) : 'Select date'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  TextField(controller: _amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount', prefixText: 'P ', border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _pickReceipt,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(_receipt != null ? _receipt!.name : 'Attach Receipt (optional)'),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Submit Claim'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
