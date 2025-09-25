import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../localization/localization_extension.dart';
import '../controllers/auth_controller.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key, required this.controller, this.onBack});

  final AuthController controller;
  final VoidCallback? onBack;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  String _selectedRole = 'Client';
  bool _acceptedTerms = false;
  bool _obscure = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = widget.controller;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('createAccount')),
        leading: widget.onBack != null ? BackButton(onPressed: widget.onBack) : null,
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final state = controller.state;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.large),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    label: l10n.translate('firstNameLabel'),
                    controller: _firstName,
                    textInputAction: TextInputAction.next,
                  ),
                  _buildTextField(
                    label: l10n.translate('lastNameLabel'),
                    controller: _lastName,
                    textInputAction: TextInputAction.next,
                  ),
                  _buildTextField(
                    label: l10n.translate('emailLabel'),
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.translate('formRequired');
                      }
                      if (!value.contains('@')) {
                        return l10n.translate('formEmailInvalid');
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  _buildTextField(
                    label: l10n.translate('phoneLabel'),
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.translate('formRequired');
                      }
                      if (value.length < 7) {
                        return l10n.translate('formPhoneInvalid');
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  Text(l10n.translate('roleQuestion'), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: Spacing.micro),
                  Wrap(
                    spacing: Spacing.small,
                    runSpacing: Spacing.small,
                    children: [
                      _RoleChip(
                        label: l10n.translate('roleClient'),
                        value: 'Client',
                        isSelected: _selectedRole == 'Client',
                        onSelected: () => setState(() => _selectedRole = 'Client'),
                      ),
                      _RoleChip(
                        label: l10n.translate('roleChef'),
                        value: 'Chef',
                        isSelected: _selectedRole == 'Chef',
                        onSelected: () => setState(() => _selectedRole = 'Chef'),
                      ),
                      _RoleChip(
                        label: l10n.translate('roleDispatch'),
                        value: 'Dispatch',
                        isSelected: _selectedRole == 'Dispatch',
                        onSelected: () => setState(() => _selectedRole = 'Dispatch'),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.medium),
                  _buildPasswordField(
                    label: l10n.translate('passwordLabel'),
                    controller: _password,
                    obscureText: _obscure,
                    toggle: () => setState(() => _obscure = !_obscure),
                  ),
                  _buildPasswordField(
                    label: l10n.translate('confirmPasswordLabel'),
                    controller: _confirmPassword,
                    obscureText: _obscureConfirm,
                    toggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.translate('formRequired');
                      }
                      if (value != _password.text) {
                        return l10n.translate('passwordsDoNotMatch');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: Spacing.medium),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _acceptedTerms,
                        onChanged: (value) => setState(() => _acceptedTerms = value ?? false),
                      ),
                      Expanded(
                        child: Text(
                          l10n.translate('termsAgreement'),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  if (state.error != null) ...[
                    const SizedBox(height: Spacing.small),
                    Text(state.error!, style: const TextStyle(color: AppColors.error)),
                  ],
                  const SizedBox(height: Spacing.large),
                  ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            if (!_acceptedTerms) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.translate('termsAgreement'))),
                              );
                              return;
                            }
                            if (_formKey.currentState?.validate() ?? false) {
                              controller.signUp(
                                email: _email.text,
                                password: _password.text,
                                firstName: _firstName.text,
                                lastName: _lastName.text,
                                phone: _phone.text,
                                role: _selectedRole,
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    TextInputAction? textInputAction,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: Spacing.nano),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator ?? (value) => value == null || value.isEmpty ? context.l10n.translate('formRequired') : null,
            textInputAction: textInputAction,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggle,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: Spacing.nano),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator ?? (value) => value == null || value.isEmpty ? context.l10n.translate('formRequired') : null,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: toggle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      labelStyle: TextStyle(color: isSelected ? AppColors.primary : Colors.black),
      selectedColor: AppColors.primary.withOpacity(0.12),
    );
  }
}
