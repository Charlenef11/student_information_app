import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final students = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('students');

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.dashboard_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Dashboard',
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Banner Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer,
                    // ignore: deprecated_member_use
                    theme.colorScheme.secondaryContainer.withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(
                      Icons.school,
                      color: theme.colorScheme.onPrimary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back,',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email ?? 'User',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Statistics Card (Total Students)
            StreamBuilder<QuerySnapshot>(
              stream: students.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Card(
                    color: Colors.redAccent,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Unable to load student count.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: LinearProgressIndicator());
                }

                final totalStudents = snapshot.data!.docs.length;

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Enrolled Students',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$totalStudents',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 28,
                          // ignore: deprecated_member_use
                          backgroundColor:
                              // ignore: deprecated_member_use
                              theme.colorScheme.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.group,
                            size: 32,
                            color: theme.colorScheme.primary,
                          ),
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
    
//     final theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: theme.colorScheme.primary,
//         foregroundColor: Colors.white,
//         title: const Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.dashboard_rounded, color: Colors.white, size: 22),
//             SizedBox(width: 8),
//             Text(
//               'Dashboard',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Welcome Banner Card
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     theme.colorScheme.primaryContainer,
//                     // ignore: deprecated_member_use
//                     theme.colorScheme.secondaryContainer.withOpacity(0.5),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 28,
//                     backgroundColor: theme.colorScheme.primary,
//                     child: Icon(
//                       Icons.school,
//                       color: theme.colorScheme.onPrimary,
//                       size: 28,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Welcome back,',
//                           style: TextStyle(fontSize: 13, color: Colors.black54),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           user.email ?? 'User',
//                           style: const TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),

//             // Statistics Card (Total Students)
//             StreamBuilder<QuerySnapshot>(
//               stream: students.snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return const Card(
//                     color: Colors.redAccent,
//                     child: Padding(
//                       padding: EdgeInsets.all(16.0),
//                       child: Text('Unable to load student count.', style: TextStyle(color: Colors.white)),
//                     ),
//                   );
//                 }
//                 if (!snapshot.hasData) {
//                   return const Center(child: LinearProgressIndicator());
//                 }
                
//                 final totalStudents = snapshot.data!.docs.length;

//                 return Card(
//                   elevation: 3,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(24.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Enrolled Students',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               '$totalStudents',
//                               style: TextStyle(
//                                 fontSize: 36,
//                                 fontWeight: FontWeight.bold,
//                                 color: theme.colorScheme.primary,
//                               ),
//                             ),
//                           ],
//                         ),
//                         CircleAvatar(
//                           radius: 28,
//                           // ignore: deprecated_member_use
//                           backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
//                           child: Icon(
//                             Icons.group,
//                             size: 32,
//                             color: theme.colorScheme.primary,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(height: 32),

//             // Navigation Actions
//             Text(
//               'Quick Actions',
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: theme.colorScheme.primary,
//               ),
//             ),
//             const SizedBox(height: 12),

//             FilledButton.icon(
//               onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const StudentsPage()),
//               ),
//               icon: const Icon(Icons.people_outline),
//               label: const Text('Manage Students', style: TextStyle(fontSize: 16)),
//               style: FilledButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),

//             OutlinedButton.icon(
//               onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const AccountSettingsPage()),
//               ),
//               icon: const Icon(Icons.settings_outlined),
//               label: const Text('Account Settings', style: TextStyle(fontSize: 16)),
//               style: OutlinedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }