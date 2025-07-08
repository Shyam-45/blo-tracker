class AppState {
  final bool isLoggedIn;
  final bool userDisabledToday;
  final String? authToken;

  const AppState({
    required this.isLoggedIn,
    required this.userDisabledToday,
    required this.authToken,
  });

  AppState copyWith({
    bool? isLoggedIn,
    bool? userDisabledToday,
    String? authToken,
  }) {
    return AppState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userDisabledToday: userDisabledToday ?? this.userDisabledToday,
      authToken: authToken ?? this.authToken,
    );
  }

  factory AppState.initial() => const AppState(
        isLoggedIn: false,
        userDisabledToday: false,
        authToken: null,
      );
}
