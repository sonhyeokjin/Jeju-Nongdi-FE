// API 예외 클래스들

abstract class ApiException implements Exception {
  final String message;
  final String? errorCode;
  final Map<String, dynamic>? details;
  
  const ApiException(this.message, {this.errorCode, this.details});
  
  @override
  String toString() => 'ApiException: $message ${errorCode != null ? '($errorCode)' : ''}';
}

// 네트워크 연결 오류
class NetworkException extends ApiException {
  const NetworkException(super.message, {super.errorCode, super.details});
}

// 타임아웃 오류
class TimeoutException extends ApiException {
  const TimeoutException(super.message, {super.errorCode, super.details});
}

// 400 Bad Request
class BadRequestException extends ApiException {
  const BadRequestException(super.message, {super.errorCode, super.details});
}

// 401 Unauthorized
class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message, {super.errorCode, super.details});
}

// 403 Forbidden
class ForbiddenException extends ApiException {
  const ForbiddenException(super.message, {super.errorCode, super.details});
}

// 404 Not Found
class NotFoundException extends ApiException {
  const NotFoundException(super.message, {super.errorCode, super.details});
}

// 409 Conflict
class ConflictException extends ApiException {
  const ConflictException(super.message, {super.errorCode, super.details});
}

// 422 Validation Error
class ValidationException extends ApiException {
  const ValidationException(super.message, {super.errorCode, super.details});
}

// 429 Too Many Requests
class TooManyRequestsException extends ApiException {
  const TooManyRequestsException(super.message, {super.errorCode, super.details});
}

// 500+ Server Error
class ServerException extends ApiException {
  const ServerException(super.message, {super.errorCode, super.details});
}

// 알 수 없는 오류
class UnknownException extends ApiException {
  const UnknownException(super.message, {super.errorCode, super.details});
}

// API 결과 래퍼 클래스
class ApiResult<T> {
  final T? data;
  final ApiException? error;
  final bool isSuccess;
  
  ApiResult.success(this.data) 
      : error = null, 
        isSuccess = true;
  
  ApiResult.failure(this.error) 
      : data = null, 
        isSuccess = false;
  
  // 성공 여부 확인
  bool get isFailure => !isSuccess;
  
  // 데이터가 있는지 확인
  bool get hasData => data != null;
  
  // 에러가 있는지 확인
  bool get hasError => error != null;
  
  // 성공 시 콜백 실행
  ApiResult<T> onSuccess(void Function(T data) callback) {
    if (isSuccess && data != null) {
      callback(data as T);
    }
    return this;
  }
  
  // 실패 시 콜백 실행
  ApiResult<T> onFailure(void Function(ApiException error) callback) {
    if (isFailure && error != null) {
      callback(error!);
    }
    return this;
  }
  
  // 데이터 변환
  ApiResult<R> map<R>(R Function(T data) mapper) {
    if (isSuccess && data != null) {
      try {
        final mappedData = mapper(data as T);
        return ApiResult.success(mappedData);
      } catch (e) {
        return ApiResult.failure(UnknownException('Data mapping failed: $e'));
      }
    }
    return ApiResult.failure(error!);
  }
  
  // 데이터 가져오기 (기본값 제공)
  T getOrElse(T defaultValue) {
    return data ?? defaultValue;
  }
  
  // 데이터 가져오기 (에러 시 예외 발생)
  T getOrThrow() {
    if (isSuccess && data != null) {
      return data as T;
    }
    throw error ?? UnknownException('No data available');
  }
  
  @override
  String toString() {
    if (isSuccess) {
      return 'ApiResult.success($data)';
    } else {
      return 'ApiResult.failure($error)';
    }
  }
}

// API 응답 래퍼 클래스
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? errorCode;
  final Map<String, dynamic>? meta;
  
  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
    this.meta,
  });
  
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, 
    T Function(dynamic)? fromJsonT
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null 
          ? fromJsonT(json['data']) 
          : json['data'],
      errorCode: json['errorCode'],
      meta: json['meta'],
    );
  }
  
  Map<String, dynamic> toJson(Object? Function(T?)? toJsonT) {
    return {
      'success': success,
      'message': message,
      'data': toJsonT != null ? toJsonT(data) : data,
      'errorCode': errorCode,
      'meta': meta,
    };
  }
  
  ApiResult<T> toResult() {
    if (success && data != null) {
      return ApiResult.success(data as T);
    } else {
      final exception = errorCode != null 
          ? UnknownException(message, errorCode: errorCode)
          : UnknownException(message);
      return ApiResult.failure(exception);
    }
  }
}

// 페이지네이션 응답 클래스
class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;
  
  const PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
  
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final items = (json['data'] as List<dynamic>)
        .map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList();
    
    return PaginatedResponse<T>(
      data: items,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalItems: json['totalItems'] ?? items.length,
      itemsPerPage: json['itemsPerPage'] ?? items.length,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'data': data.map(toJsonT).toList(),
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalItems': totalItems,
      'itemsPerPage': itemsPerPage,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }
}
