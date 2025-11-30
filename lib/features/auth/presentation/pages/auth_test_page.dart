import 'package:flutter/material.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../../../injection_container.dart';

/// Test page to verify Firebase Authentication is working
class AuthTestPage extends StatefulWidget {
  const AuthTestPage({super.key});

  @override
  State<AuthTestPage> createState() => _AuthTestPageState();
}

class _AuthTestPageState extends State<AuthTestPage> {
  final _authDataSource = getIt<AuthRemoteDataSource>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  String _status = 'Not authenticated';
  bool _isLoading = false;
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    try {
      final user = await _authDataSource.getCurrentUser();
      setState(() {
        if (user != null) {
          _currentUserEmail = user.email;
          _status = 'Logged in as: ${user.email}';
        } else {
          _currentUserEmail = null;
          _status = 'Not authenticated';
        }
      });
    } catch (e) {
      setState(() {
        _status = 'Error checking user: $e';
      });
    }
  }

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty || 
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty) {
      _showMessage('Please fill all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authDataSource.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        displayName: _nameController.text.trim(),
      );
      
      setState(() {
        _currentUserEmail = user.email;
        _status = '✅ Sign up successful! Logged in as: ${user.email}';
        _isLoading = false;
      });
      
      _showMessage('Account created successfully!');
    } catch (e) {
      setState(() {
        _status = '❌ Sign up failed: $e';
        _isLoading = false;
      });
      _showMessage('Sign up failed: $e');
    }
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('Please enter email and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authDataSource.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      setState(() {
        _currentUserEmail = user.email;
        _status = '✅ Sign in successful! Logged in as: ${user.email}';
        _isLoading = false;
      });
      
      _showMessage('Welcome back!');
    } catch (e) {
      setState(() {
        _status = '❌ Sign in failed: $e';
        _isLoading = false;
      });
      _showMessage('Sign in failed: $e');
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authDataSource.signInWithGoogle();
      
      setState(() {
        _currentUserEmail = user.email;
        _status = '✅ Google sign in successful! Logged in as: ${user.email}';
        _isLoading = false;
      });
      
      _showMessage('Welcome!');
    } catch (e) {
      setState(() {
        _status = '❌ Google sign in failed: $e';
        _isLoading = false;
      });
      _showMessage('Google sign in failed: $e');
    }
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);

    try {
      await _authDataSource.signOut();
      
      setState(() {
        _currentUserEmail = null;
        _status = '✅ Signed out successfully';
        _isLoading = false;
      });
      
      _showMessage('Signed out successfully!');
      
      // Clear form
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
    } catch (e) {
      setState(() {
        _status = '❌ Sign out failed: $e';
        _isLoading = false;
      });
      _showMessage('Sign out failed: $e');
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      _showMessage('Please enter your email');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authDataSource.sendPasswordResetEmail(_emailController.text.trim());
      
      setState(() {
        _status = '✅ Password reset email sent!';
        _isLoading = false;
      });
      
      _showMessage('Check your email for reset instructions');
    } catch (e) {
      setState(() {
        _status = '❌ Password reset failed: $e';
        _isLoading = false;
      });
      _showMessage('Password reset failed: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Auth Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: _currentUserEmail != null ? Colors.green[50] : Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    if (_currentUserEmail != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Current User: $_currentUserEmail',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // If logged in, show logout button
            if (_currentUserEmail != null) ...[
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _signOut,
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
            ],

            // Form fields
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name (for sign up)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 24),

            // Auth Buttons
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _signUp,
              icon: const Icon(Icons.person_add),
              label: const Text('Sign Up'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _signIn,
              icon: const Icon(Icons.login),
              label: const Text('Sign In'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _isLoading ? null : _signInWithGoogle,
              icon: Image.network(
                'https://www.google.com/favicon.ico',
                width: 20,
                height: 20,
                errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata),
              ),
              label: const Text('Sign In with Google'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),

            TextButton.icon(
              onPressed: _isLoading ? null : _resetPassword,
              icon: const Icon(Icons.email_outlined),
              label: const Text('Send Password Reset Email'),
            ),

            if (_isLoading) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
