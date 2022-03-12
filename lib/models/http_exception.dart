class HttpExtention implements Exception {
  final String message;
  HttpExtention({
    required this.message,
  });

  @override
  String toString() {
    return message;
  }
}
