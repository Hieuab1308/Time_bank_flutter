import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api_settings_repository.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/user.dart';


final settingsRepoProvider = Provider((ref) {
  final authedApi = ref.watch(authedApiClientProvider);
  return ApiSettingsRepository(authedApi);
});

final userProfileProvider = FutureProvider<UserProfile>((ref) {
  final repo = ref.watch(settingsRepoProvider);
  return repo.loadProfile();
});