import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../widgets/auth/auth_branding.dart';
import '../../widgets/auth/auth_form_container.dart';
import '../../widgets/auth/social_login_section.dart';
import '../../widgets/global/custom_text_field.dart';
import '../../widgets/global/primary_button.dart';
import '../../widgets/global/rich_text_links.dart';
import '../../utils/validator.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
                    'Create your\nAccount',
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
                        "Already have an account? ",
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: AppFontSize.base,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/login');
                          }
                        },
                        child: Text(
                          "Log In",
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
                      label: 'Full Name',
                      hint: 'John Doe',
                      validator: (v) =>
                          Validator.validateRequired(v, 'Full Name'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CustomTextField(
                      label: 'Email',
                      hint: 'email@gmail.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validator.validateEmail,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CustomTextField(
                      label: 'Password',
                      hint: '*******',
                      isPassword: true,
                      validator: Validator.validatePassword,
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    PrimaryButton(
                      text: 'Sign Up',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.go('/dashboard');
                        }
                      },
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    SocialLoginSection(
                      dividerText: 'Or sign up with',
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
                          TextPart(text: 'By signing up, you agree to the '),
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
  }
}
