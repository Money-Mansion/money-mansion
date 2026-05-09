class UpdateException implements Exception {
  final String message;
  final Object? cause;

  const UpdateException(this.message, {this.cause});

  @override
  String toString() => message;
}
