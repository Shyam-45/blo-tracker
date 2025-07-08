import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blo_tracker/models/app_state.dart';
import 'package:blo_tracker/services/user_db_service.dart';

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(AppState.initial()) {
    loadFromPrefs();
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final disabled = prefs.getBool('user_disabled_today') ?? false;

    if (token != null) {
      state = state.copyWith(
        isLoggedIn: true,
        authToken: token,
        userDisabledToday: disabled,
      );
    }
  }

  Future<void> setLogin(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    state = state.copyWith(isLoggedIn: true, authToken: token);
  }

  Future<void> setTrackingDisabledToday(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('user_disabled_today', value);
    state = state.copyWith(userDisabledToday: value);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await UserDatabaseService.deleteUser(); // clear profile
    state = AppState.initial();
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((
  ref,
) {
  return AppStateNotifier();
});
