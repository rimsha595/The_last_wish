class CurseEngine {
  static String generate() {
    final curses = [
      "Your wish has awakened something...",
      "It is watching you now...",
      "The camera remembers everything...",
      "You should not have done that...",
    ];

    return curses[DateTime.now().millisecondsSinceEpoch % curses.length];
  }
}
