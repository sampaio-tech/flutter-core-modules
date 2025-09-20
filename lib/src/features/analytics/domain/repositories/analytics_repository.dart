import '../entities/events/event_entity.dart';

abstract class AnalyticsRepository {
  const AnalyticsRepository();

  Future<void> track(
    EventEntity event,
  );
}
