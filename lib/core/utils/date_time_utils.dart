import 'package:intl/intl.dart';
import 'package:flutter/material.dart'; // ADD THIS IMPORT

class DateTimeUtils {
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return formatDate(date);
    }
  }

  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime startOfWeek([DateTime? date]) {
    final currentDate = date ?? DateTime.now();
    return currentDate.subtract(Duration(days: currentDate.weekday - 1));
  }

  static DateTime endOfWeek([DateTime? date]) {
    final currentDate = date ?? DateTime.now();
    return currentDate.add(Duration(days: DateTime.daysPerWeek - currentDate.weekday));
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static List<DateTime> getDaysInWeek([DateTime? date]) {
    final start = startOfWeek(date);
    return List.generate(7, (index) => start.add(Duration(days: index)));
  }

  static DateTime timeOfDayToDateTime(TimeOfDay time) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  static TimeOfDay dateTimeToTimeOfDay(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  static String formatTimeRange(DateTime start, DateTime end) {
    return '${formatTime(start)} - ${formatTime(end)}';
  }

  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}