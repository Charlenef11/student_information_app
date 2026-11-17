import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;
    
    if (_currentPassword.text.isEmpty || _newPassword.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter your current password and a new password of at least 6 characters.',
          ),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPassword.text,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newPassword.text);
      
      _currentPassword.clear();
      _newPassword.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Password update failed.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Account Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.surfaceContainerHighest,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Info Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Logged in as',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Change Password Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Change Password',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Ensure your account is secure by using a strong password.',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        TextField(
                          controller: _currentPassword,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Current Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        TextField(
                          controller: _newPassword,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'New Password (min. 6 chars)',
                            prefixIcon: const Icon(Icons.lock_reset),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        SizedBox(
                          height: 48,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _loading ? null : _changePassword,
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Update Password',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Logout Button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Log out'),
                        content: const Text('Are you sure you want to log out of your account?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.error,
                            ),
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: const Text('Log out'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class AccountSettingsPage extends StatefulWidget {
//   const AccountSettingsPage({super.key});
//   @override
//   State<AccountSettingsPage> createState() => _AccountSettingsPageState();
// }

// class _AccountSettingsPageState extends State<AccountSettingsPage> {
//   final _currentPassword = TextEditingController();
//   final _newPassword = TextEditingController();
//   bool _loading = false;
//   @override
//   void dispose() {
//     _currentPassword.dispose();
//     _newPassword.dispose();
//     super.dispose();
//   }

//   Future<void> _changePassword() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null || user.email == null) return;
//     if (_currentPassword.text.isEmpty || _newPassword.text.length < 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Enter your current password and a new password of at least 6 characters.',
//           ),
//         ),
//       );
//       return;
//     }
//     setState(() => _loading = true);
//     try {
//       final credential = EmailAuthProvider.credential(
//         email: user.email!,
//         password: _currentPassword.text,
//       );
//       await user.reauthenticateWithCredential(credential);
//       await user.updatePassword(_newPassword.text);
//       _currentPassword.clear();
//       _newPassword.clear();
//       if (mounted)
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Password updated successfully.')),
//         );
//     } on FirebaseAuthException catch (e) {
//       if (mounted)
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(e.message ?? 'Password update failed.')),
//         );
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser!;
//     return Scaffold(
//       appBar: AppBar(title: const Text('Account Settings')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const Icon(Icons.account_circle, size: 72),
//             const SizedBox(height: 12),
//             Text('Email: ${user.email ?? 'Unknown'}'),
//             const SizedBox(height: 24),
//             Text(
//               'Change Password',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _currentPassword,
//               obscureText: true,
//               decoration: const InputDecoration(
//                 labelText: 'Current Password',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _newPassword,
//               obscureText: true,
//               decoration: const InputDecoration(
//                 labelText: 'New Password',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 12),
//             FilledButton(
//               onPressed: _loading ? null : _changePassword,
//               child: const Text('Update Password'),
//             ),
//             const SizedBox(height: 24),
//             OutlinedButton.icon(
//               onPressed: () async {
//                 await FirebaseAuth.instance.signOut();
//                 if (context.mounted) Navigator.pop(context);
//               },
//               icon: const Icon(Icons.logout),
//               label: const Text('Logout'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
