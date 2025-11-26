// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../blocs/auth_bloc.dart';
// import '../blocs/auth_event.dart';
// import '../blocs/auth_state.dart';
// import '../../../../core/widgets/custom_button.dart' as custom_buttons;
// import '../../../../core/widgets/custom_text_field.dart';
// import '../../../../core/widgets/loading_widget.dart';
// import '../../../../core/widgets/error_widget.dart';
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _emailFocusNode = FocusNode();
//   final _passwordFocusNode = FocusNode();
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _emailFocusNode.dispose();
//     _passwordFocusNode.dispose();
//     super.dispose();
//   }
//
//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       context.read<AuthBloc>().add(
//         SignInRequested(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//         ),
//       );
//     }
//   }
//
//   void _navigateToRegister() {
//     Navigator.pushNamed(context, '/register');
//   }
//
//   void _navigateToForgotPassword() {
//     Navigator.pushNamed(context, '/forgot-password');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocConsumer<AuthBloc, AuthState>(
//         listener: (context, state) {
//           if (state is Authenticated) {
//             Navigator.pushReplacementNamed(context, '/dashboard');
//           }
//         },
//         builder: (context, state) {
//           return LoadingOverlay(
//             isLoading: state is SignInLoading || state is GoogleSignInLoading,
//             message: 'Signing in...',
//             child: Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // Logo and Title
//                     _buildHeader(),
//                     const SizedBox(height: 48),
//
//                     // Email Field
//                     CustomTextField(
//                       label: 'Email',
//                       controller: _emailController,
//                       keyboardType: TextInputType.emailAddress,
//                       focusNode: _emailFocusNode,
//                       textInputAction: TextInputAction.next,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your email';
//                         }
//                         if (!RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
//                             .hasMatch(value)) {
//                           return 'Please enter a valid email';
//                         }
//                         return null;
//                       },
//                       onEditingComplete: () {
//                         _passwordFocusNode.requestFocus();
//                       },
//                     ),
//                     const SizedBox(height: 16),
//
//                     // Password Field
//                     PasswordTextField(
//                       label: 'Password',
//                       controller: _passwordController,
//                       focusNode: _passwordFocusNode,
//                       textInputAction: TextInputAction.done,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your password';
//                         }
//                         if (value.length < 6) {
//                           return 'Password must be at least 6 characters';
//                         }
//                         return null;
//                       },
//                       onEditingComplete: _submitForm,
//                     ),
//                     const SizedBox(height: 8),
//
//                     // Forgot Password
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: TextButton(
//                         onPressed: _navigateToForgotPassword,
//                         child: Text(
//                           'Forgot Password?',
//                           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                             color: Theme.of(context).colorScheme.primary,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//
//                     // Sign In Button
//                     custom_buttons.PrimaryButton(
//                       text: 'Sign In',
//                       onPressed: _submitForm,
//                     ),
//                     const SizedBox(height: 16),
//
//                     // Google Sign In
//                     custom_buttons.CustomOutlinedButton(
//                       text: 'Continue with Google',
//                       onPressed: () {
//                         context.read<AuthBloc>().add(GoogleSignInRequested());
//                       },
//                       icon: Icons.g_mobiledata,
//                     ),
//                     const SizedBox(height: 24),
//
//                     // Sign Up Link
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           "Don't have an account?",
//                           style: Theme.of(context).textTheme.bodyMedium,
//                         ),
//                         const SizedBox(width: 8),
//                         GestureDetector(
//                           onTap: _navigateToRegister,
//                           child: Text(
//                             'Sign Up',
//                             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                               color: Theme.of(context).colorScheme.primary,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     // Error Display
//                     if (state is SignInError) ...[
//                       const SizedBox(height: 16),
//                       ErrorDisplayWidget(
//                         message: state.message,
//                         onRetry: _submitForm,
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Column(
//       children: [
//         // App Logo/Icon
//         Container(
//           width: 80,
//           height: 80,
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.primary,
//             shape: BoxShape.circle,
//           ),
//           child: Icon(
//             Icons.medical_services,
//             size: 40,
//             color: Theme.of(context).colorScheme.onPrimary,
//           ),
//         ),
//         const SizedBox(height: 24),
//         Text(
//           'Welcome to MedMind',
//           style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           'Sign in to manage your medications',
//           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//             color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../../../../core/widgets/custom_button.dart' as custom_buttons;
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        SignInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  void _navigateToRegister() {
    Navigator.pushNamed(context, '/register');
  }

  void _navigateToForgotPassword() {
    Navigator.pushNamed(context, '/forgot-password');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is SignInLoading || state is GoogleSignInLoading,
            message: 'Signing in...',
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo and Title
                      _buildHeader(),
                      const SizedBox(height: 48),

                      // Email Field
                      CustomTextField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        focusNode: _emailFocusNode,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        onEditingComplete: () {
                          _passwordFocusNode.requestFocus();
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      PasswordTextField(
                        label: 'Password',
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        onEditingComplete: _submitForm,
                      ),
                      const SizedBox(height: 8),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _navigateToForgotPassword,
                          child: Text(
                            'Forgot Password?',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Sign In Button
                      custom_buttons.PrimaryButton(
                        text: 'Sign In',
                        onPressed: _submitForm,
                      ),
                      const SizedBox(height: 16),

                      // Google Sign In
                      custom_buttons.CustomOutlinedButton(
                        text: 'Continue with Google',
                        onPressed: () {
                          context.read<AuthBloc>().add(GoogleSignInRequested());
                        },
                        icon: Icons.g_mobiledata,
                      ),
                      const SizedBox(height: 24),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _navigateToRegister,
                            child: Text(
                              'Sign Up',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Error Display
                      if (state is SignInError) ...[
                        const SizedBox(height: 16),
                        ErrorDisplayWidget(
                          message: state.message,
                          onRetry: _submitForm,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Logo/Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.medical_services,
            size: 40,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome to MedMind',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to manage your medications',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}