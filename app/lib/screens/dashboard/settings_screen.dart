import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth.dart';
import '../../widgets/global/primary_button.dart';
import '../../theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: PrimaryButton(
                text: 'Logout',
                isLoading: authProvider.isLoading,
                onPressed: () => authProvider.logout(),
              ),
            ),
          ),
        );
      },
    );
  }
}
