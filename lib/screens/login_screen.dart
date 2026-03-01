// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isSignUp = false;
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth = context.read<UserAuthProvider>();
    if (_isSignUp) {
      await auth.createAccount(_emailCtrl.text.trim(), _passwordCtrl.text);
    } else {
      await auth.signInWithEmail(_emailCtrl.text.trim(), _passwordCtrl.text);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<UserAuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Logo ─────────────────────────────────────────────────
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.35),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'MR',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'MAXREP',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary,
                    letterSpacing: 5,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'Fitness. Leveled.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // ─── Tab Toggle ────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _tab('Sign In', !_isSignUp),
                    _tab('Create Account', _isSignUp),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ─── Form ─────────────────────────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.mail_outline,
                            color: AppTheme.textSecondary, size: 20),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter your email';
                        if (!v.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: AppTheme.textSecondary, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter your password';
                        if (_isSignUp && v.length < 6) {
                          return 'At least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              // ─── Error ────────────────────────────────────────────────
              if (auth.error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    auth.error!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // ─── Primary Button ────────────────────────────────────────
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submitForm,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.black,
                          ),
                        )
                      : Text(_isSignUp ? 'Create Account' : 'Sign In'),
                ),
              ),

              const SizedBox(height: 20),

              // ─── Divider ──────────────────────────────────────────────
              Row(
                children: [
                  const Expanded(child: Divider(color: AppTheme.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('or',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  const Expanded(child: Divider(color: AppTheme.border)),
                ],
              ),

              const SizedBox(height: 20),

              // ─── Google Button ────────────────────────────────────────
              SizedBox(
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: _loading
                      ? null
                      : () => context.read<UserAuthProvider>().signInWithGoogle(),
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  label: const Text('Continue with Google'),
                ),
              ),

              const SizedBox(height: 32),

              Center(
                child: TextButton(
                  child: Text(
                    _isSignUp
                        ? 'Already have an account? Sign In'
                        : "Don't have an account? Sign Up",
                    style: const TextStyle(
                        color: AppTheme.primary, fontSize: 13),
                  ),
                  onPressed: () => setState(() => _isSignUp = !_isSignUp),
                ),
              ),

              // ─── Demo Mode shortcut ────────────────────────────────────
              if (auth.demoMode) ...[
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accent.withValues(alpha: 0.35)),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.bolt, color: AppTheme.accent, size: 22),
                    title: const Text('Try Demo',
                        style: TextStyle(
                            color: AppTheme.accent, fontWeight: FontWeight.w700)),
                    subtitle: const Text('Firebase not configured — explore with mock data',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppTheme.accent),
                    onTap: () {
                      // Force demo sign-in by calling saveProfile with demo user
                      context.read<UserAuthProvider>().saveProfile(
                        const UserModel(
                          uid: 'demo_user_1',
                          displayName: 'Alex Kumar',
                          age: 28,
                          gender: 'male',
                          heightCm: 178,
                          weightKg: 82,
                          bmi: 25.9,
                          orgId: 'acme_corp',
                          department: 'Engineering',
                          district: 'Downtown',
                          state: 'California',
                          country: 'USA',
                          pulsePoints: 3820,
                          activityScore: 68,
                          strengthScore: 74,
                          vitalityScore: 55,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(String label, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isSignUp = label == 'Create Account'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? Colors.black : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
