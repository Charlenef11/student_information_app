import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'student_form_page.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('students');
    
    final theme = Theme.of(context);

    return Scaffold(
      // Solid color AppBar na may icon at tugma sa tema (walang gradient)
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_alt_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Student Records',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StudentFormPage()),
        ),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add Student'),
      ),
      body: StreamBuilder(
        stream: collection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load students.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_off_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'No student records yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap "Add Student" to create a new record.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
             final data = doc.data();
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        (data['fullName'] ?? 'U').substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      data['fullName'] ?? 'No Name',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.badge_outlined, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('${data['studentNumber'] ?? 'N/A'}'),
                              const SizedBox(width: 12),
                              const Icon(Icons.school_outlined, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${data['course'] ?? 'N/A'} (${data['yearLevel'] ?? 'N/A'})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  data['email'] ?? 'No Email',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (action) async {
                        if (action == 'edit') {
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudentFormPage(
                                documentId: doc.id,
                                initialData: data,
                              ),
                            ),
                          );
                        } else if (action == 'delete') {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Delete student?'),
                              content: Text(
                                'Delete ${data['fullName']}? This cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, true),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            try {
                              await collection.doc(doc.id).delete();
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Delete failed: $e')),
                                );
                              }
                            }
                          }
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

















// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'student_form_page.dart';

// class StudentsPage extends StatelessWidget {
//   const StudentsPage({super.key});
//   @override
//   Widget build(BuildContext context) {
//     final uid = FirebaseAuth.instance.currentUser!.uid;
//     final collection = FirebaseFirestore.instance
//         .collection('users')
//         .doc(uid)
//         .collection('students');
//     return Scaffold(
//       appBar: AppBar(title: const Text('Student Records')),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const StudentFormPage()),
//         ),
//         icon: const Icon(Icons.add),
//         label: const Text('Add Student'),
//       ),
//       body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//         stream: collection.orderBy('fullName').snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return const Center(child: Text('Unable to load students.'));
//           }
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           final docs = snapshot.data!.docs;
//           if (docs.isEmpty) {
//             return const Center(
//               child: Text('No student records yet. Tap Add Student.'),
//             );
//           }
//           return ListView.builder(
//             padding: const EdgeInsets.only(bottom: 90),
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final doc = docs[index];
//               final data = doc.data();
//               return Card(
//                 child: ListTile(
//                   title: Text('${data['fullName'] ?? ''}'),
//                   subtitle: Text(
//                     '${data['studentNumber'] ?? ''} • ${data['course'] ?? ''} • ${data['yearLevel'] ?? ''}\n${data['email'] ?? ''}',
//                   ),
//                   isThreeLine: true,
//                   trailing: PopupMenuButton<String>(
//                     onSelected: (action) async {
//                       if (action == 'edit') {
//                         if (!context.mounted) return;
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => StudentFormPage(
//                               documentId: doc.id,
//                               initialData: data,
//                             ),
//                           ),
//                         );
//                       } else if (action == 'delete') {
//                         final confirmed = await showDialog<bool>(
//                           context: context,
//                           builder: (dialogContext) => AlertDialog(
//                             title: const Text('Delete student?'),
//                             content: Text(
//                               'Delete ${data['fullName']}? This cannot be undone.',
//                             ),
//                             actions: [
//                               TextButton(
//                                 onPressed: () =>
//                                     Navigator.pop(dialogContext, false),
//                                 child: const Text('Cancel'),
//                               ),
//                               FilledButton(
//                                 onPressed: () =>
//                                     Navigator.pop(dialogContext, true),
//                                 child: const Text('Delete'),
//                               ),
//                             ],
//                           ),
//                         );
//                         if (confirmed == true) {
//                           try {
//                             await collection.doc(doc.id).delete();
//                           } catch (e) {
//                             if (context.mounted) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text('Delete failed: $e')),
//                               );
//                             }
//                           }
//                         }
//                       }
//                     },
//                     itemBuilder: (_) => const [
//                       PopupMenuItem(value: 'edit', child: Text('Edit')),
//                       PopupMenuItem(value: 'delete', child: Text('Delete')),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
