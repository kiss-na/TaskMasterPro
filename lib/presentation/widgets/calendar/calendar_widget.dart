import 'package:flutter/material.dart';
import 'package:clean_nepali_calendar/clean_nepali_calendar.dart';
import 'package:task_manager/data/models/task.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  final String calendarType;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final List<Task>? tasks;

  const CalendarWidget({
    Key? key,
    required this.calendarType,
    required this.selectedDate,
    required this.onDateSelected,
    this.tasks,
  }) : super(key: key);

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late NepaliCalendarController _nepaliCalendarController;
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<Task>> _groupedTasks;


  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = widget.selectedDate;
    _selectedDay = widget.selectedDate;
    _groupedTasks = {};
    _groupTasks();
    _nepaliCalendarController = NepaliCalendarController();
  }

  @override
  void didUpdateWidget(CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tasks != widget.tasks) {
      _groupTasks();
    }
    if (oldWidget.selectedDate != widget.selectedDate) {
      setState(() {
        _selectedDay = widget.selectedDate;
        _focusedDay = widget.selectedDate;
      });
    }
  }

  void _groupTasks() {
    if (widget.tasks == null) return;
    _groupedTasks = {};
    for (final task in widget.tasks!) {
      if (task.dueDate != null) {
        final date = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );
        if (!_groupedTasks.containsKey(date)) {
          _groupedTasks[date] = [];
        }
        _groupedTasks[date]!.add(task);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.calendarType == 'gregorian')
          _buildGregorianCalendar()
        else
          _buildNepaliCalendar(),
      ],
    );
  }

  Widget _buildGregorianCalendar() {
    return TableCalendar<Task>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      eventLoader: (day) {
        final date = DateTime(day.year, day.month, day.day);
        return _groupedTasks[date] ?? [];
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        widget.onDateSelected(selectedDay);
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonShowsNext: false,
        formatButtonDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        formatButtonTextStyle: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildNepaliCalendar() {
    return CleanNepaliCalendar(
      controller: _nepaliCalendarController,
      language: Language.nepali,
      onDaySelected: (selectedDay) {
        widget.onDateSelected(selectedDay);
      },
      events: widget.tasks?.where((task) => task.dueDate != null).map(
        (task) => NepaliCalendarEvent(
          title: task.title,
          date: task.dueDate!,
          color: task.color ?? Colors.blue,
        ),
      ).toList() ?? [],
      headerStyle: HeaderStyle(
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      dayStyle: DayStyle(
        holidayTextStyle: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
        weekendTextStyle: TextStyle(
          color: Colors.orange[800],
        ),
      ),
      eventCountBuilder: (count) => Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
      ),
      onEventDayTap: (events, date) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Events on ${date.toString()}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: events.map((event) => ListTile(
                title: Text(event.title),
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: event.color,
                    shape: BoxShape.circle,
                  ),
                ),
              )).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
  @override 
  void dispose() {
    _nepaliCalendarController.dispose();
    super.dispose();
  }
}