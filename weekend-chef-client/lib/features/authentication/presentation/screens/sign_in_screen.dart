import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../localization/localization_extension.dart';
import '../controllers/auth_controller.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.controller, this.onBack});

  final AuthController controller;
  final VoidCallback? onBack;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('signIn')),
        leading: widget.onBack != null ? BackButton(onPressed: widget.onBack) : null,
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final state = widget.controller.state;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.large),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.translate('emailLabel')),
                  const SizedBox(height: Spacing.nano),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.translate('formRequired');
                      }
                      if (!value.contains('@')) {
                        return l10n.translate('formEmailInvalid');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: Spacing.medium),
                  Text(l10n.translate('passwordLabel')),
                  const SizedBox(height: Spacing.nano),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.translate('formRequired');
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                        tooltip: 'Toggle password visibility',
                      ),
                    ),
                  ),
                  if (state.error != null) ...[
                    const SizedBox(height: Spacing.medium),
                    Text(
                      state.error!,
                      style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: Spacing.xLarge),
                  ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              widget.controller.signIn(
                                email: _emailController.text,
                                password: _passwordController.text,
                              );
                            }
                          },
                    child: state.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.onPrimary)),
                          )
                        : Text(l10n.translate('continue')),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
