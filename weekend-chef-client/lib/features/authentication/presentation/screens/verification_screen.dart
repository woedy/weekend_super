import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../localization/localization_extension.dart';
import '../../domain/auth_state.dart';
import '../controllers/auth_controller.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({
    super.key,
    required this.controller,
    required this.initialPurpose,
  });

  final AuthController controller;
  final VerificationPurpose initialPurpose;

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  late VerificationPurpose _purpose;

  @override
  void initState() {
    super.initState();
    _purpose = widget.initialPurpose;
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('verificationHeader')),
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final state = widget.controller.state;
          final user = state.user;
          final contact = _purpose == VerificationPurpose.email ? user?.email ?? '' : user?.phone ?? '';
          return Padding(
            padding: const EdgeInsets.all(Spacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translate('verificationDescriptionEmail', params: {'contact': contact}),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: Spacing.large),
                ToggleButtons(
                  isSelected: [
                    _purpose == VerificationPurpose.email,
                    _purpose == VerificationPurpose.phone,
                  ],
                  borderRadius: BorderRadius.circular(16),
                  selectedColor: AppColors.onPrimary,
                  fillColor: AppColors.primary,
                  onPressed: (index) {
                    setState(() {
                      _purpose = index == 0 ? VerificationPurpose.email : VerificationPurpose.phone;
                    });
                    widget.controller.requestVerification(_purpose);
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.medium, vertical: Spacing.micro),
                      child: Text(l10n.translate('emailLabel')),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.medium, vertical: Spacing.micro),
                      child: Text(l10n.translate('phoneLabel')),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.large),
                TextField(
                  controller: _codeController,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.translate('codeLabel'),
                    counterText: '',
                  ),
                ),
                if (state.error != null) ...[
                  const SizedBox(height: Spacing.small),
                  Text(state.error!, style: const TextStyle(color: AppColors.error)),
                ],
                const SizedBox(height: Spacing.large),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : () {
                                widget.controller.verifyCode(
                                  purpose: _purpose,
                                  code: _codeController.text,
                                );
                              },
                        child: state.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.onPrimary)),
                              )
                            : Text(l10n.translate('verifyButton')),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    if (_purpose == VerificationPurpose.phone) {
                      widget.controller.resendPhoneVerification();
                    } else {
                      widget.controller.requestVerification(_purpose);
                    }
                  },
                  child: Text(l10n.translate('resendCode')),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
