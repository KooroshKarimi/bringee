import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _initializeAuth();
  }

  void _initializeAuth() {
    // TODO: Implement Firebase Authentication
    // For now, we'll simulate a loading state
    Future.delayed(const Duration(seconds: 1), () {
      state = const AsyncValue.data(null);
    });
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      // TODO: Implement Firebase Authentication
      await Future.delayed(const Duration(seconds: 1));
      final user = User(
        id: '1',
        email: email,
        name: 'Demo User',
        isVerified: true,
        userType: UserType.sender,
      );
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    state = const AsyncValue.loading();
    try {
      // TODO: Implement Firebase Authentication
      await Future.delayed(const Duration(seconds: 1));
      final user = User(
        id: '1',
        email: email,
        name: name,
        isVerified: false,
        userType: UserType.sender,
      );
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.data(null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>(
  (ref) => AuthNotifier(),
);