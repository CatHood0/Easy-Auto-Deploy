// Extensión para formatear la hora
extension DateTimeExtension on DateTime {
  String formatHhMmSs() {
    return '${hour.toString().padLeft(2, '0')}'
        ':${minute.toString().padLeft(2, '0')}'
        ':${second.toString().padLeft(2, '0')}';
  }
}
