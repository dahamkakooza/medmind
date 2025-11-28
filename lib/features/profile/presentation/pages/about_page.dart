import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // App Logo and Name
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medical_services,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'MedMind',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your Personal Medication Companion',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // App Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About MedMind',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'MedMind is designed to help you manage your medications effectively. '
                          'Set reminders, track adherence, and maintain your health journey with ease. '
                          'Our mission is to make medication management simple and reliable.',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // App Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Version', '1.0.0 (1)'),
                    _buildInfoRow('Package Name', 'com.medmind.app'),
                    _buildInfoRow('Last Updated', 'December 2024'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Features
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem('💊 Medication Tracking', 'Add and manage all your medications'),
                    _buildFeatureItem('⏰ Smart Reminders', 'Never miss a dose with custom reminders'),
                    _buildFeatureItem('📊 Adherence Analytics', 'Track your medication adherence over time'),
                    _buildFeatureItem('🏥 Health Profile', 'Store important health information'),
                    _buildFeatureItem('🔒 Privacy First', 'Your data is secure and private'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Links
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Links',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLinkItem(
                      'Privacy Policy',
                      Icons.privacy_tip,
                          () => _launchPrivacyPolicy(),
                    ),
                    _buildLinkItem(
                      'Terms of Service',
                      Icons.description,
                          () => _launchTermsOfService(),
                    ),
                    _buildLinkItem(
                      'Website',
                      Icons.language,
                          () => _launchWebsite(),
                    ),
                    _buildLinkItem(
                      'Rate App',
                      Icons.star,
                          () => _rateApp(context),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Team Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Development Team',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'MedMind is developed by a dedicated team passionate about improving healthcare through technology.',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    _buildTeamMember('Lead Developer', 'Technical Architecture'),
                    _buildTeamMember('UI/UX Designer', 'User Experience'),
                    _buildTeamMember('Medical Advisor', 'Healthcare Guidance'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Acknowledgments
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acknowledgments',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Special thanks to our beta testers and the healthcare professionals who provided valuable feedback to make MedMind better.',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Copyright
            const Text(
              '© 2024 MedMind. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 20),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildTeamMember(String role, String responsibility) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            responsibility,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPrivacyPolicy() async {
    final Uri url = Uri.parse('https://medmind.com/privacy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showLaunchError();
    }
  }

  Future<void> _launchTermsOfService() async {
    final Uri url = Uri.parse('https://medmind.com/terms');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showLaunchError();
    }
  }

  Future<void> _launchWebsite() async {
    final Uri url = Uri.parse('https://medmind.com');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showLaunchError();
    }
  }

  void _rateApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate MedMind'),
        content: const Text('Thank you for using MedMind! Rating the app helps us improve and reach more people who need medication management help.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _launchAppStore(context);
            },
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );
  }

  void _launchAppStore(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('App store rating feature coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showLaunchError() {
    // This would show an error in a real app
  }
}