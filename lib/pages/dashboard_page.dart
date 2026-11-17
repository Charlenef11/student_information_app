import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'account_settings_page.dart';
import 'students_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  // Listahan ng mga pages na naka-link sa Bottom Navigation Bar
  final List<Widget> _pages = [
    const DashboardHomeContent(),
    const StudentsPage(),
    const AccountSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Students',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Separate widget para sa mismong loob ng Dashboard Home tab para mas malinis
class DashboardHomeContent extends StatelessWidget {
  const DashboardHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final students = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('students');
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.surfaceContainerHighest,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Header Card
            Card(
              elevation: 0,
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: colorScheme.primary,
                      radius: 28,
                      child: Icon(Icons.person, color: colorScheme.onPrimary, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome back,',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            user.email ?? 'User',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            // Total Students Stream Counter Card
            StreamBuilder<QuerySnapshot>(
              stream: students.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Unable to load student count.'),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const LinearProgressIndicator();
                }
                final count = snapshot.data!.docs.length;
                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Students',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.school, size: 36, color: colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}



// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'account_settings_page.dart';
// import 'students_page.dart';

// class DashboardPage extends StatelessWidget {
//   const DashboardPage({super.key});
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser!;
//     final students = FirebaseFirestore.instance
//         .collection('users')
//         .doc(user.uid)
//         .collection('students');
//     return Scaffold(
//       appBar: AppBar(title: const Text('Dashboard')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'Welcome, ${user.email ?? 'User'}!',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const SizedBox(height: 20),
//             StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//               stream: students.snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError)
//                   return const Text('Unable to load student count.');
//                 if (!snapshot.hasData) return const LinearProgressIndicator();
//                 return Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(20),
//                     child: Text(
//                       'Total Students: ${snapshot.data!.docs.length}',
//                       style: const TextStyle(fontSize: 22),
//                     ),
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(height: 20),
//             FilledButton.icon(
//               onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const StudentsPage()),
//               ),
//               icon: const Icon(Icons.people),
//               label: const Text('Manage Students'),
//             ),
//             const SizedBox(height: 12),
//             OutlinedButton.icon(
//               onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const AccountSettingsPage()),
//               ),
//               icon: const Icon(Icons.settings),
//               label: const Text('Account Settings'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
