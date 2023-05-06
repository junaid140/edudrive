import 'package:intl/intl.dart';

String getTimeAgoString({String time = "2023-04-07T14:59:04.542Z", DateTime? toTime}) {

  if (toTime!.difference(DateTime.parse(time)).inSeconds < 60) {
    return "Now";
  } else if (toTime.difference(DateTime.parse(time)).inMinutes < 60) {
    final minutes = toTime.difference(DateTime.parse(time)).inMinutes;
    return "$minutes ${Intl.plural(minutes, one: 'minute', other: 'minutes')} ";
  } else if (toTime.difference(DateTime.parse(time)).inHours < 24) {
    final hours = toTime.difference(DateTime.parse(time)).inHours;
    return "$hours ${Intl.plural(hours, one: 'hour', other: 'hours')} ";
  } else if (toTime.difference(DateTime.parse(time)).inDays < 30) {
    if (toTime.difference(DateTime.parse(time)).inDays < 7) {
      final days = toTime.difference(DateTime.parse(time)).inDays;
      return "$days ${Intl.plural(days, one: 'day', other: 'days')} ";
    } else {
      final weeks = (toTime.difference(DateTime.parse(time)).inDays / 7).round();
      return "$weeks ${Intl.plural(weeks, one: 'week', other: 'weeks')} ";
    }
  } else if (toTime.difference(DateTime.parse(time)).inDays < 365) {
    final months = (toTime.difference(DateTime.parse(time)).inDays / 30).round();
    return "$months ${Intl.plural(months, one: 'month', other: 'months')} ";
  } else {
    final years = (toTime.difference(DateTime.parse(time)).inDays / 365).round();
    return "$years ${Intl.plural(years, one: 'year', other: 'years')} ";
  }
}
