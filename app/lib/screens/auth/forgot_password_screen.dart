import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../widgets/auth/auth_branding.dart';
import '../../widgets/auth/auth_form_container.dart';
import '../../widgets/global/custom_text_field.dart';
import '../../widgets/global/primary_button.dart';
import '../../utils/validator.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
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
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const AuthBranding(),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Reset your\nPassword',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: AppFontSize.display,
                      fontWeight: AppFontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    "Enter your email address and we'll send you a link to reset your password.",
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: AppFontSize.base,
                    ),
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
                      label: 'Email',
                      hint: 'email@gmail.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validator.validateEmail,
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    PrimaryButton(
                      text: 'Send Reset Link',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Show success message or navigate
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reset link sent!')),
                          );
                          context.pop();
                        }
                      },
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
