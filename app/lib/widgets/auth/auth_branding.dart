import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';

class AuthBranding extends StatelessWidget {
  const AuthBranding({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const FaIcon(
          FontAwesomeIcons.rocket,
          color: AppColors.primary,
          size: 28,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Acme',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: AppFontSize.xxl,
            fontWeight: AppFontWeight.bold,
          ),
        ),
      ],
    );
  }
}
