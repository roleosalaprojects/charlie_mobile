import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../config/api.dart';
import '../../utils/helpers.dart';
import '../../widgets/empty_state.dart';

class OvertimeScreen extends StatefulWidget {
  const OvertimeScreen({super.key});

  @override
  State<OvertimeScreen> createState() => _OvertimeScreenState();
}

class _OvertimeScreenState extends State<OvertimeScreen> {
  final Dio _dio = ApiConfig.createDio();
  List<dynamic> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await _dio.get('/overtime');
      _requests = res.data['data'] ?? [];
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Overtime Requests')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab-file-overtime',
        onPressed: () async {
          await Navigator.pushNamed(context, '/file-overtime');
          _fetch();
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _fetch,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _requests.isEmpty
                ? ListView(children: const [EmptyState(icon: Icons.schedule_outlined, title: 'No overtime requests')])
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _requests.length,
                    itemBuilder: (_, i) {
                      final o = _requests[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: statusColor(o['status'] ?? '').withValues(alpha: 0.15),
                            child: Icon(Icons.schedule, size: 18, color: statusColor(o['status'] ?? '')),
                          ),
                          title: Text(o['request_no'] ?? '#${o['id']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: Text('${Fmt.date(o['date'])} - ${o['planned_hours'] ?? 0}hrs - ${o['reason'] ?? ''}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor(o['status'] ?? '').withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text((o['status'] ?? '').toString().toUpperCase(),
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor(o['status'] ?? ''))),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
