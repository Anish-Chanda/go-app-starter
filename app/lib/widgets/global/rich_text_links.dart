import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme.dart';

class TextPart {
  final String text;
  final String? url;
  final bool isBold;

  const TextPart({required this.text, this.url, this.isBold = false});
}

class RichTextLinks extends StatelessWidget {
  final List<TextPart> parts;
  final TextAlign textAlign;
  final TextStyle? baseStyle;
  final TextStyle? linkStyle;

  const RichTextLinks({
    super.key,
    required this.parts,
    this.textAlign = TextAlign.center,
    this.baseStyle,
    this.linkStyle,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBaseStyle =
        baseStyle ??
        TextStyle(
          color: AppColors.textSecondary,
          fontSize: AppFontSize.xs,
          height: 1.5,
        );

    final defaultLinkStyle =
        linkStyle ??
        TextStyle(color: AppColors.textPrimary, fontWeight: AppFontWeight.bold);

    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: defaultBaseStyle,
        children: parts.map((part) {
          if (part.url != null) {
            return TextSpan(
              text: part.text,
              style: defaultLinkStyle.copyWith(
                fontWeight: part.isBold ? FontWeight.bold : null,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launchUrl(Uri.parse(part.url!));
                },
            );
          } else {
            return TextSpan(
              text: part.text,
              style: part.isBold
                  ? defaultBaseStyle.copyWith(fontWeight: FontWeight.bold)
                  : defaultBaseStyle,
            );
          }
        }).toList(),
      ),
    );
  }
}
