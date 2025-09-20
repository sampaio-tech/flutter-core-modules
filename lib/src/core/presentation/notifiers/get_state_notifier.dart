import '../../domain/utils/either.dart';
import 'safe_state_notifier.dart';
import 'state.dart';

abstract class GetStateNotifier<Failure, Entity>
    extends SafeStateNotifier<State<Failure, Entity>> {
  GetStateNotifier({
    State<Failure, Entity>? initialState,
  }) : super(initialState ?? const StartedState());

  Future<void> lazyGet() => switch (state) {
        StartedState() || LoadFailureState() => get(),
        _ => Future.value(),
      };

  Future<Either<Failure, Entity>> get() async {
    state = const LoadInProgressState();
    final failureOrSuccess = await forwardedGet();
    state = failureOrSuccess.fold(
      LoadFailureState.new,
      LoadSuccessState.new,
    );
    return failureOrSuccess;
  }

  Future<Either<Failure, Entity>> forwardedGet();
}
