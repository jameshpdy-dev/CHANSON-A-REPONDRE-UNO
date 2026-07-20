enum AiApiErrorType {
  configuration,
  connection,
  timeout,
  unauthorized,
  quota,
  rateLimited,
  invalidRequest,
  unsupportedMedia,
  payloadTooLarge,
  server,
  malformedJson,
  emptyResponse,
  cancelled,
}

class AiApiException implements Exception {
  const AiApiException(this.type, this.message, {this.statusCode});
  final AiApiErrorType type;
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}
