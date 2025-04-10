class RepositoryException implements Exception {
  final String message;
  final dynamic originalException;
  RepositoryException(this.message, [this.originalException]);

  @override
  String toString() {
    return 'RepositoryException: $message ${originalException != null ? '(Original: $originalException)' : ''}';
  }
}
