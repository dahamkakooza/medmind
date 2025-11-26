// import 'package:flutter/material.dart';
//
// class SettingsPage extends StatelessWidget {
//   const SettingsPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Settings'),
//       ),
//       body: ListView(
//         children: [
//           ListTile(
//             leading: const Icon(Icons.palette),
//             title: const Text('Theme'),
//             subtitle: const Text('Light mode'),
//             onTap: () {},
//           ),
//           ListTile(
//             leading: const Icon(Icons.notifications),
//             title: const Text('Notifications'),
//             subtitle: const Text('Enabled'),
//             onTap: () {},
//           ),
//           ListTile(
//             leading: const Icon(Icons.language),
//             title: const Text('Language'),
//             subtitle: const Text('English'),
//             onTap: () {},
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:medmind/core/constants/route_constants.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: const Text('Light mode'),
            onTap: () {
              // TODO: Implement theme selection
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Enabled'),
            onTap: () {
              Navigator.pushNamed(context, RouteConstants.notifications);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('English'),
            onTap: () {
              // TODO: Implement language selection
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Privacy & Security'),
            onTap: () {
              Navigator.pushNamed(context, RouteConstants.privacySecurity);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pushNamed(context, RouteConstants.helpSupport);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pushNamed(context, RouteConstants.about);
            },
          ),
        ],
      ),
    );
  }
}