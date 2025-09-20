import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/repositories/analytics_repository.dart';
import '../entities/events/event_entity.dart';
import '../repositories/analytics_repository.dart';

class TrackEventUsecase {
  final AnalyticsRepository _repository;

  const TrackEventUsecase({
    required AnalyticsRepository repository,
  }) : _repository = repository;

  Future<void> call({
    required EventEntity event,
  }) =>
      _repository.track(
        event,
      );
}

final trackEventUsecaseProvider = Provider.autoDispose<TrackEventUsecase>(
  (ref) => TrackEventUsecase(
    repository: ref.read(analyticsRepositoryProvider),
  ),
);
