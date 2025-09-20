import 'package:http/http.dart';

import '../utils/either.dart';

sealed class HttpFailure {
  const HttpFailure();

  static Either<HttpFailure, Response> fromResponse(
    Response response,
  ) =>
      switch (response.statusCode) {
        200 || 201 => Right(response),
        404 => const Left(NotFoundFailure()),
        409 => const Left(UnidentifiedHttpFailure()),
        422 => const Left(ValidationErrorsHttpFailure()),
        _ => const Left(UnidentifiedHttpFailure()),
      };
}

class TimeoutFailure extends HttpFailure {
  const TimeoutFailure();
}

class NotFoundFailure extends HttpFailure {
  const NotFoundFailure();
}

class UnidentifiedHttpFailure extends HttpFailure {
  const UnidentifiedHttpFailure();
}

class ValidationErrorsHttpFailure extends HttpFailure {
  const ValidationErrorsHttpFailure();
}
