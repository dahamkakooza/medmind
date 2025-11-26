
import 'package:flutter/material.dart';
import 'package:medmind/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:medmind/injection_container.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPageSimple(),
    MedicationListPageSimple(),
    AdherenceHistoryPageSimple(),
    ProfilePageSimple(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication),
            label: 'Medications',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'Auth Test',
          ),
        ],
      ),
    );
  }
}

// Simplified Dashboard Page
class DashboardPageSimple extends StatelessWidget {
  const DashboardPageSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good morning'),
            Text(
              'Let\'s start your day right',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Adherence Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Today\'s Adherence',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: 0.5,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey[200],
                          ),
                          const Center(
                            child: Text(
                              '50%',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('2 of 4 medications taken'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Today's Medications
            const Text(
              'Today\'s Medications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            _buildMedicationCard(
              'Lisinopril',
              '10mg at 8:00 AM',
              true,
              Colors.green,
            ),
            _buildMedicationCard(
              'Metformin',
              '500mg at 12:00 PM',
              true,
              Colors.green,
            ),
            _buildMedicationCard(
              'Atorvastatin',
              '20mg at 6:00 PM',
              false,
              Colors.red,
            ),
            _buildMedicationCard(
              'Vitamin D3',
              '1000 IU at 8:00 PM',
              false,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationCard(
    String name,
    String dosage,
    bool taken,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(
            taken ? Icons.check_circle : Icons.circle_outlined,
            color: color,
          ),
        ),
        title: Text(name),
        subtitle: Text(dosage),
        trailing: taken
            ? Icon(Icons.check_circle, color: color)
            : ElevatedButton(onPressed: () {}, child: const Text('Take Now')),
      ),
    );
  }
}

// Simplified Medications Page
class MedicationListPageSimple extends StatelessWidget {
  const MedicationListPageSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Medications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMedicationCard('Lisinopril', '10mg', 'Daily at 8:00 AM'),
          _buildMedicationCard('Metformin', '500mg', 'Twice daily'),
          _buildMedicationCard('Atorvastatin', '20mg', 'Daily at 6:00 PM'),
          _buildMedicationCard('Vitamin D3', '1000 IU', 'Daily at 8:00 PM'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMedicationCard(String name, String dosage, String schedule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.medication)),
        title: Text(name),
        subtitle: Text('$dosage • $schedule'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}

// Simplified History Page
class AdherenceHistoryPageSimple extends StatelessWidget {
  const AdherenceHistoryPageSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adherence History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Monthly Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'November 2025',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('75%', 'Adherence Rate'),
                        _buildStat('23', 'Days Tracked'),
                        _buildStat('7', 'Missed Days'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Recent Activity
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            _buildActivityItem('Lisinopril', 'Taken today at 8:00 AM', true),
            _buildActivityItem('Metformin', 'Taken today at 12:00 PM', true),
            _buildActivityItem('Atorvastatin', 'Missed yesterday', false),
            _buildActivityItem(
              'Vitamin D3',
              'Taken yesterday at 8:00 PM',
              true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActivityItem(String name, String details, bool taken) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          taken ? Icons.check_circle : Icons.cancel,
          color: taken ? Colors.green : Colors.red,
        ),
        title: Text(name),
        subtitle: Text(details),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

// Simplified Profile Page
class ProfilePageSimple extends StatelessWidget {
  const ProfilePageSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 16),
            const Text(
              'John Doe',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'john.doe@example.com',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            _buildOption(Icons.person_outline, 'Edit Profile'),
            _buildOption(Icons.notifications_outlined, 'Notifications'),
            _buildOption(Icons.security_outlined, 'Privacy & Security'),
            _buildOption(Icons.help_outline, 'Help & Support'),
            _buildOption(Icons.info_outline, 'About'),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final authDataSource = getIt<AuthRemoteDataSource>();
                    await authDataSource.signOut();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Signed out successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ Logout failed: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(IconData icon, String title) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
