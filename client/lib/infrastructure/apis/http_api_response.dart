class HttpApiResponse<TResult> {
  final bool success;
  final TResult result;
  final String? details;
  final Map<String, dynamic> raw;

  HttpApiResponse({
    required this.success,
    required this.result,
    required this.details,
    required this.raw,
  });

  factory HttpApiResponse.fromMap(Map<String, dynamic> map) {
    final isSuccess = map['success'] == true;
    final hasResult = isSuccess && map.containsKey('result');
    final hasDetails = !isSuccess && map.containsKey('details');

    var result = hasResult ? map['result'] : {};
    if (result is List) result = List<Map<String, dynamic>>.from(result);
    if (result is Map) result = Map<String, dynamic>.from(result);
    if (result is String) result = result;

    return HttpApiResponse(
      success: isSuccess,
      result: result,
      details: hasDetails ? map['details'] : null,
      raw: map,
    );
  }
}
