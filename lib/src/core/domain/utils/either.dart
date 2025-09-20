/// This [Either] implementation was inspired by:
/// - https://www.scala-lang.org/api/2.13.6/scala/util/Either.html
/// - https://pub.dev/packages/dartz
sealed class Either<L, R> {
  const Either();

  T fold<T>(
    T Function(L) fa,
    T Function(R) fb,
  ) =>
      switch (this) {
        Left(value: final a) => fa.call(a),
        Right(value: final b) => fb.call(b),
      };
}

class Right<L, R> extends Either<L, R> {
  final R _r;
  const Right(this._r);

  R get value => _r;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Right<L, R> && other._r == _r;
  }

  @override
  int get hashCode => _r.hashCode;
}

class Left<L, R> extends Either<L, R> {
  final L _l;

  const Left(this._l);

  L get value => _l;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Left<L, R> && other._l == _l;
  }

  @override
  int get hashCode => _l.hashCode;
}
