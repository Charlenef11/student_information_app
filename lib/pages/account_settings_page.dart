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
          const SnackBar(content: Text('Password updated successfully.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Password update failed.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final theme = Theme.of(context);

    return Scaffold(
      // Solid color na AppBar (walang gradient, walang pinalitang iba)
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Account Settings',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Aesthetic User Profile Header Card na may soft gradient/shadow
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    // ignore: deprecated_member_use
                    theme.colorScheme.primaryContainer.withOpacity(0.4),
                    theme.colorScheme.surface,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  // ignore: deprecated_member_use
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: theme.colorScheme.primary.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: theme.colorScheme.primary,
                      child: const Icon(
                        Icons.person_rounded,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Signed in as',
                      style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Security Header
            Row(
              children: [
                Icon(Icons.lock_person_rounded, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Security & Password',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Current Password Field (Ibinalik sa dating lock icon)
            TextField(
              controller: _currentPassword,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // New Password Field (Ibinalik sa dating lock reset icon)
            TextField(
              controller: _newPassword,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: const Icon(Icons.lock_reset_rounded),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Aesthetic Filled Button with Shadow
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FilledButton.icon(
                onPressed: _loading ? null : _changePassword,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.security_rounded),
                label: Text(_loading ? 'Updating...' : 'Update Password'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Divider(height: 1),
            const SizedBox(height: 28),

            // Logout Button
            OutlinedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              label: const Text(
                'Logout Account',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                // ignore: deprecated_member_use
                side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
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
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Password updated successfully.')),
//         );
//       }
//     } on FirebaseAuthException catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(e.message ?? 'Password update failed.')),
//         );
//       }
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
