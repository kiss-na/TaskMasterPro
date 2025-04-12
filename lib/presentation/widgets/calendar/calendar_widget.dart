import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:task_manager/data/models/task.dart';
import 'package:task_manager/core/utils/date_utils.dart' as app_date_utils;

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

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = widget.selectedDate;
    _selectedDay = widget.selectedDate;
    _groupedTasks = {};
    _groupTasks();
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
    // Convert selected Gregorian date to Nepali date
    final nepaliDate = NepaliDateTime.fromDateTime(_selectedDay);
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeNepaliMonth(-1),
              ),
              Text(
                '${_getNepaliMonthName(nepaliDate.month)} ${nepaliDate.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _changeNepaliMonth(1),
              ),
            ],
          ),
        ),
        _buildNepaliCalendarGrid(nepaliDate),
      ],
    );
  }

  Widget _buildNepaliCalendarGrid(NepaliDateTime nepaliDate) {
    // Get the first day of the month
    final firstDay = NepaliDateTime(nepaliDate.year, nepaliDate.month, 1);
    final firstDayWeekday = firstDay.weekday % 7; // 0 for Sunday, 6 for Saturday
    
    // Get the number of days in the month
    final daysInMonth = NepaliDateTime.getDaysInMonth(nepaliDate.year, nepaliDate.month);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              'Sun',
              'Mon',
              'Tue',
              'Wed',
              'Thu',
              'Fri',
              'Sat',
            ].map((day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
            ),
            itemCount: firstDayWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < firstDayWeekday) {
                return Container(); // Empty cell for days before the 1st of the month
              }
              
              final dayNumber = index - firstDayWeekday + 1;
              final nepaliDayDate = NepaliDateTime(nepaliDate.year, nepaliDate.month, dayNumber);
              final gregorianDate = nepaliDayDate.toDateTime();
              
              final isSelected = nepaliDate.day == dayNumber;
              final isToday = NepaliDateTime.now().year == nepaliDate.year &&
                              NepaliDateTime.now().month == nepaliDate.month &&
                              NepaliDateTime.now().day == dayNumber;
              
              // Check if there are tasks for this day
              final hasTask = _hasTaskForDate(gregorianDate);
              
              return GestureDetector(
                onTap: () {
                  final selectedGregorianDate = nepaliDayDate.toDateTime();
                  setState(() {
                    _selectedDay = selectedGregorianDate;
                    _focusedDay = selectedGregorianDate;
                  });
                  widget.onDateSelected(selectedGregorianDate);
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Theme.of(context).primaryColor 
                        : isToday 
                            ? Theme.of(context).primaryColor.withOpacity(0.3)
                            : _getHighestPriorityColor(gregorianDate),
                    borderRadius: BorderRadius.circular(8),
                    border: isToday && !isSelected
                        ? Border.all(color: Theme.of(context).primaryColor)
                        : null,
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          dayNumber.toString(),
                          style: TextStyle(
                            color: isSelected 
                                ? Colors.white 
                                : null,
                            fontWeight: isSelected || isToday 
                                ? FontWeight.bold 
                                : null,
                          ),
                        ),
                      ),
                      if (hasTask)
                        Positioned(
                          bottom: 4,
                          right: 0,
                          left: 0,
                          child: Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? Colors.white 
                                    : Theme.of(context).colorScheme.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
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
      case 1: return 'Baishakh';
      case 2: return 'Jestha';
      case 3: return 'Ashadh';
      case 4: return 'Shrawan';
      case 5: return 'Bhadra';
      case 6: return 'Ashwin';
      case 7: return 'Kartik';
      case 8: return 'Mangsir';
      case 9: return 'Poush';
      case 10: return 'Magh';
      case 11: return 'Falgun';
      case 12: return 'Chaitra';
      default: return 'Unknown';
    }
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
