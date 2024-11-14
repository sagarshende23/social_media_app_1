import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:gotrue/src/types/provider.dart' as supabase_provider;

final supabaseClient = Supabase.instance.client;

class AuthState {
  final User? user;
  final bool isAuthenticated;
  final String? error;

  AuthState({
    this.user,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _initialize();
  }

  void _initialize() {
    final session = supabaseClient.auth.currentSession;
    if (session != null) {
      state = AuthState(
        user: session.user,
        isAuthenticated: true,
      );
    }

    supabaseClient.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      switch (event) {
        case AuthChangeEvent.signedIn:
          if (session != null) {
            state = AuthState(
              user: session.user,
              isAuthenticated: true,
            );
          }
          break;
        case AuthChangeEvent.signedOut:
          state = AuthState();
          break;
        default:
          break;
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        state = AuthState(
          user: response.user,
          isAuthenticated: true,
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final response = await supabaseClient.auth.signInWithOAuth(
        supabase_provider.Provider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );

      if (!response) {
        throw Exception('Google sign in failed');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user != null) {
        state = AuthState(
          user: response.user,
          isAuthenticated: true,
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> signOut() async {
    await supabaseClient.auth.signOut();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
