class AiHealthStatus {
  const AiHealthStatus({
    required this.status,
    required this.service,
    required this.version,
  });
  final String status;
  final String service;
  final String version;

  factory AiHealthStatus.fromJson(Map<String, dynamic> json) {
    final status = json['status'];
    if (status is! String || status.isEmpty) {
      throw const FormatException('Missing health status.');
    }
    return AiHealthStatus(
      status: status,
      service: json['service'] is String
          ? json['service'] as String
          : 'card-ai',
      version: json['version'] is String
          ? json['version'] as String
          : 'unknown',
    );
  }
}
