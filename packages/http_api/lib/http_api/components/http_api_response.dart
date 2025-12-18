part of '../http_api.dart';

/// Represents a response from an http api call, including success status, data, and error details.
///
/// [TData] is the type of the expected payload. Use this class to standardize api responses
/// and error handling
class HttpApiResponse<TData> {
  final bool isSuccess;
  final TData? data;
  final String? apiErrorCode;
  final String? policyViolationReason;

  HttpApiResponse({required this.isSuccess, this.data, this.apiErrorCode, this.policyViolationReason});

  /// Constructs a [HttpApiResponse] from a decoded json [map].
  ///
  /// Handles typical api response structures, including lists, maps, and error fields.
  factory HttpApiResponse.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) return HttpApiResponse(isSuccess: true);

    final isSuccess = map['isSuccess'] == true;
    final hasData = isSuccess && map.containsKey('data');
    final hasApiErrorCode = !isSuccess && map.containsKey('apiErrorCode');
    final hasPolicyViolationDetails = !isSuccess && map.containsKey('policyViolationReason');

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
      policyViolationReason: hasPolicyViolationDetails ? map['policyViolationReason'] as String? : null,
    );
  }

  @override
  String toString() {
    return 'HttpApiResponse('
        'isSuccess: $isSuccess'
        '${data != null ? ', data: $data' : ''}'
        '${apiErrorCode != null ? ', apiErrorCode: $apiErrorCode' : ''}'
        '${policyViolationReason != null ? ', policyViolationReason: $policyViolationReason' : ''}'
        ')';
  }
}
