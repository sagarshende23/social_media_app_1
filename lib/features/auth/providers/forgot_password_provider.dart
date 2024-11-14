import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } on Exception catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again later.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
