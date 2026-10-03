import 'package:flutter/material.dart';

import 'dart:async';

import '../l10n/app_localizations.dart';
import '../models/referral_models.dart';
import '../services/auth_service.dart';
import '../services/referral_service.dart';

import 'package:akwarium/utils/app_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _referralCodeController = TextEditingController();
  AuthService? _authService;

  bool _isRegistering = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  ReferralCodeValidation? _referralValidation;
  Timer? _referralValidationTimer;

  AuthService get _auth => _authService ??= AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralCodeController.dispose();
    _referralValidationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F2F1), Color(0xFFE1F5FE)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildBrandMark(),
                          const SizedBox(height: 22),
                          Text(
                            _isRegistering
                                ? l10n.createAccount
                                : l10n.loginWelcome,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: const Color(0xFF123D39),
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isRegistering
                                ? l10n.registerSubtitle
                                : l10n.loginSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 26),
                          if (_errorMessage != null) ...[
                            _ErrorMessage(message: _errorMessage!),
                            const SizedBox(height: 16),
                          ],
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            decoration: InputDecoration(
                              labelText: l10n.email,
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: _isRegistering
                                ? TextInputAction.next
                                : TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            decoration: InputDecoration(
                              labelText: l10n.password,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword
                                    ? l10n.showPassword
                                    : l10n.hidePassword,
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: _validatePassword,
                            onFieldSubmitted: (_) {
                              if (!_isRegistering) _submit();
                            },
                          ),
                          if (_isRegistering) ...[
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                labelText: l10n.confirmPassword,
                                prefixIcon: const Icon(Icons.lock_reset),
                                suffixIcon: IconButton(
                                  tooltip: _obscureConfirmPassword
                                      ? l10n.showPassword
                                      : l10n.hidePassword,
                                  onPressed: () => setState(
                                    () => _obscureConfirmPassword =
                                        !_obscureConfirmPassword,
                                  ),
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return l10n.passwordsMustMatch;
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _referralCodeController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                labelText: l10n.referralCodeOptional,
                                prefixIcon: const Icon(
                                  Icons.card_giftcard_outlined,
                                ),
                                suffixIcon: _referralValidation == null
                                    ? null
                                    : Icon(
                                        _referralValidation!.isValid
                                            ? Icons.check_circle
                                            : Icons.error_outline,
                                        color: _referralValidation!.isValid
                                            ? Colors.green
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                      ),
                                helperText: _referralValidation == null
                                    ? null
                                    : _referralValidation!.isValid
                                    ? null
                                    : _referralErrorMessage(
                                        AppLocalizations.of(context)!,
                                        _referralValidation!.errorCode!,
                                      ),
                              ),
                              onChanged: _onReferralCodeChanged,
                            ),
                          ],
                          const SizedBox(height: 22),
                          FilledButton(
                            onPressed: _isLoading ? null : _submit,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _isRegistering
                                        ? l10n.createAccount
                                        : l10n.login,
                                  ),
                          ),
                          if (!_isRegistering) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(l10n.orContinueWith),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _isLoading ? null : _signInWithGoogle,
                              icon: _isGoogleLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'G',
                                      style: TextStyle(
                                        color: Color(0xFF4285F4),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                              label: Text(l10n.signInWithGoogle),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.googleConfigurationHint,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                          if (!_isRegistering) ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _isLoading ? null : _resetPassword,
                              child: Text(l10n.forgotPassword),
                            ),
                          ],
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: _isLoading ? null : _toggleMode,
                            child: Text(
                              _isRegistering
                                  ? l10n.alreadyHaveAccount
                                  : l10n.createNewAccount,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandMark() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.teal.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.water, color: Colors.teal, size: 34),
        ),
        const SizedBox(height: 12),
        const Text(
          'AKWARYSTA PRO',
          style: TextStyle(
            color: Color(0xFF123D39),
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),
      ],
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    final l10n = AppLocalizations.of(context)!;
    if (email.isEmpty) return l10n.emailRequired;
    final isValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    return isValid ? null : l10n.invalidEmail;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').length < 6) {
      return AppLocalizations.of(context)!.passwordTooShort;
    }
    return null;
  }

  void _toggleMode() {
    setState(() {
      _isRegistering = !_isRegistering;
      _errorMessage = null;
    });
    _formKey.currentState?.reset();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isRegistering) {
        await _auth.registerWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (_referralCodeController.text.trim().isNotEmpty) {
          try {
            await ReferralService().applyCode(_referralCodeController.text);
          } on ReferralException catch (error) {
            if (mounted) {
              setState(
                () => _errorMessage = _referralErrorMessage(
                  AppLocalizations.of(context)!,
                  error.code,
                ),
              );
            }
            return;
          }
        }
      } else {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      if (mounted) {
        await Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } on AuthException catch (error) {
      if (mounted) {
        final message = _authErrorMessage(error);
        setState(() => _errorMessage = message);
        _showMessage(message, error: true);
      }
    } catch (_) {
      if (mounted) {
        final message = AppLocalizations.of(context)!.firebaseGenericError;
        setState(() => _errorMessage = message);
        _showMessage(message, error: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isLoading = true;
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = await _auth.signInWithGoogle();
      if (!mounted || credential == null) return;
      await Navigator.of(context).pushReplacementNamed('/dashboard');
    } on AuthException catch (error) {
      if (!mounted) return;
      final message = _authErrorMessage(error);
      setState(() => _errorMessage = message);
      _showMessage(message, error: true);
    } on Object catch (error, stackTrace) {
      debugPrint('Google sign-in screen failed: $error\n$stackTrace');
      if (!mounted) return;
      final message = AppLocalizations.of(context)!.googleSignInFailed;
      setState(() => _errorMessage = message);
      _showMessage(message, error: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isGoogleLoading = false;
        });
      }
    }
  }

  void _onReferralCodeChanged(String value) {
    _referralValidationTimer?.cancel();
    final code = value.trim();
    if (code.isEmpty) {
      setState(() => _referralValidation = null);
      return;
    }
    _referralValidationTimer = Timer(
      const Duration(milliseconds: 450),
      () async {
        final result = await ReferralService().validateCode(code);
        if (!mounted || _referralCodeController.text.trim() != code) return;
        setState(() => _referralValidation = result);
      },
    );
  }

  Future<void> _resetPassword() async {
    final l10n = AppLocalizations.of(context)!;
    final emailController = TextEditingController(text: _emailController.text);
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetPasswordTitle),
        content: TextField(
          controller: emailController,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: l10n.emailAddressLabel,
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, emailController.text),
            child: Text(l10n.sendResetLinkAction),
          ),
        ],
      ),
    );
    emailController.dispose();

    if (email == null || _validateEmail(email) != null) {
      if (email != null && mounted) {
        setState(() => _errorMessage = l10n.invalidEmail);
      }
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email);
      if (mounted) {
        context.showAppSnackBar(
          SnackBar(content: Text(l10n.passwordResetSuccess)),
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        final message = _authErrorMessage(error);
        setState(() => _errorMessage = message);
        _showMessage(message, error: true);
      }
    }
  }

  void _showMessage(String message, {bool error = false}) {
    context.showAppSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red.shade700 : null,
      ),
    );
  }

  String _authErrorMessage(AuthException error) {
    final l10n = AppLocalizations.of(context)!;
    return switch (error.code) {
      'google-sign-in-configuration' =>
        '${l10n.googleSignInConfigurationError}\n${l10n.googleConfigurationHint}',
      'google-sign-in-unsupported' => l10n.googleSignInUnsupported,
      'google-sign-in-failed' => l10n.googleSignInFailed,
      'invalid-email' => l10n.invalidEmail,
      'user-disabled' => l10n.userDisabled,
      'user-not-found' ||
      'invalid-credential' ||
      'wrong-password' => l10n.invalidCredentials,
      'email-already-in-use' => l10n.emailAlreadyInUse,
      'network-request-failed' => l10n.networkError,
      _ => l10n.authError,
    };
  }
}

String _referralErrorMessage(AppLocalizations l10n, ReferralErrorCode code) {
  switch (code) {
    case ReferralErrorCode.codeTooShort:
      return l10n.referralCodeTooShort;
    case ReferralErrorCode.invalidCode:
      return l10n.referralInvalidCode;
    case ReferralErrorCode.selfReferral:
      return l10n.referralSelfReferral;
    case ReferralErrorCode.alreadyUsedDevice:
      return l10n.referralDeviceUsed;
    case ReferralErrorCode.alreadyReferred:
      return l10n.referralAlreadyReferred;
    case ReferralErrorCode.emailNotVerified:
      return l10n.referralEmailUnverified;
    case ReferralErrorCode.operationUnavailable:
      return l10n.referralOperationUnavailable;
    case ReferralErrorCode.unauthenticated:
      return l10n.referralUnauthenticated;
    case ReferralErrorCode.unavailable:
      return l10n.referralUnavailable;
    case ReferralErrorCode.internal:
      return l10n.referralInternal;
    case ReferralErrorCode.generic:
      return l10n.referralGenericError;
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(color: Colors.red.shade800)),
          ),
        ],
      ),
    );
  }
}
