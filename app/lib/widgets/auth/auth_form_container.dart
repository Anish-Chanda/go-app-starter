import 'package:flutter/material.dart';
import '../../theme.dart';

class AuthFormContainer extends StatelessWidget {
  final Widget child;

  const AuthFormContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.lg),
            topRight: Radius.circular(AppSpacing.lg),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}
