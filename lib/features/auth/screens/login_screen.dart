import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/loading_widget.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithEmail(
      _emailController.text,
      _passwordController.text,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login failed'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();
    if (!success && mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  _buildLogo(),
                  const SizedBox(height: 48),
                  const Text(
                    'Welcome back',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to continue to Taskrift',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildForm(),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      ),
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(color: AppTheme.primaryLight),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLoginButton(),
                  const SizedBox(height: 24),
                  _buildDivider(),
                  const SizedBox(height: 24),
                  _buildGoogleButton(),
                  const SizedBox(height: 40),
                  _buildRegisterLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        const Text(
          'Taskrift',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'your@email.com',
              prefixIcon: Icon(Icons.mail_outline_rounded, color: AppTheme.textSecondary, size: 20),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            validator: Validators.validatePassword,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.textSecondary, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: auth.isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: auth.isLoading
                ? const LoadingWidget(size: 20, color: Colors.white)
                : const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppTheme.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppTheme.border)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: auth.isLoading ? null : _handleGoogleSignIn,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Center(
                    child: Text('G', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Continue with Google',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Don't have an account? ",
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            ),
            child: const Text(
              'Sign Up',
              style: TextStyle(
                color: AppTheme.primaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
