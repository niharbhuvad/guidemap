extension StringExtension on String? {
  String toTitleCase() {
    if (this == null || this!.isEmpty || this!.length < 2) {
      return this!.toUpperCase();
    } else {
      return "${this![0].toUpperCase()}${this!.substring(1).toLowerCase()}";
    }
  }
}

extension DescribeTimeDiff on DateTime {
  String getDifferences() {
    final now = DateTime.now();
    final diff = difference(DateTime(
        now.year, now.month, now.day, now.hour, now.minute, now.second));
    String a;
    if (diff.inHours.abs() > 23) {
      a = switch (diff) {
        Duration(inDays: -1) => "Yesterday",
        Duration(inDays: 1) => "Tomorrow",
        Duration(inDays: 0) => "Today",
        Duration(inDays: int d, isNegative: true) => "${d.abs()} days ago",
        Duration(inDays: int d, isNegative: false) => "$d days from now",
      };
    } else {
      if (diff.inHours.abs() < 24 && diff.inMinutes.abs() > 59) {
        var hrs = diff.inHours;
        a = hrs.isNegative ? "${hrs.abs()} hours ago" : "$hrs hours from now";
      } else {
        var min = diff.inMinutes;
        a = min.isNegative
            ? "${min.abs()} minutes ago"
            : "$min minutes from now";
        if (diff.inSeconds.abs() < 59) {
          var sec = diff.inSeconds;
          a = sec.isNegative
              ? "${sec.abs()} seconds ago"
              : "$sec seconds from now";
        }
      }
    }
    return a;
  }
}

extension HumanReadableDatetime on DateTime {
  List<String> get monthsLong {
    return "January,February,March,April,May,June,July,August,September,October,November,December"
        .split(",");
  }

  List<String> get months {
    return "Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sept,Oct,Nov,Dec".split(",");
  }

  List<String> get daysLong {
    return "Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday"
        .split(",");
  }

  List<String> get days {
    return "Sun,Mon,Tue,Wed,Thu,Fri,Sat".split(",");
  }

  String toHumanReadable() {
    int hr = (hour > 12) ? hour - 12 : hour;
    if (hr == 0) hr = 12;
    String hrOf = (hour < 12) ? "AM" : "PM";
    String min = (minute < 10) ? '0$minute' : minute.toString();
    return "${days[weekday - 1]} $day ${months[month - 1]}, $year at $hr:$min $hrOf";
  }
}
