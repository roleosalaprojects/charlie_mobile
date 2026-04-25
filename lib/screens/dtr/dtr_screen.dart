import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/dtr.dart';
import '../../providers/dtr_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_toast.dart';

class DtrScreen extends StatefulWidget {
  const DtrScreen({super.key});

  @override
  State<DtrScreen> createState() => _DtrScreenState();
}

class _DtrScreenState extends State<DtrScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, DailyTimeRecord> _dtrMap = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMonth();
      context.read<DtrProvider>().fetchToday();
    });
  }

  Future<void> _loadMonth() async {
    final dtr = context.read<DtrProvider>();
    await dtr.fetchHistory(month: _focusedDay.month, year: _focusedDay.year);
    _buildMap(dtr.history);
  }

  void _buildMap(List<DailyTimeRecord> records) {
    _dtrMap = {};
    for (final r in records) {
      try {
        final date = DateTime.parse(r.date.substring(0, 10));
        _dtrMap[DateTime.utc(date.year, date.month, date.day)] = r;
      } catch (_) {}
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dtr = context.watch<DtrProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export CSV',
            onPressed: () async {
              final ok = await dtr.exportDtr(month: _focusedDay.month, year: _focusedDay.year);
              if (!context.mounted) return;
              if (!ok) AppToast.error(context, 'Export failed');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await dtr.fetchToday();
          await _loadMonth();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Today's punches (read-only)
            if (dtr.today != null && dtr.today!.clockIn != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Today', style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(child: _chip('In', _shortTime(dtr.today!.clockIn!), AppColors.success)),
                          if (dtr.today!.breakStart != null)
                            Flexible(child: Padding(padding: const EdgeInsets.only(left: 8), child: _chip('B.Out', _shortTime(dtr.today!.breakStart!), AppColors.warning))),
                          if (dtr.today!.breakEnd != null)
                            Flexible(child: Padding(padding: const EdgeInsets.only(left: 8), child: _chip('B.In', _shortTime(dtr.today!.breakEnd!), AppColors.info))),
                          Flexible(child: Padding(padding: const EdgeInsets.only(left: 8), child: _chip('Out', _shortTime(dtr.today!.clockOut ?? '--'), AppColors.danger))),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                color: AppColors.info.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Clock in/out at the office kiosk or web portal. This app is view-only for attendance.',
                            style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Calendar
            Card(
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
                  _showDayDetail(selected);
                },
                onPageChanged: (focused) {
                  _focusedDay = focused;
                  _loadMonth();
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.3), shape: BoxShape.circle),
                  selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  markerDecoration: const BoxDecoration(shape: BoxShape.circle),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final key = DateTime.utc(date.year, date.month, date.day);
                    final record = _dtrMap[key];
                    if (record == null) return null;
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor(record.status),
                        ),
                      ),
                    );
                  },
                ),
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
              ),
            ),
            const SizedBox(height: 16),

            // Selected day detail
            if (_selectedDay != null) _buildDayDetail(),
          ],
        ),
      ),
    );
  }

  Widget _buildDayDetail() {
    final key = DateTime.utc(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final record = _dtrMap[key];

    if (record == null) {
      final isFuture = _selectedDay!.isAfter(DateTime.now());
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(Fmt.date(_selectedDay!.toIso8601String()), style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(isFuture ? 'Tap to file leave for this date' : 'No record', style: TextStyle(color: Colors.grey[500])),
              if (isFuture) ...[
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/file-leave', arguments: _selectedDay),
                  icon: const Icon(Icons.event_note),
                  label: const Text('File Leave'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(Fmt.date(record.date), style: const TextStyle(fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor(record.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(record.status.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor(record.status))),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _detailItem('Clock In', _shortTime(record.clockIn ?? '--'))),
                Expanded(child: _detailItem('Clock Out', _shortTime(record.clockOut ?? '--'))),
                Expanded(child: _detailItem('Hours', record.hoursWorked?.toStringAsFixed(1) ?? '--')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _chip(String label, String time, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(time, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ),
      ],
    );
  }

  void _showDayDetail(DateTime day) {
    // Detail card below calendar handles display
  }

  String _shortTime(String raw) {
    if (raw == '--') return raw;
    // If already short (e.g. "09:00 AM"), return as-is
    if (!raw.contains('T') && !raw.contains('-')) return raw;
    // Parse ISO datetime
    try {
      final dt = DateTime.parse(raw).toLocal();
      final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '${h.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $ampm';
    } catch (_) {
      return raw;
    }
  }
}
