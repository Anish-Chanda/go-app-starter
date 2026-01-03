import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../providers/auth.dart';
import '../../widgets/auth/auth_branding.dart';
import '../../widgets/auth/auth_form_container.dart';
import '../../widgets/auth/social_login_section.dart';
import '../../widgets/global/custom_text_field.dart';
import '../../widgets/global/primary_button.dart';
import '../../widgets/global/rich_text_links.dart';
import '../../utils/validator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.loginWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // Navigation handled by router redirect
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: Column(
              children: [
                // Header Section
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      const AuthBranding(),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Sign in to your\nAccount',
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: AppFontSize.display,
                          fontWeight: AppFontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: AppFontSize.base,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/signup'),
                            child: Text(
                              "Sign Up",
                              style: GoogleFonts.inter(
                                color: AppColors.primary,
                                fontSize: AppFontSize.base,
                                fontWeight: AppFontWeight.semiBold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Form Section
                AuthFormContainer(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'email@gmail.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: Validator.validateEmail,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: '*******',
                          isPassword: true,
                          validator: Validator.validatePassword,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push('/forgot-password'),
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.inter(
                                color: AppColors.primary,
                                fontWeight: AppFontWeight.semiBold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),
                        PrimaryButton(
                          text: 'Log In',
                          isLoading: authProvider.isLoading,
                          onPressed: () => _handleLogin(),
                        ),

                        const SizedBox(height: AppSpacing.xl),
                        SocialLoginSection(
                          dividerText: 'Or login with',
                          onGooglePressed: () {},
                          onFacebookPressed: () {},
                        ),

                        const SizedBox(height: AppSpacing.xxl),
                        Center(
                          child: RichTextLinks(
                            baseStyle: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: AppFontSize.xs,
                              height: 1.5,
                            ),
                            linkStyle: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontWeight: AppFontWeight.bold,
                            ),
                            parts: const [
                              TextPart(
                                text: 'By signing up, you agree to the ',
                              ),
                              TextPart(
                                text: 'Terms of Service',
                                url: 'https://example.com/tos',
                                isBold: true,
                              ),
                              TextPart(text: ' and\n'),
                              TextPart(
                                text: 'Data Processing Agreement',
                                url: 'https://example.com/dpa',
                                isBold: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
