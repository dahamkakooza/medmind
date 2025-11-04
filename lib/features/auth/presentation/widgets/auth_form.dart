import 'package:flutter/material.dart';

class AuthForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final VoidCallback onSubmit;

  const AuthForm({
    super.key,
    required this.formKey,
    required this.children,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...children,
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onSubmit,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}