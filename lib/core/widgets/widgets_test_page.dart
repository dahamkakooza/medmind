import 'package:flutter/material.dart';
import 'loading_widget.dart';
import 'empty_state_widget.dart';
import 'error_widget.dart';
import 'custom_button.dart' as custom_buttons;
import 'custom_text_field.dart';

class WidgetsTestPage extends StatefulWidget {
  const WidgetsTestPage({super.key});

  @override
  State<WidgetsTestPage> createState() => _WidgetsTestPageState();
}

class _WidgetsTestPageState extends State<WidgetsTestPage> {
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _simulateLoading() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Core Widgets Test'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTestSection('Loading Widgets', [
            const LoadingWidget(message: 'Loading medications...'),
            const SizedBox(height: 20),
            LoadingOverlay(
              isLoading: _isLoading,
              message: _isLoading ? 'Processing...' : null,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[100],
                child: Column(
                  children: [
                    const Text('LoadingOverlay Demo'),
                    const SizedBox(height: 10),
                    custom_buttons.PrimaryButton(
                      text: 'Trigger Loading Overlay',
                      onPressed: _simulateLoading,
                    ),
                  ],
                ),
              ),
            ),
          ]),

          _buildTestSection('Button Widgets', [
            custom_buttons.PrimaryButton(
              text: 'Primary Button',
              onPressed: () => print('Primary clicked'),
            ),
            const SizedBox(height: 8),
            custom_buttons.SecondaryButton(
              text: 'Secondary Button',
              onPressed: () => print('Secondary clicked'),
            ),
            const SizedBox(height: 8),
            custom_buttons.CustomOutlinedButton(
              text: 'Outlined Button',
              onPressed: () => print('Outlined clicked'),
            ),
            const SizedBox(height: 8),
            custom_buttons.DangerButton(
              text: 'Danger Button',
              onPressed: () => print('Danger clicked'),
            ),
            const SizedBox(height: 8),
            LoadingButton(
              isLoading: _isLoading,
              text: 'Loading Button',
              onPressed: _simulateLoading,
            ),
          ]),

          _buildTestSection('Form Widgets', [
            CustomTextField(
              label: 'Email',
              hintText: 'Enter your email',
              controller: _emailController,
            ),
            const SizedBox(height: 16),
            PasswordTextField(
              label: 'Password',
              controller: _passwordController,
            ),
            const SizedBox(height: 16),
            custom_buttons.PrimaryButton(
              text: 'Submit Form',
              onPressed: () {
                print('Email: ${_emailController.text}');
                print('Password: ${_passwordController.text}');
              },
            ),
          ]),

          _buildTestSection('State Widgets', [
            ErrorDisplayWidget(
              message: 'Failed to load medications. Please check your connection.',
              onRetry: () => print('Retry pressed'),
            ),
            const SizedBox(height: 20),
            EmptyStateWidget(
              title: 'No Medications Found',
              description: 'Add your first medication to get started with tracking your health journey.',
              icon: Icons.medication_outlined,
              actionText: 'Add First Medication',
              onAction: () => print('Add medication clicked'),
            ),
          ]),

          _buildTestSection('Combined Demo', [
            const Text('Simulate different app states:'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: custom_buttons.CustomOutlinedButton(
                    text: 'Show Loading',
                    onPressed: _simulateLoading,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: custom_buttons.DangerButton(
                    text: 'Show Error',
                    onPressed: () {
                      print('Error state triggered');
                    },
                  ),
                ),
              ],
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildTestSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}