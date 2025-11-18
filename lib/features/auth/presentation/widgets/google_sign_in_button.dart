import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_button.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'Continue with Google',
      onPressed: onPressed,
      variant: ButtonVariant.outlined,
      isLoading: isLoading,
      icon: Icons.g_mobiledata,
    );
  }
}