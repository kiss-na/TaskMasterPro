import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:task_manager/data/models/task.dart';
import 'package:task_manager/core/utils/date_utils.dart' as app_date_utils;
import 'package:clean_nepali_calendar/clean_nepali_calendar.dart'; // Added import

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
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<Task>> _groupedTasks;
  late NepaliCalendarController _nepaliCalendarController; // Added controller

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = widget.selectedDate;
    _selectedDay = widget.selectedDate;
    _groupedTasks = {};
    _groupTasks();
    _nepaliCalendarController = NepaliCalendarController(); // Initialize controller
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
        else if (widget.calendarType == 'nepali')
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
    return widget.calendarType == 'nepali'
        ? CleanNepaliCalendar(
            controller: _nepaliCalendarController,
            onDaySelected: (day) {
              widget.onDateSelected(day);
            },
            headerDayBuilder: (_, day) {
              return Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              );
            },
          )
        : Column(
            children: [], // Placeholder, should not reach here based on original code logic.
          );
  }


  bool _hasTaskForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _groupedTasks.containsKey(normalizedDate) && _groupedTasks[normalizedDate]!.isNotEmpty;
  }

  void _changeNepaliMonth(int delta) {
    final currentNepaliDate = NepaliDateTime.fromDateTime(_focusedDay);
    int newMonth = currentNepaliDate.month + delta;
    int newYear = currentNepaliDate.year;

    if (newMonth < 1) {
      newMonth = 12;
      newYear--;
    } else if (newMonth > 12) {
      newMonth = 1;
      newYear++;
    }

    final newNepaliDate = NepaliDateTime(newYear, newMonth, 1);
    final newGregorianDate = newNepaliDate.toDateTime();

    setState(() {
      _focusedDay = newGregorianDate;
    });
  }

  String _getNepaliMonthName(int month) {
    switch (month) {
      case 1:
        return 'Baishakh';
      case 2:
        return 'Jestha';
      case 3:
        return 'Ashadh';
      case 4:
        return 'Shrawan';
      case 5:
        return 'Bhadra';
      case 6:
        return 'Ashwin';
      case 7:
        return 'Kartik';
      case 8:
        return 'Mangsir';
      case 9:
        return 'Poush';
      case 10:
        return 'Magh';
      case 11:
        return 'Falgun';
      case 12:
        return 'Chaitra';
      default:
        return 'Unknown';
    }
  }
  Color? _getHighestPriorityColor(DateTime date) {
    final tasksForDate = _groupedTasks[date] ?? [];
    if (tasksForDate.isEmpty) return null;

    // Find highest priority task
    var highestPriority = TaskPriority.low;
    for (final task in tasksForDate) {
      if (task.priority.index > highestPriority.index) {
        highestPriority = task.priority;
      }
    }

    // Return color based on priority
    switch (highestPriority) {
      case TaskPriority.high:
        return Colors.red[100];
      case TaskPriority.medium:
        return Colors.orange[100];
      case TaskPriority.low:
        return Colors.green[100];
      default:
        return null;
    }
  }
}