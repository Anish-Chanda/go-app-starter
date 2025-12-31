import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../global/social_button.dart';

class SocialLoginSection extends StatelessWidget {
  final String dividerText;
  final VoidCallback? onGooglePressed;
  final VoidCallback? onFacebookPressed;

  const SocialLoginSection({
    super.key,
    required this.dividerText,
    this.onGooglePressed,
    this.onFacebookPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                dividerText,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: AppFontSize.sm,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppColors.border)),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            SocialButton(
              text: 'Google',
              icon: const FaIcon(
                FontAwesomeIcons.google,
                color: Colors.red,
                size: 20,
              ),
              onPressed: onGooglePressed ?? () {},
            ),
            const SizedBox(width: AppSpacing.md),
            SocialButton(
              text: 'Facebook',
              icon: const FaIcon(
                FontAwesomeIcons.facebookF,
                color: Colors.blue,
                size: 20,
              ),
              onPressed: onFacebookPressed ?? () {},
            ),
          ],
        ),
      ],
    );
  }
}
