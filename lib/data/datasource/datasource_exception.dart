class DataSourceException implements Exception {
  final String message;
  final dynamic originalException;
  DataSourceException(this.message, [this.originalException]);

  @override
  String toString() {
    return 'DataSourceException: $message ${originalException != null ? '(Original: $originalException)' : ''}';
  }
}
