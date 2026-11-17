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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Records',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.surfaceContainerHighest,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StudentFormPage()),
        ),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Student'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: collection.orderBy('fullName').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Unable to load students.'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No student records yet.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tap "Add Student" below to get started.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
              
              final fullName = data['fullName'] as String? ?? 'No Name';
              final studentNumber = data['studentNumber'] as String? ?? 'No ID';
              final course = data['course'] as String? ?? 'No Course';
              final yearLevel = data['yearLevel'] as String? ?? '';
              final email = data['email'] as String? ?? 'No Email';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          fullName.isNotEmpty ? fullName[0].toUpperCase() : 'S',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      title: Text(
                        fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.badge_outlined, size: 14, color: colorScheme.primary),
                                const SizedBox(width: 4),
                                Text('$studentNumber • $course ($yearLevel)'),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    email,
                                    style: const TextStyle(color: Colors.grey),
                                    overflow: TextOverflow.ellipsis,
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
                                  'Are you sure you want to delete $fullName? This action cannot be undone.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: colorScheme.error,
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, true),
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
//           if (snapshot.hasError)
//             return const Center(child: Text('Unable to load students.'));
//           if (!snapshot.hasData)
//             return const Center(child: CircularProgressIndicator());
//           final docs = snapshot.data!.docs;
//           if (docs.isEmpty)
//             return const Center(
//               child: Text('No student records yet. Tap Add Student.'),
//             );
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
//                             if (context.mounted)
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text('Delete failed: $e')),
//                               );
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
