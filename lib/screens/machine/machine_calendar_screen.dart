import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../../controllers/machine_controller.dart';
import 'booking_detail_screen.dart';

class MachineCalendarScreen extends StatefulWidget {
  const MachineCalendarScreen({super.key});

  @override
  State<MachineCalendarScreen> createState() => _MachineCalendarScreenState();
}

class _MachineCalendarScreenState extends State<MachineCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    context.read<MachineController>().fetchCalendarData();
  }

  @override
  Widget build(BuildContext context) {
    final events = context.watch<MachineController>().calendarEvents;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Lịch Trình Thuê Máy'), elevation: 0),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            // Hiển thị dấu chấm nếu ngày đó có đơn hàng
            eventLoader: (day) {
              final dayOnly = DateTime(day.year, day.month, day.day);
              return events[dayOnly] ?? [];
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Color(0x330F5C45),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xFF0F5C45),
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Divider(),
          Expanded(child: _buildEventList(events)),
        ],
      ),
    );
  }

  Widget _buildEventList(Map<DateTime, List<dynamic>> events) {
    final dayOnly = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );
    final dayEvents = events[dayOnly] ?? [];

    if (dayEvents.isEmpty) {
      return const Center(child: Text('Không có lịch trình trong ngày này.'));
    }

    return ListView.builder(
      itemCount: dayEvents.length,
      itemBuilder: (context, index) {
        final ev = dayEvents[index];
        return ListTile(
          onTap: () {
            // KHI BẤM VÀO ĐƠN TRÊN LỊCH -> NHẢY SANG CHI TIẾT
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingDetailScreen(booking: ev),
              ),
            );
          },
          leading: const Icon(Icons.circle, size: 12, color: Colors.orange),
          title: Text(
            ev['MachineType'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('Trạng thái: ${ev['Status']}'),
          trailing: const Icon(
            Icons.chevron_right,
          ), // Thêm icon mũi tên để báo hiệu bấm được
        );
      },
    );
  }
}
