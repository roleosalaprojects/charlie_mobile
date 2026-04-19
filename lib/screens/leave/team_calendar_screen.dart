import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../config/api.dart';
import '../../utils/helpers.dart';

class TeamCalendarScreen extends StatefulWidget {
  const TeamCalendarScreen({super.key});

  @override
  State<TeamCalendarScreen> createState() => _TeamCalendarScreenState();
}

class _TeamCalendarScreenState extends State<TeamCalendarScreen> {
  final Dio _dio = ApiConfig.createDio();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _leaves = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadMonth();
  }

  Future<void> _loadMonth() async {
    setState(() => _loading = true);
    try {
      final res = await _dio.get('/leaves/team-calendar', queryParameters: {
        'month': _focusedDay.month,
        'year': _focusedDay.year,
      });
      _leaves = List<Map<String, dynamic>>.from(res.data['data']);
    } catch (_) {}
    setState(() => _loading = false);
  }

  List<Map<String, dynamic>> _leavesForDay(DateTime day) {
    final dayStr = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    return _leaves.where((l) {
      return dayStr.compareTo(l['start_date']) >= 0 && dayStr.compareTo(l['end_date']) <= 0;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team Leave Calendar')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: TableCalendar(
              firstDay: DateTime.utc(2025, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              onPageChanged: (focused) {
                _focusedDay = focused;
                _loadMonth();
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.3), shape: BoxShape.circle),
                selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  final count = _leavesForDay(date).length;
                  if (count == 0) return null;
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(8)),
                      child: Text('$count', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  );
                },
              ),
              headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          // Selected day leave list
          Expanded(
            child: _selectedDay == null
                ? const Center(child: Text('Tap a day to see who\'s on leave', style: TextStyle(color: Colors.grey)))
                : _buildDayLeaves(),
          ),
        ],
      ),
    );
  }

  Widget _buildDayLeaves() {
    final leaves = _leavesForDay(_selectedDay!);
    if (leaves.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 48, color: Colors.green[300]),
            const SizedBox(height: 8),
            Text('${Fmt.date(_selectedDay!.toIso8601String())}\nNo one on leave',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: leaves.length,
      itemBuilder: (context, i) {
        final l = leaves[i];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.warning.withValues(alpha: 0.15),
              child: const Icon(Icons.event_busy, color: AppColors.warning),
            ),
            title: Text(l['employee_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${l['leave_type']} - ${l['total_days']} day(s)'),
            trailing: Text('${l['start_date']} - ${l['end_date']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ),
        );
      },
    );
  }
}
