import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../localization/localization_extension.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, required this.onCreateAccount, required this.onSignIn});

  final VoidCallback onCreateAccount;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.large, vertical: Spacing.xLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                l10n.translate('welcomeTitle'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: Spacing.small),
              Text(
                l10n.translate('welcomeSubtitle'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.mutedText),
              ),
              const Spacer(),
              Semantics(
                label: l10n.translate('createAccount'),
                button: true,
                child: ElevatedButton(
                  onPressed: onCreateAccount,
                  child: Text(l10n.translate('createAccount')),
                ),
              ),
              const SizedBox(height: Spacing.small),
              Semantics(
                label: l10n.translate('signIn'),
                button: true,
                child: OutlinedButton(
                  onPressed: onSignIn,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                  ),
                  child: Text(l10n.translate('signIn')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
