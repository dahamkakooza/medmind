// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:medmind/core/constants/route_constants.dart';
// import 'package:medmind/features/auth/presentation/blocs/auth_bloc.dart';
//
// class SplashPage extends StatefulWidget {
//   const SplashPage({super.key});
//
//   @override
//   State<SplashPage> createState() => _SplashPageState();
// }
//
// class _SplashPageState extends State<SplashPage> {
//   @override
//   void initState() {
//     super.initState();
//     _checkAuthStatus();
//   }
//
//   void _checkAuthStatus() {
//     // Auth check is handled by the AuthBloc in main.dart
//     // This page just shows loading while the check happens
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthBloc, AuthState>(
//       listener: (context, state) {
//         if (state is AuthAuthenticated) {
//           Navigator.pushReplacementNamed(context, RouteConstants.dashboard);
//         } else if (state is AuthUnauthenticated) {
//           Navigator.pushReplacementNamed(context, RouteConstants.login);
//         }
//       },
//       child: Scaffold(
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // App logo
//               Icon(
//                 Icons.medical_services,
//                 size: 80,
//                 color: Colors.white,
//               ),
//               const SizedBox(height: 20),
//               // App name
//               Text(
//                 'MedMind',
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // Loading indicator
//               CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medmind/core/constants/route_constants.dart';
import '../blocs/auth_bloc.dart';

import '../blocs/auth_state.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('🔐 SplashPage - Auth State: $state');

        if (state is Authenticated) {
          print('✅ User authenticated, navigating to dashboard');
          Navigator.pushReplacementNamed(context, RouteConstants.dashboard);
        } else if (state is Unauthenticated) {
          print('❌ User not authenticated, navigating to login');
          Navigator.pushReplacementNamed(context, RouteConstants.login);
        } else if (state is SignUpSuccess) {
          print('✅ Sign up successful, navigating to dashboard');
          Navigator.pushReplacementNamed(context, RouteConstants.dashboard);
        }
        // Stay on splash screen for loading/initial states
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medical_services,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              Text(
                'MedMind',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}