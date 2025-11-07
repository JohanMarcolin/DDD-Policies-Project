class HttpApiResponse<TData> {
  final bool isSuccess;
  final TData? data;
  final String? errorCode;
  final String? policyViolationDetails;

  HttpApiResponse({
    required this.isSuccess,
    this.data,
    this.errorCode,
    this.policyViolationDetails,
  });

  factory HttpApiResponse.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return HttpApiResponse(isSuccess: true);
    }

    final isSuccess = map['isSuccess'] == true;
    final hasData = isSuccess && map.containsKey('data');
    final hasErrorCode = !isSuccess && map.containsKey('errorCode');
    final hasPolicyViolationDetails =
        !isSuccess && map.containsKey('policyViolationDetails');

    var data = hasData ? map['data'] : null;
    if (data is List) data = List<Map<String, dynamic>>.from(data);
    if (data is Map) data = Map<String, dynamic>.from(data);
    if (data is String) data = data;

    return HttpApiResponse(
      isSuccess: isSuccess,
      data: data,
      errorCode: hasErrorCode ? map['errorCode'] : null,
      policyViolationDetails: hasPolicyViolationDetails
          ? map['policyViolationDetails']
          : null,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('HttpApiResponse(');
    buffer.write('isSuccess: $isSuccess');
    if (data != null) buffer.write(', data: $data');
    if (errorCode != null) buffer.write(', errorCode: $errorCode');
    if (policyViolationDetails != null) {
      buffer.write(', policyViolationDetails: $policyViolationDetails');
    }
    buffer.write(')');
    return buffer.toString();
  }
}
