import '../domain/models/home_models.dart';

abstract class HomeRepository {
  Future<HomeSummary> fetchSummary();
  Future<List<Activity>> fetchActivities();

  /// Activities for the "My" section (phần của tôi)
  Future<List<Activity>> fetchMyActivities();
}
