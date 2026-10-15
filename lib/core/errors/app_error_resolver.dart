import 'package:dio/dio.dart';

import '../enums/backend_enums.dart';
import '../network/api_exception.dart';
import 'app_failure.dart';

/// ============================================================================
/// USER FRIENDLY MESSAGE MODEL
/// ============================================================================
/// Represents a polished, concise, on-point error communication for users.
/// Completely separates user communication from internal error traces.
class UserFriendlyMessage {
  final String title;
  final String message;
  final String?
  directive; // Directional / guidance message telling user what to do
  final ApiErrorType errorType;
  final String? traceId;
  final List<String>? errors;
  final dynamic rawSource;

  const UserFriendlyMessage({
    required this.title,
    required this.message,
    this.directive,
    this.errorType = ApiErrorType.unknown,
    this.traceId,
    this.errors,
    this.rawSource,
  });

  /// Single formatted message string with directive, ideal for Snackbars and alerts.
  String get displayMessage {
    // if (directive != null && directive!.isNotEmpty) {
    //   return '$message $directive';
    // }
    return message;
  }

  @override
  String toString() => displayMessage;
}

/// ============================================================================
/// APP ERROR RESOLVER
/// ============================================================================
/// Intercepts backend failure responses and exceptions, maps them to `ApiErrorType`,
/// and creates decent, concise, on-point user messages with directional guidance.
class AppErrorResolver {
  const AppErrorResolver._();

  /// Resolve any exception or error object into a `UserFriendlyMessage`.
  static UserFriendlyMessage resolve(
    Object? error, {
    String? languageCode,
    String? fallbackDirective,
  }) {
    final isSpanish = _isSpanish(languageCode);

    if (error == null) {
      return _buildMessage(
        type: ApiErrorType.unknown,
        isSpanish: isSpanish,
        customDirective: fallbackDirective,
      );
    }

    if (error is UserFriendlyMessage) {
      if (languageCode != null) {
        if (error.rawSource != null) {
          return resolve(
            error.rawSource,
            languageCode: languageCode,
            fallbackDirective: fallbackDirective ?? error.directive,
          );
        }
        return _retranslateMessage(
          error,
          isSpanish: isSpanish,
          customDirective: fallbackDirective,
        );
      }
      return error;
    }

    // 1. Backend response map or JSON-like structure
    if (error is Map) {
      return _fromBackendMap(
        Map<String, dynamic>.from(error),
        isSpanish: isSpanish,
        customDirective: fallbackDirective,
      );
    }

    // 2. DioException (HTTP layer)
    if (error is DioException) {
      return _fromDioException(
        error,
        isSpanish: isSpanish,
        customDirective: fallbackDirective,
      );
    }

    // 3. ApiException (Custom HTTP exception)
    if (error is ApiException) {
      return _fromApiException(
        error,
        isSpanish: isSpanish,
        customDirective: fallbackDirective,
      );
    }

    // 4. Clean Architecture AppFailure
    if (error is AppFailure) {
      return _fromAppFailure(
        error,
        isSpanish: isSpanish,
        customDirective: fallbackDirective,
      );
    }

    // 5. Raw string or general Exception
    return _fromString(
      error.toString(),
      isSpanish: isSpanish,
      customDirective: fallbackDirective,
    );
  }

  static bool _isSpanish(String? languageCode) {
    if (languageCode == null) return false;
    return languageCode.toLowerCase().startsWith('es');
  }

  static UserFriendlyMessage _fromBackendMap(
    Map<String, dynamic> data, {
    required bool isSpanish,
    String? customDirective,
  }) {
    final rawErrorType = data['errorType']?.toString();
    final rawMessage = data['message']?.toString();
    final traceId = data['traceId']?.toString();
    final rawErrors = data['errors'];

    // 1. Check if backend provided structured validation errors list or map
    if (rawErrors != null) {
      final parsedErrors = _parseRawErrors(rawErrors, isSpanish: isSpanish);
      if (parsedErrors.isNotEmpty) {
        final title = isSpanish ? 'Error de validación' : 'Validation Error';
        final directive =
            customDirective ??
            (isSpanish
                ? (parsedErrors.length > 1
                      ? 'Por favor corrige los campos señalados e intenta de nuevo.'
                      : 'Por favor corrige el campo señalado e intenta de nuevo.')
                : (parsedErrors.length > 1
                      ? 'Please correct the indicated fields and try again.'
                      : 'Please correct the indicated field and try again.'));

        final message = parsedErrors.length == 1
            ? parsedErrors.first
            : parsedErrors.map((e) => '• $e').join('\n');

        return UserFriendlyMessage(
          title: title,
          message: message,
          directive: directive,
          errorType: ApiErrorType.validationError,
          traceId: traceId,
          errors: parsedErrors,
          rawSource: data,
        );
      }
    }

    // 2. Check if message itself indicates request validation failure
    if (rawMessage != null &&
        (rawMessage.toLowerCase().contains('validation failed') ||
            rawMessage.toLowerCase().contains('validation error'))) {
      final title = isSpanish ? 'Error de validación' : 'Validation Error';
      final message = isSpanish
          ? 'Algunos campos obligatorios contienen datos inválidos o incompletos.'
          : 'Some required fields are missing or contain invalid information.';
      final directive =
          customDirective ??
          (isSpanish
              ? 'Por favor revisa los campos señalados e intenta de nuevo.'
              : 'Please review the highlighted fields and try again.');

      return UserFriendlyMessage(
        title: title,
        message: message,
        directive: directive,
        errorType: ApiErrorType.validationError,
        traceId: traceId,
        rawSource: data,
      );
    }

    final errorType = ApiErrorType.fromString(rawErrorType);

    // For recognized backend error types (such as INVALID_CREDENTIALS),
    // use our polished, localized, on-point message from the enum type.
    // Only use raw message if errorType is unknown and the message is clean.
    final cleanMessage = errorType == ApiErrorType.unknown
        ? _sanitizeMessage(rawMessage)
        : null;

    final msg = _buildMessage(
      type: errorType,
      isSpanish: isSpanish,
      customMessage: cleanMessage,
      customDirective: customDirective,
      traceId: traceId,
    );

    return UserFriendlyMessage(
      title: msg.title,
      message: msg.message,
      directive: msg.directive,
      errorType: msg.errorType,
      traceId: msg.traceId,
      rawSource: data,
    );
  }

  static UserFriendlyMessage _fromDioException(
    DioException dioError, {
    required bool isSpanish,
    String? customDirective,
  }) {
    final response = dioError.response;
    if (response != null && response.data is Map) {
      return _fromBackendMap(
        Map<String, dynamic>.from(response.data as Map),
        isSpanish: isSpanish,
        customDirective: customDirective,
      );
    }

    // Handle standard network timeouts and connection errors
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return _buildMessage(
          type: ApiErrorType.networkError,
          isSpanish: isSpanish,
          customDirective: customDirective,
        );
      case DioExceptionType.badResponse:
        final status = response?.statusCode ?? 500;
        if (status == 401) {
          return _buildMessage(
            type: ApiErrorType.unauthorized,
            isSpanish: isSpanish,
            customDirective: customDirective,
          );
        } else if (status == 403) {
          return _buildMessage(
            type: ApiErrorType.forbidden,
            isSpanish: isSpanish,
            customDirective: customDirective,
          );
        } else if (status == 404) {
          return _buildMessage(
            type: ApiErrorType.notFound,
            isSpanish: isSpanish,
            customDirective: customDirective,
          );
        } else if (status == 429) {
          return _buildMessage(
            type: ApiErrorType.rateLimitExceeded,
            isSpanish: isSpanish,
            customDirective: customDirective,
          );
        } else if (status >= 500) {
          return _buildMessage(
            type: ApiErrorType.serverError,
            isSpanish: isSpanish,
            customDirective: customDirective,
          );
        }
        return _buildMessage(
          type: ApiErrorType.unknown,
          isSpanish: isSpanish,
          customDirective: customDirective,
        );
      case DioExceptionType.cancel:
        return _buildMessage(
          type: ApiErrorType.unknown,
          isSpanish: isSpanish,
          customMessage: isSpanish
              ? 'La solicitud fue cancelada.'
              : 'The request was cancelled.',
          customDirective: customDirective,
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
      default:
        return _buildMessage(
          type: ApiErrorType.networkError,
          isSpanish: isSpanish,
          customDirective: customDirective,
        );
    }
  }

  static UserFriendlyMessage _fromApiException(
    ApiException apiException, {
    required bool isSpanish,
    String? customDirective,
  }) {
    if (apiException.data is Map) {
      return _fromBackendMap(
        Map<String, dynamic>.from(apiException.data as Map),
        isSpanish: isSpanish,
        customDirective: customDirective,
      );
    }

    return _fromString(
      apiException.message,
      isSpanish: isSpanish,
      customDirective: customDirective,
    );
  }

  static UserFriendlyMessage _fromAppFailure(
    AppFailure failure, {
    required bool isSpanish,
    String? customDirective,
  }) {
    if (failure is ValidationFailure) {
      if (failure.errors != null) {
        final parsedErrors = _parseRawErrors(
          failure.errors,
          isSpanish: isSpanish,
        );
        if (parsedErrors.isNotEmpty) {
          final title = isSpanish ? 'Error de validación' : 'Validation Error';
          final message = parsedErrors.length == 1
              ? parsedErrors.first
              : parsedErrors.map((e) => '• $e').join('\n');
          final directive =
              customDirective ??
              (isSpanish
                  ? 'Por favor corrige los campos señalados e intenta de nuevo.'
                  : 'Please correct the indicated fields and try again.');
          return UserFriendlyMessage(
            title: title,
            message: message,
            directive: directive,
            errorType: ApiErrorType.validationError,
            errors: parsedErrors,
            rawSource: failure,
          );
        }
      }
      return _buildMessage(
        type: ApiErrorType.validationError,
        isSpanish: isSpanish,
        customDirective: customDirective,
      );
    }
    if (failure is UnauthorizedFailure) {
      return _buildMessage(
        type: ApiErrorType.unauthorized,
        isSpanish: isSpanish,
        customDirective: customDirective,
      );
    }
    if (failure is NetworkFailure || failure is TimeoutFailure) {
      return _buildMessage(
        type: ApiErrorType.networkError,
        isSpanish: isSpanish,
        customDirective: customDirective,
      );
    }
    if (failure is ForbiddenFailure) {
      return _buildMessage(
        type: ApiErrorType.forbidden,
        isSpanish: isSpanish,
        customDirective: customDirective,
      );
    }
    if (failure is NotFoundFailure) {
      return _buildMessage(
        type: ApiErrorType.notFound,
        isSpanish: isSpanish,
        customDirective: customDirective,
      );
    }
    if (failure is ServerFailure) {
      return _buildMessage(
        type: ApiErrorType.serverError,
        isSpanish: isSpanish,
        customDirective: customDirective,
      );
    }

    return _fromString(
      failure.userMessage,
      isSpanish: isSpanish,
      customDirective: customDirective,
    );
  }

  static UserFriendlyMessage _fromString(
    String raw, {
    required bool isSpanish,
    String? customDirective,
  }) {
    // Check for stringified errors list: {field: phone, message: Invalid phone number} or {"field": "phone", "message": "..."}
    final fieldMessageRegex = RegExp(
      r"""\{["']?field["']?:\s*["']?(\w+)["']?,\s*["']?message["']?:\s*["']?([^}"']+)["']?\}""",
      caseSensitive: false,
    );
    final matches = fieldMessageRegex.allMatches(raw);
    if (matches.isNotEmpty) {
      final parsedErrors = <String>[];
      for (final m in matches) {
        final field = m.group(1);
        final msg = m.group(2);
        if (msg != null && msg.trim().isNotEmpty) {
          parsedErrors.add(
            _translateValidationError(msg.trim(), field, isSpanish: isSpanish),
          );
        }
      }
      if (parsedErrors.isNotEmpty) {
        final title = isSpanish ? 'Error de validación' : 'Validation Error';
        final directive =
            customDirective ??
            (isSpanish
                ? (parsedErrors.length > 1
                      ? 'Por favor corrige los campos señalados e intenta de nuevo.'
                      : 'Por favor corrige el campo señalado e intenta de nuevo.')
                : (parsedErrors.length > 1
                      ? 'Please correct the indicated fields and try again.'
                      : 'Please correct the indicated field and try again.'));

        final message = parsedErrors.length == 1
            ? parsedErrors.first
            : parsedErrors.map((e) => '• $e').join('\n');

        return UserFriendlyMessage(
          title: title,
          message: message,
          directive: directive,
          errorType: ApiErrorType.validationError,
          errors: parsedErrors,
          rawSource: raw,
        );
      }
    }

    final lower = raw.toLowerCase();

    if (lower.contains('invalid_credentials') ||
        lower.contains('invalid credential') ||
        (lower.contains('credential') && lower.contains('password')) ||
        lower.contains('credenciales')) {
      return _buildMessage(
        type: ApiErrorType.invalidCredentials,
        isSpanish: isSpanish,
        customDirective: customDirective,
      );
    }

    if (lower.contains('user_not_found') ||
        lower.contains('user not found') ||
        lower.contains('usuario no encontrado')) {
      return _buildMessage(
        type: ApiErrorType.userNotFound,
        isSpanish: isSpanish,
        customDirective: customDirective,
      );
    }

    if (lower.contains('otp') &&
        (lower.contains('invalid') ||
            lower.contains('incorrect') ||
            lower.contains('incorrecto'))) {
      return _buildMessage(
        type: ApiErrorType.invalidOtp,
        isSpanish: isSpanish,
        customDirective: customDirective,
      );
    }

    if (lower.contains('otp') &&
        (lower.contains('expired') ||
            lower.contains('expirado') ||
            lower.contains('caducado'))) {
      return _buildMessage(
        type: ApiErrorType.otpExpired,
        isSpanish: isSpanish,
        customDirective: customDirective,
      );
    }

    if (lower.contains('email_already_exists') ||
        lower.contains('email already exists') ||
        lower.contains('already registered') ||
        lower.contains('correo ya registrado')) {
      return _buildMessage(
        type: ApiErrorType.emailAlreadyExists,
        isSpanish: isSpanish,
        customDirective: customDirective,
      );
    }

    if (lower.contains('session expired') ||
        lower.contains('token_expired') ||
        lower.contains('token expired')) {
      return _buildMessage(
        type: ApiErrorType.sessionExpired,
        isSpanish: isSpanish,
        customDirective: customDirective,
      );
    }

    if (lower.contains('socketexception') ||
        lower.contains('network') ||
        lower.contains('connection refused') ||
        lower.contains('no internet') ||
        lower.contains('sin conexión')) {
      return _buildMessage(
        type: ApiErrorType.networkError,
        isSpanish: isSpanish,
        customDirective: customDirective,
      );
    }

    // Discard raw technical prefixes
    final clean = _sanitizeMessage(raw);

    return _buildMessage(
      type: ApiErrorType.unknown,
      isSpanish: isSpanish,
      customMessage: clean,
      customDirective: customDirective,
    );
  }

  static List<String> _parseRawErrors(
    dynamic rawErrors, {
    required bool isSpanish,
  }) {
    final result = <String>[];

    if (rawErrors is List) {
      for (final item in rawErrors) {
        if (item is Map) {
          final field =
              item['field']?.toString() ??
              item['param']?.toString() ??
              item['path']?.toString() ??
              item['name']?.toString() ??
              item['key']?.toString();
          final msg =
              item['message']?.toString() ??
              item['msg']?.toString() ??
              item['error']?.toString();
          if (msg != null && msg.trim().isNotEmpty) {
            result.add(
              _translateValidationError(
                msg.trim(),
                field,
                isSpanish: isSpanish,
              ),
            );
          }
        } else if (item is String && item.trim().isNotEmpty) {
          result.add(
            _translateValidationError(item.trim(), null, isSpanish: isSpanish),
          );
        }
      }
    } else if (rawErrors is Map) {
      rawErrors.forEach((key, value) {
        final field = key.toString();
        if (value is List) {
          for (final v in value) {
            if (v != null && v.toString().trim().isNotEmpty) {
              result.add(
                _translateValidationError(
                  v.toString().trim(),
                  field,
                  isSpanish: isSpanish,
                ),
              );
            }
          }
        } else if (value != null && value.toString().trim().isNotEmpty) {
          result.add(
            _translateValidationError(
              value.toString().trim(),
              field,
              isSpanish: isSpanish,
            ),
          );
        }
      });
    }

    return result;
  }

  static String _translateValidationError(
    String rawMsg,
    String? field, {
    required bool isSpanish,
  }) {
    final lower = rawMsg.toLowerCase().trim();
    final lowerField = field?.toLowerCase().trim() ?? '';

    // Password validations
    if (lower.contains('uppercase') || lower.contains('mayúscula')) {
      return isSpanish
          ? 'La contraseña debe contener al menos una letra mayúscula'
          : 'Password must contain at least one uppercase letter';
    }
    if (lower.contains('lowercase') || lower.contains('minúscula')) {
      return isSpanish
          ? 'La contraseña debe contener al menos una letra minúscula'
          : 'Password must contain at least one lowercase letter';
    }
    if (lower.contains('special character') ||
        lower.contains('carácter especial') ||
        lower.contains('caracter especial') ||
        lower.contains('special char')) {
      return isSpanish
          ? 'La contraseña debe contener al menos un carácter especial'
          : 'Password must contain at least one special character';
    }
    if ((lower.contains('number') ||
            lower.contains('digit') ||
            lower.contains('número') ||
            lower.contains('numero')) &&
        (lower.contains('password') || lowerField.contains('password'))) {
      return isSpanish
          ? 'La contraseña debe contener al menos un número'
          : 'Password must contain at least one number';
    }
    if ((lower.contains('8 character') ||
            lower.contains('at least 8') ||
            lower.contains('min 8') ||
            lower.contains('8 caracteres')) &&
        (lower.contains('password') || lowerField.contains('password'))) {
      return isSpanish
          ? 'La contraseña debe tener al menos 8 caracteres'
          : 'Password must be at least 8 characters';
    }
    if ((lower.contains('required') || lower.contains('obligatori')) &&
        (lower.contains('password') || lowerField.contains('password'))) {
      return isSpanish
          ? 'La contraseña es obligatoria'
          : 'Password is required';
    }

    // Phone validations
    if ((lower.contains('phone') ||
            lowerField.contains('phone') ||
            lowerField.contains('mobile')) &&
        (lower.contains('invalid') ||
            lower.contains('no válido') ||
            lower.contains('not valid') ||
            lower.contains('inválido'))) {
      return isSpanish
          ? 'Número de teléfono no válido'
          : 'Invalid phone number';
    }
    if ((lower.contains('phone') ||
            lowerField.contains('phone') ||
            lowerField.contains('mobile')) &&
        (lower.contains('already exists') ||
            lower.contains('already in use') ||
            lower.contains('ya registrado') ||
            lower.contains('ya existe'))) {
      return isSpanish
          ? 'Este número de teléfono ya está registrado en otra cuenta'
          : 'This phone number is already registered to another account';
    }
    if ((lower.contains('phone') ||
            lowerField.contains('phone') ||
            lowerField.contains('mobile')) &&
        (lower.contains('required') ||
            lower.contains('obligatori') ||
            lower.contains('empty'))) {
      return isSpanish
          ? 'El número de teléfono es obligatorio'
          : 'Phone number is required';
    }

    // Email validations
    if ((lower.contains('email') ||
            lowerField.contains('email') ||
            lower.contains('correo')) &&
        (lower.contains('already exists') ||
            lower.contains('already in use') ||
            lower.contains('ya registrado') ||
            lower.contains('ya existe'))) {
      return isSpanish
          ? 'Ya existe una cuenta vinculada a este correo electrónico'
          : 'An account is already registered with this email address';
    }
    if ((lower.contains('email') ||
            lowerField.contains('email') ||
            lower.contains('correo')) &&
        (lower.contains('invalid') ||
            lower.contains('valid') ||
            lower.contains('no válido') ||
            lower.contains('inválido'))) {
      return isSpanish
          ? 'Introduce un correo electrónico válido'
          : 'Please enter a valid email address';
    }
    if ((lower.contains('email') ||
            lowerField.contains('email') ||
            lower.contains('correo')) &&
        (lower.contains('required') ||
            lower.contains('obligatori') ||
            lower.contains('empty'))) {
      return isSpanish
          ? 'El correo electrónico es obligatorio'
          : 'Email is required';
    }

    // Name validations
    if ((lower.contains('name') ||
            lowerField.contains('name') ||
            lower.contains('nombre')) &&
        (lower.contains('required') ||
            lower.contains('obligatori') ||
            lower.contains('empty'))) {
      return isSpanish
          ? 'El nombre completo es obligatorio'
          : 'Full name is required';
    }

    // Terms validation
    if (lower.contains('term') ||
        lower.contains('término') ||
        lowerField.contains('term')) {
      return isSpanish
          ? 'Por favor acepta los Términos y Condiciones'
          : 'Please agree to the Terms and Conditions';
    }

    // Generic fallback for field + required/invalid
    if (isSpanish) {
      if (lower.contains('required') ||
          lower.contains('is required') ||
          lower.contains('must not be empty')) {
        final fieldNameEs = _translateFieldName(lowerField, isSpanish: true);
        return '$fieldNameEs es obligatorio';
      }
      if (lower.contains('invalid') || lower.contains('is not valid')) {
        final fieldNameEs = _translateFieldName(lowerField, isSpanish: true);
        return '$fieldNameEs no es válido';
      }
      return rawMsg;
    } else {
      if (rawMsg.isNotEmpty) {
        return rawMsg[0].toUpperCase() + rawMsg.substring(1);
      }
      return rawMsg;
    }
  }

  static String _translateFieldName(String field, {required bool isSpanish}) {
    switch (field.toLowerCase()) {
      case 'phone':
      case 'phonenumber':
      case 'phone_number':
      case 'mobile':
        return isSpanish ? 'El número de teléfono' : 'Phone number';
      case 'password':
        return isSpanish ? 'La contraseña' : 'Password';
      case 'email':
      case 'emailaddress':
      case 'email_address':
        return isSpanish ? 'El correo electrónico' : 'Email';
      case 'fullname':
      case 'full_name':
      case 'name':
        return isSpanish ? 'El nombre completo' : 'Full name';
      case 'role':
        return isSpanish ? 'El rol' : 'Role';
      default:
        if (field.isEmpty) return isSpanish ? 'Este campo' : 'This field';
        return field;
    }
  }

  static UserFriendlyMessage _retranslateMessage(
    UserFriendlyMessage original, {
    required bool isSpanish,
    String? customDirective,
  }) {
    if (original.errorType == ApiErrorType.validationError &&
        original.errors != null &&
        original.errors!.isNotEmpty) {
      final retranslated = original.errors!
          .map((e) => _translateValidationError(e, null, isSpanish: isSpanish))
          .toList();
      final title = isSpanish ? 'Error de validación' : 'Validation Error';
      final directive =
          customDirective ??
          (isSpanish
              ? (retranslated.length > 1
                    ? 'Por favor corrige los campos señalados e intenta de nuevo.'
                    : 'Por favor corrige el campo señalado e intenta de nuevo.')
              : (retranslated.length > 1
                    ? 'Please correct the indicated fields and try again.'
                    : 'Please correct the indicated field and try again.'));
      final message = retranslated.length == 1
          ? retranslated.first
          : retranslated.map((e) => '• $e').join('\n');

      return UserFriendlyMessage(
        title: title,
        message: message,
        directive: directive,
        errorType: ApiErrorType.validationError,
        traceId: original.traceId,
        errors: retranslated,
        rawSource: original.rawSource,
      );
    }

    if (original.errorType != ApiErrorType.unknown) {
      return _buildMessage(
        type: original.errorType,
        isSpanish: isSpanish,
        customDirective: customDirective ?? original.directive,
        traceId: original.traceId,
      );
    }

    return original;
  }

  static String? _sanitizeMessage(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    var cleaned = raw.trim();

    // Strip out common technical exception prefixes
    cleaned = cleaned.replaceAll(
      RegExp(
        r'^(Exception|DioException.*?|Error|AppException):\s*',
        caseSensitive: false,
      ),
      '',
    );
    cleaned = cleaned.replaceAll(RegExp(r'\[.*?\]'), '').trim();

    // Reject raw JSON dumps, trace dumps, or HTTP status dumps
    if (cleaned.startsWith('{') ||
        cleaned.contains('traceId') ||
        cleaned.contains('statusCode')) {
      return null;
    }

    return cleaned.isNotEmpty ? cleaned : null;
  }

  static UserFriendlyMessage _buildMessage({
    required ApiErrorType type,
    required bool isSpanish,
    String? customMessage,
    String? customDirective,
    String? traceId,
  }) {
    switch (type) {
      case ApiErrorType.invalidCredentials:
        return UserFriendlyMessage(
          title: isSpanish
              ? 'Credenciales incorrectas'
              : 'Incorrect Credentials',
          message:
              customMessage ??
              (isSpanish
                  ? 'El correo electrónico o la contraseña ingresados no coinciden con nuestros registros.'
                  : 'The email or password entered does not match our records.'),
          directive:
              customDirective ??
              (isSpanish
                  ? 'Por favor verifica tus datos o pulsa "¿Olvidaste tu contraseña?" para restablecerla.'
                  : "Please double-check your credentials or tap 'Forgot password?' to reset your access."),
          errorType: type,
          traceId: traceId,
        );

      case ApiErrorType.userNotFound:
        return UserFriendlyMessage(
          title: isSpanish ? 'Cuenta no encontrada' : 'Account Not Found',
          message:
              customMessage ??
              (isSpanish
                  ? 'No se encontró ninguna cuenta activa con este correo electrónico.'
                  : 'No active account was found with the provided email address.'),
          directive:
              customDirective ??
              (isSpanish
                  ? 'Verifica la dirección ingresada o regístrate para crear una nueva cuenta.'
                  : 'Please check the spelling or sign up for a new academy account.'),
          errorType: type,
          traceId: traceId,
        );

      case ApiErrorType.userInactive:
      case ApiErrorType.accountInactive:
        return UserFriendlyMessage(
          title: isSpanish ? 'Cuenta inactiva' : 'Account Inactive',
          message:
              customMessage ??
              (isSpanish
                  ? 'Tu cuenta de usuario se encuentra inactiva en este momento.'
                  : 'Your account is currently inactive.'),
          directive:
              customDirective ??
              (isSpanish
                  ? 'Por favor ponte en contacto con la secretaría o administración del centro para activarla.'
                  : 'Please contact academy administration to activate your access.'),
          errorType: type,
          traceId: traceId,
        );

      case ApiErrorType.userSuspended:
        return UserFriendlyMessage(
          title: isSpanish ? 'Cuenta suspendida' : 'Account Suspended',
          message:
              customMessage ??
              (isSpanish
                  ? 'El acceso a esta cuenta ha sido suspendido temporalmente.'
                  : 'Access to this account has been temporarily suspended.'),
          directive:
              customDirective ??
              (isSpanish
                  ? 'Por favor consulta con la administración del centro escolar para más detalles.'
                  : 'Please speak with academy administration to resolve this notice.'),
          errorType: type,
          traceId: traceId,
        );

      case ApiErrorType.userWithdrawn:
        return UserFriendlyMessage(
          title: isSpanish ? 'Matrícula dada de baja' : 'Enrollment Withdrawn',
          message:
              customMessage ??
              (isSpanish
                  ? 'Este perfil ha sido marcado como dado de baja en la academia.'
                  : 'This student account has been withdrawn from academy enrollment.'),
          directive:
              customDirective ??
              (isSpanish
                  ? 'Contacta con secretaría si necesitas renovar la matrícula.'
                  : 'Contact the academy office if you need assistance with re-enrollment.'),
          errorType: type,
          traceId: traceId,
        );

      case ApiErrorType.invalidOtp:
        return UserFriendlyMessage(
          title: isSpanish ? 'Código incorrecto' : 'Invalid Verification Code',
          message:
              customMessage ??
              (isSpanish
                  ? 'El código de verificación de 6 dígitos no es válido.'
                  : 'The 6-digit verification code entered is incorrect.'),
          directive:
              customDirective ??
              (isSpanish
                  ? 'Por favor revisa el correo enviado o pulsa "Reenviar código" para recibir uno nuevo.'
                  : "Please check your verification email or request a new code."),
          errorType: type,
          traceId: traceId,
        );

      case ApiErrorType.otpExpired:
        return UserFriendlyMessage(
          title: isSpanish ? 'Código caducado' : 'Verification Code Expired',
          message:
              customMessage ??
              (isSpanish
                  ? 'El código de verificación ha expirado por límite de tiempo.'
                  : 'This verification code has expired.'),
          directive:
              customDirective ??
              (isSpanish
                  ? 'Pulsa "Reenviar código" para obtener un código de seguridad actualizado.'
                  : "Please tap 'Resend code' to receive a fresh verification code."),
          errorType: type,
          traceId: traceId,
        );

      case ApiErrorType.emailAlreadyExists:
        return UserFriendlyMessage(
          title: isSpanish
              ? 'Correo ya registrado'
              : 'Email Already Registered',
          message:
              customMessage ??
              (isSpanish
                  ? 'Ya existe una cuenta vinculada a este correo electrónico.'
                  : 'An account is already registered with this email address.'),
          directive:
              customDirective ??
              (isSpanish
                  ? 'Inicia sesión directamente o utiliza la recuperación de contraseña.'
                  : "Please log in instead or use 'Forgot password' to recover access."),
          errorType: type,
          traceId: traceId,
        );

      case ApiErrorType.phoneAlreadyExists:
        return UserFriendlyMessage(
          title: isSpanish ? 'Teléfono ya registrado' : 'Phone Number in Use',
          message:
              customMessage ??
              (isSpanish
                  ? 'Este número de teléfono ya está registrado en otra cuenta.'
                  : 'This phone number is already registered to another account.'),
          directive:
              customDirective ??
              (isSpanish
                  ? 'Introduce un teléfono alternativo o inicia sesión en tu cuenta existente.'
                  : 'Please provide a different phone number or log in to your account.'),
          errorType: type,
          traceId: traceId,
        );

      case ApiErrorType.unauthorized:
      case ApiErrorType.tokenExpired:
      case ApiErrorType.sessionExpired:
        return UserFriendlyMessage(
          title: isSpanish ? 'Sesión finalizada' : 'Session Expired',
          message:
              customMessage ??
              (isSpanish
                  ? 'Tu sesión de usuario ha expirado por motivos de seguridad.'
                  : 'Your session has expired for security reasons.'),
          directive:
              customDirective ??
              (isSpanish
                  ? 'Por favor inicia sesión de nuevo con tus credenciales para continuar.'
                  : 'Please sign in again with your credentials to continue.'),
          errorType: type,
          traceId: traceId,
        );

      case ApiErrorType.forbidden:
        return UserFriendlyMessage(
          title: isSpanish ? 'Acceso restringido' : 'Access Restricted',
          message:
              customMessage ??
              (isSpanish
                  ? 'No dispones de permisos para realizar esta acción.'
                  : 'You do not have permission to access this resource or feature.'),
          directive:
              customDirective ??
              (isSpanish
                  ? 'Si consideras que es un error, consulta con la dirección de la academia.'
                  : 'Please speak with academy administration if you believe this is an error.'),
          errorType: type,
          traceId: traceId,
        );

      case ApiErrorType.notFound:
        return UserFriendlyMessage(
          title: isSpanish ? 'No encontrado' : 'Resource Not Found',
          message:
              customMessage ??
              (isSpanish
                  ? 'El recurso solicitado no se encuentra disponible.'
                  : 'The requested resource, class, or report could not be found.'),
          directive:
              customDirective ??
              (isSpanish
                  ? 'Por favor regresa al menú principal o actualiza la pantalla.'
                  : 'Please return to the previous screen or refresh your list.'),
          errorType: type,
          traceId: traceId,
        );

      case ApiErrorType.validationError:
        return UserFriendlyMessage(
          title: isSpanish ? 'Información incompleta' : 'Information Required',
          message:
              customMessage ??
              (isSpanish
                  ? 'Algunos campos obligatorios contienen datos inválidos o incompletos.'
                  : 'Some required fields are missing or contain invalid information.'),
          directive:
              customDirective ??
              (isSpanish
                  ? 'Por favor revisa los campos señalados e intenta de nuevo.'
                  : 'Please review the highlighted fields and try again.'),
          errorType: type,
          traceId: traceId,
        );

      case ApiErrorType.fileTooLarge:
        return UserFriendlyMessage(
          title: isSpanish ? 'Archivo demasiado grande' : 'File Too Large',
          message:
              customMessage ??
              (isSpanish
                  ? 'El archivo seleccionado supera el límite de subida permitido.'
                  : 'The selected file exceeds the maximum permitted upload limit.'),
          directive:
              customDirective ??
              (isSpanish
                  ? 'Por favor selecciona un archivo de menor tamaño (máximo 50MB).'
                  : 'Please choose a smaller file (under 50MB) and try again.'),
          errorType: type,
          traceId: traceId,
        );

      case ApiErrorType.invalidFileType:
        return UserFriendlyMessage(
          title: isSpanish
              ? 'Formato no compatible'
              : 'Unsupported File Format',
          message:
              customMessage ??
              (isSpanish
                  ? 'El tipo de archivo seleccionado no está admitido.'
                  : 'The selected file format is not supported.'),
          directive:
              customDirective ??
              (isSpanish
                  ? 'Por favor adjunta un documento o imagen válido (JPG, PNG, PDF).'
                  : 'Please select a supported file type such as JPG, PNG, or PDF.'),
          errorType: type,
          traceId: traceId,
        );

      case ApiErrorType.rateLimitExceeded:
        return UserFriendlyMessage(
          title: isSpanish ? 'Demasiadas solicitudes' : 'Too Many Attempts',
          message:
              customMessage ??
              (isSpanish
                  ? 'Se han realizado demasiadas solicitudes en un corto periodo de tiempo.'
                  : 'Too many attempts have been made in a short period.'),
          directive:
              customDirective ??
              (isSpanish
                  ? 'Por favor espera unos instantes antes de volver a intentarlo.'
                  : 'Please wait a moment before trying again.'),
          errorType: type,
          traceId: traceId,
        );

      case ApiErrorType.networkError:
        return UserFriendlyMessage(
          title: isSpanish ? 'Problema de conexión' : 'Connection Problem',
          message:
              customMessage ??
              (isSpanish
                  ? 'No se ha podido conectar con los servidores de la academia.'
                  : 'Unable to connect to the academy server.'),
          directive:
              customDirective ??
              (isSpanish
                  ? 'Por favor revisa tu conexión a internet e inténtalo de nuevo.'
                  : 'Please check your internet connection and try again.'),
          errorType: type,
          traceId: traceId,
        );

      case ApiErrorType.serverError:
        return UserFriendlyMessage(
          title: isSpanish ? 'Servicio no disponible' : 'Service Interruption',
          message:
              customMessage ??
              (isSpanish
                  ? 'Los servidores de la academia están experimentando una interrupción técnica.'
                  : 'The academy servers are currently experiencing technical difficulties.'),
          directive:
              customDirective ??
              (isSpanish
                  ? 'Nuestro equipo está trabajando en ello. Inténtalo de nuevo en unos minutos.'
                  : 'Our team is working on it. Please try again in a few moments.'),
          errorType: type,
          traceId: traceId,
        );

      case ApiErrorType.unknown:
        return UserFriendlyMessage(
          title: isSpanish
              ? 'No se pudo completar'
              : 'Unable to Complete Request',
          message:
              customMessage ??
              (isSpanish
                  ? 'Ocurrió un problema inesperado al procesar tu solicitud.'
                  : 'Something unexpected occurred while processing your request.'),
          directive: customDirective,

          //  ??
          // (isSpanish
          //     ? 'Por favor intenta de nuevo o contacta con el soporte si el problema persiste.'
          //     : 'Please try again or contact academy support if this continues.'),
          errorType: type,
          traceId: traceId,
        );
    }
  }
}
