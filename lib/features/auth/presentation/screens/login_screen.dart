import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:bookshelf/core/localization/l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final auth = FirebaseAuth.instance;
    final loc = AppLocalizations.of(context)!;

    try {
      if (_isLogin) {
        await auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = loc.auth_error_unknown;
      
      if (e.code == 'user-not-found') {
        errorMessage = loc.auth_error_user_not_found;
      } else if (e.code == 'wrong-password') {
        errorMessage = loc.localeName == 'en' 
            ? 'Incorrect password.' 
            : loc.localeName == 'pl' 
                ? 'Niepoprawne hasło.' 
                : 'Невірний пароль.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = loc.localeName == 'en' 
            ? 'This email is already in use by another account.' 
            : loc.localeName == 'pl' 
                ? 'Ten e-mail jest już używany przez inne konto.' 
                : 'Цей email вже використовується іншим акаунтом.';
      } else if (e.code == 'weak-password') {
        errorMessage = loc.localeName == 'en' 
            ? 'Password is too weak (minimum 6 characters).' 
            : loc.localeName == 'pl' 
                ? 'Hasło jest zbyt słabe (minimum 6 znaków).' 
                : 'Пароль занадто слабкий (мінімум 6 символів).';
      } else if (e.code == 'invalid-email') {
        errorMessage = loc.auth_error_invalid_email;
      }

      _showErrorSnackBar(errorMessage);
    } catch (e) {
      _showErrorSnackBar('${loc.localeName == 'en' ? 'Connection error' : loc.localeName == 'pl' ? 'Błąd połączenia' : 'Помилка з\'єднання'}: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isLogin ? loc.auth_welcome : loc.auth_sign_up_title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin 
                        ? (loc.localeName == 'en' 
                            ? 'Sign in to access your library' 
                            : loc.localeName == 'pl' 
                                ? 'Zaloguj się, aby uzyskać dostęp do swojej biblioteki' 
                                : 'Увійдіть, щоб отримати доступ до вашої бібліотеки') 
                        : (loc.localeName == 'en' 
                            ? 'Fill in the fields to start reading right now' 
                            : loc.localeName == 'pl' 
                                ? 'Wypełnij pola, aby zacząć czytać już teraz' 
                                : 'Заповніть поля, щоб почати читати прямо зараз'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: loc.email_label,
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return loc.validation_enter_email;
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                        return loc.validation_correct_email;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: _isLogin ? TextInputAction.done : TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: loc.password_label,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return loc.validation_enter_password;
                      }
                      if (value.length < 6) {
                        return loc.validation_password_length;
                      }
                      return null;
                    },
                  ),
                  if (_isLogin) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                context.push('/forgot-password');
                              },
                        child: Text(
                          loc.auth_forgot_password_link,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (!_isLogin) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: loc.confirm_password_label,
                        prefixIcon: const Icon(Icons.lock_clock_outlined),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return loc.validation_confirm_password;
                        }
                        if (value != _passwordController.text) {
                          return loc.validation_passwords_match;
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_isLogin ? loc.btn_sign_in : loc.btn_sign_up, style: const TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _isLogin = !_isLogin;
                              _formKey.currentState?.reset();
                              _emailController.clear();
                              _passwordController.clear();
                              _confirmPasswordController.clear();
                            });
                          },
                    child: Text(
                      _isLogin ? loc.no_account : loc.has_account,
                      style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}