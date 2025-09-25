import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../localization/localization_extension.dart';
import '../../authentication/domain/auth_state.dart';
import '../../authentication/presentation/controllers/auth_controller.dart';
import '../../support/presentation/client_knowledge_base_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AnimatedBuilder(
      animation: authController,
      builder: (context, _) {
        final state = authController.state;
        final user = state.user;
        if (user == null) {
          return Center(child: Text(l10n.translate('loading')));
        }
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(l10n.translate('profileGreetings', params: {'name': user.firstName}),
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _VerificationTile(
              label: l10n.translate('emailLabel'),
              value: user.email,
              verified: user.emailVerified,
              verifiedLabel: l10n.translate('emailVerified'),
              pendingLabel: l10n.translate('verificationPending'),
              onVerify: () => authController.requestVerification(VerificationPurpose.email),
            ),
            const SizedBox(height: 12),
            _VerificationTile(
              label: l10n.translate('phoneLabel'),
              value: user.phone,
              verified: user.phoneVerified,
              verifiedLabel: l10n.translate('phoneVerified'),
              pendingLabel: l10n.translate('verificationPending'),
              onVerify: () => authController.requestVerification(VerificationPurpose.phone),
            ),
            const Divider(height: 32),
            Text(l10n.translate('language'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: [
                ChoiceChip(
                  label: const Text('English'),
                  selected: state.locale?.languageCode == 'en' || state.locale == null,
                  onSelected: (_) => authController.updateLocale(const Locale('en')),
                ),
                ChoiceChip(
                  label: const Text('Español'),
                  selected: state.locale?.languageCode == 'es',
                  onSelected: (_) => authController.updateLocale(const Locale('es')),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Card(
              child: ListTile(
                leading: const Icon(Icons.school_outlined),
                title: Text(l10n.translate('learnSupport')),
                subtitle: Text(l10n.translate('learnSupportSubtitle')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ClientKnowledgeBaseScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: authController.signOut,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: Text(l10n.translate('signOut')),
            ),
          ],
        );
      },
    );
  }
}

class _VerificationTile extends StatelessWidget {
  const _VerificationTile({
    required this.label,
    required this.value,
    required this.verified,
    required this.verifiedLabel,
    required this.pendingLabel,
    required this.onVerify,
  });

  final String label;
  final String value;
  final bool verified;
  final String verifiedLabel;
  final String pendingLabel;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      title: Text(label),
      subtitle: Text(value.isEmpty ? '-' : value),
      trailing: verified
          ? const Icon(Icons.verified, color: AppColors.success)
          : TextButton(onPressed: onVerify, child: Text(pendingLabel)),
    );
  }
}
