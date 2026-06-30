import 'package:shared_preferences/shared_preferences.dart';

class TimerService {
  static const String _key = "lastWishTime";

  // Change this to Duration(hours: 24) when you're done testing.
  static const Duration lockDuration = Duration(hours: 24);

  /// Save current time when user submits a wish
  static Future<void> saveWishTime() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_key, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get saved timer start time
  static Future<DateTime?> getStartTime() async {
    final prefs = await SharedPreferences.getInstance();

    final time = prefs.getInt(_key);

    if (time == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(time);
  }

  /// Returns true if the app can be used.
  /// If the timer has expired, it automatically clears the saved timer.
  static Future<bool> canUseApp() async {
    final startTime = await getStartTime();

    if (startTime == null) {
      return true;
    }

    final endTime = startTime.add(lockDuration);

    if (DateTime.now().isAfter(endTime)) {
      await clear(); // Remove expired timer
      return true;
    }

    return false;
  }

  /// Remaining seconds
  static Future<int> remainingSeconds() async {
    final startTime = await getStartTime();

    if (startTime == null) {
      return 0;
    }

    final endTime = startTime.add(lockDuration);

    final seconds = endTime.difference(DateTime.now()).inSeconds;

    if (seconds <= 0) {
      await clear();
      return 0;
    }

    return seconds;
  }

  /// Remaining duration
  static Future<Duration> remainingDuration() async {
    final startTime = await getStartTime();

    if (startTime == null) {
      return Duration.zero;
    }

    final endTime = startTime.add(lockDuration);

    final duration = endTime.difference(DateTime.now());

    if (duration.isNegative) {
      await clear();
      return Duration.zero;
    }

    return duration;
  }

  /// Remove saved timer
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
