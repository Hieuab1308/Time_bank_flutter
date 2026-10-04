import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/network/api_client.dart';
import '../../../core/app_config.dart';
import '../data/onboarding_api.dart';
import '../data/onboarding_repository.dart';
import 'onboarding_state.dart';
import '../domain/models/models.dart';
import 'package:http/http.dart' as http;
import 'onboarding_controller.dart';
final appConfigProvider = Provider<AppConfig>((_) => AppConfig.fromEnv);

final baseHttpProvider = Provider<http.Client>((_) => http.Client());

final publicApiClientProvider = Provider<ApiClient>((ref) {
  final baseHttp = ref.read(baseHttpProvider);
  return ApiClient(baseHttp, ref.read(appConfigProvider));
});

// OnboardingApi
final onboardingApiProvider = Provider<OnboardingApi>(
      (ref) => OnboardingApi(ref.read(publicApiClientProvider)),
);

// Repository
final onboardingRepoProvider = Provider<OnboardingRepository>(
      (ref) => OnboardingRepository(
    ref.read(onboardingApiProvider),
    FirebaseAuth.instance,
  ),
);

// Load skills từ backend (/skills)
final skillsProvider = FutureProvider<List<SkillDto>>((ref) {
  final api = ref.read(onboardingApiProvider);
  return api.fetchSkills();
});

// Controller
final onboardingControllerProvider =
StateNotifierProvider<OnboardingController, OnboardingState>(
      (ref) => OnboardingController(ref.read(onboardingRepoProvider)),
);
