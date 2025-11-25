part of 'http_api.dart';

/// Represents a response from an HTTP API call, including success status, data, and error details.
///
/// [TData] is the type of the expected data payload. Use this class to standardize API responses
/// and error handling throughout the client infrastructure.
class HttpApiResponse<TData> {
  final bool isSuccess;
  final TData? data;
  final String? apiErrorCode;
  final String? policyViolationDetails;

  HttpApiResponse({required this.isSuccess, this.data, this.apiErrorCode, this.policyViolationDetails});

  /// Constructs a [HttpApiResponse] from a decoded JSON [map].
  ///
  /// Handles typical API response structures, including lists, maps, and error fields.
  factory HttpApiResponse.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return HttpApiResponse(isSuccess: true);
    }

    final isSuccess = map['isSuccess'] == true;
    final hasData = isSuccess && map.containsKey('data');
    final hasApiErrorCode = !isSuccess && map.containsKey('apiErrorCode');
    final hasPolicyViolationDetails = !isSuccess && map.containsKey('policyViolationDetails');

    dynamic data = hasData ? map['data'] : null;
    if (data is List) {
      data = List<Map<String, dynamic>>.from(data);
    } else if (data is Map) {
      data = Map<String, dynamic>.from(data);
    }

    return HttpApiResponse(
      isSuccess: isSuccess,
      data: data,
      apiErrorCode: hasApiErrorCode ? map['apiErrorCode'] as String? : null,
      policyViolationDetails: hasPolicyViolationDetails ? map['policyViolationDetails'] as String? : null,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('HttpApiResponse(');
    buffer.write('isSuccess: $isSuccess');
    if (data != null) buffer.write(', data: $data');
    if (apiErrorCode != null) buffer.write(', apiErrorCode: $apiErrorCode');
    if (policyViolationDetails != null) {
      buffer.write(', policyViolationDetails: $policyViolationDetails');
    }
    buffer.write(')');
    return buffer.toString();
  }
}
