sealed class State<F, S> {
  const State();
}

class StartedState<F, S> extends State<F, S> {
  const StartedState();
}

class LoadInProgressState<F, S> extends State<F, S> {
  final F? _f;
  final S? _s;

  const LoadInProgressState({
    F? f,
    S? s,
  })  : _f = f,
        _s = s;

  F? get f => _f;
  S? get s => _s;
}

class LoadSuccessState<F, S> extends State<F, S> {
  final S _s;
  const LoadSuccessState(
    S value,
  ) : _s = value;

  S get value => _s;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LoadSuccessState<F, S> && other._s == _s;
  }

  @override
  int get hashCode => _s.hashCode;
}

class LoadFailureState<F, S> extends State<F, S> {
  final F _f;
  const LoadFailureState(
    F value,
  ) : _f = value;

  F get value => _f;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LoadFailureState<F, S> && other._f == _f;
  }

  @override
  int get hashCode => _f.hashCode;
}
