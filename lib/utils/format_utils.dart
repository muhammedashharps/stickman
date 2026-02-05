String formatDuration(int minutes) {
  if (minutes < 60) {
    return '$minutes min';
  } else {
    final int hours = minutes ~/ 60;
    final int mins = minutes % 60;
    if (mins == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${mins}m';
    }
  }
}
