enum LogLevel { info, success, error, warning }

class LogEntry {
  final String message;
  final LogLevel level;
  LogEntry(this.message, this.level);
}
