import 'package:intl/intl.dart';
import 'package:nepali_utils/nepali_utils.dart';

class AppDateUtils {
  // Private constructor to prevent instantiation
  AppDateUtils._();

  static const String defaultDateFormat = 'yyyy-MM-dd';
  static const String defaultTimeFormat = 'HH:mm';
  static const String defaultDateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String readableDateFormat = 'MMM dd, yyyy';
  static const String readableTimeFormat = 'h:mm a';
  static const String readableDateTimeFormat = 'MMM dd, yyyy h:mm a';
  
  // Get formatted date string
  static String formatDate(DateTime date, {String format = defaultDateFormat}) {
    return DateFormat(format).format(date);
  }
  
  // Get formatted time string
  static String formatTime(DateTime time, {String format = defaultTimeFormat}) {
    return DateFormat(format).format(time);
  }
  
  // Get formatted date and time string
  static String formatDateTime(DateTime dateTime, {String format = defaultDateTimeFormat}) {
    return DateFormat(format).format(dateTime);
  }
  
  // Get readable date string (e.g., Jan 01, 2023)
  static String getReadableDate(DateTime date) {
    return DateFormat(readableDateFormat).format(date);
  }
  
  // Get readable time string (e.g., 3:30 PM)
  static String getReadableTime(DateTime time) {
    return DateFormat(readableTimeFormat).format(time);
  }
  
  // Get readable date and time string (e.g., Jan 01, 2023 3:30 PM)
  static String getReadableDateTime(DateTime dateTime) {
    return DateFormat(readableDateTimeFormat).format(dateTime);
  }
  
  // Get relative time (e.g., Today, Yesterday, Tomorrow, or date)
  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final inputDate = DateTime(date.year, date.month, date.day);
    
    if (inputDate == today) {
      return 'Today';
    } else if (inputDate == yesterday) {
      return 'Yesterday';
    } else if (inputDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return getReadableDate(date);
    }
  }
  
  // Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
  
  // Convert Gregorian date to Nepali date
  static String gregorianToNepaliDate(DateTime date) {
    try {
      final nepaliDateTime = NepaliDateTime.fromDateTime(date);
      return '${nepaliDateTime.year}-${nepaliDateTime.month}-${nepaliDateTime.day}';
    } catch (e) {
      return 'Invalid date';
    }
  }
  
  // Format Nepali date
  static String formatNepaliDate(NepaliDateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  // Get the number of days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }
  
  // Get the number of months between two dates
  static int monthsBetween(DateTime from, DateTime to) {
    return (to.year - from.year) * 12 + to.month - from.month;
  }
  
  // Check if a date is in the past
  static bool isPast(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(now);
  }
  
  // Check if a date is in the future
  static bool isFuture(DateTime date) {
    final now = DateTime.now();
    return date.isAfter(now);
  }
  
  // Get the start of a day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  // Get the end of a day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
}
