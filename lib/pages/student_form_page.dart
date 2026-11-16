import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentFormPage extends StatefulWidget {
  final String? documentId;
  final Map<String, dynamic>? initialData;
  const StudentFormPage({super.key, this.documentId, this.initialData});

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _number;
  late final TextEditingController _name;
  late final TextEditingController _course;
  late final TextEditingController _year;
  late final TextEditingController _email;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData ?? {};
    _number = TextEditingController(text: d['studentNumber'] ?? '');
    _name = TextEditingController(text: d['fullName'] ?? '');
    _course = TextEditingController(text: d['course'] ?? '');
    _year = TextEditingController(text: d['yearLevel'] ?? '');
    _email = TextEditingController(text: d['email'] ?? '');
  }

  @override
  void dispose() {
    for (final c in [_number, _name, _course, _year, _email]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _saving = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('students');
    final data = <String, dynamic>{
      'studentNumber': _number.text.trim(),
      'fullName': _name.text.trim(),
      'course': _course.text.trim(),
      'yearLevel': _year.text.trim(),
      'email': _email.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    try {
      if (widget.documentId == null) {
        await collection.add({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await collection.doc(widget.documentId).update(data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool email = false,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return '$label is required';
          if (email &&
              !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
            return 'Enter a valid email';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.documentId != null;
    final theme = Theme.of(context);

    return Scaffold(
      // Solid color AppBar na may icon at tugma sa tema (walang gradient)
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isEditing ? Icons.edit_note_rounded : Icons.person_add_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              isEditing ? 'Edit Student' : 'Add Student',
              style: const TextStyle(
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
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _key,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(
                              isEditing ? Icons.edit : Icons.person_add,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            isEditing ? 'Update Student Details' : 'Student Information',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _field(_number, 'Student Number', icon: Icons.badge_outlined),
                      _field(_name, 'Full Name', icon: Icons.person_outline),
                      _field(_course, 'Course', icon: Icons.school_outlined),
                      _field(_year, 'Year Level', icon: Icons.stairs_outlined),
                      _field(_email, 'Email', email: true, icon: Icons.email_outlined),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _saving ? 'Saving...' : (isEditing ? 'Update Student' : 'Save Student'),
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
















// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class StudentFormPage extends StatefulWidget {
//   final String? documentId;
//   final Map<String, dynamic>? initialData;
//   const StudentFormPage({super.key, this.documentId, this.initialData});
//   @override
//   State<StudentFormPage> createState() => _StudentFormPageState();
// }

// class _StudentFormPageState extends State<StudentFormPage> {
//   final _key = GlobalKey<FormState>();
//   late final TextEditingController _number;
//   late final TextEditingController _name;
//   late final TextEditingController _course;
//   late final TextEditingController _year;
//   late final TextEditingController _email;
//   bool _saving = false;
//   @override
//   void initState() {
//     super.initState();
//     final d = widget.initialData ?? {};
//     _number = TextEditingController(text: d['studentNumber'] ?? '');
//     _name = TextEditingController(text: d['fullName'] ?? '');
//     _course = TextEditingController(text: d['course'] ?? '');
//     _year = TextEditingController(text: d['yearLevel'] ?? '');
//     _email = TextEditingController(text: d['email'] ?? '');
//   }

//   @override
//   void dispose() {
//     for (final c in [_number, _name, _course, _year, _email]) {
//       c.dispose();
//     }
//     super.dispose();
//   }

//   Future<void> _save() async {
//     if (!_key.currentState!.validate()) return;
//     setState(() => _saving = true);
//     final uid = FirebaseAuth.instance.currentUser!.uid;
//     final collection = FirebaseFirestore.instance
//         .collection('users')
//         .doc(uid)
//         .collection('students');
//     final data = <String, dynamic>{
//       'studentNumber': _number.text.trim(),
//       'fullName': _name.text.trim(),
//       'course': _course.text.trim(),
//       'yearLevel': _year.text.trim(),
//       'email': _email.text.trim(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     };
//     try {
//       if (widget.documentId == null) {
//         await collection.add({
//           ...data,
//           'createdAt': FieldValue.serverTimestamp(),
//         });
//       } else {
//         await collection.doc(widget.documentId).update(data);
//       }
//       if (mounted) Navigator.pop(context);
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
//       }
//     } finally {
//       if (mounted) setState(() => _saving = false);
//     }
//   }

//   Widget _field(
//     TextEditingController controller,
//     String label, {
//     bool email = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
//         decoration: InputDecoration(
//           labelText: label,
//           border: const OutlineInputBorder(),
//         ),
//         validator: (v) {
//           if (v == null || v.trim().isEmpty) return '$label is required';
//           if (email &&
//               !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
//             return 'Enter a valid email';
//           }
//           return null;
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.documentId == null ? 'Add Student' : 'Edit Student'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _key,
//           child: Column(
//             children: [
//               _field(_number, 'Student Number'),
//               _field(_name, 'Full Name'),
//               _field(_course, 'Course'),
//               _field(_year, 'Year Level'),
//               _field(_email, 'Email', email: true),
//               FilledButton(
//                 onPressed: _saving ? null : _save,
//                 child: Text(_saving ? 'Saving...' : 'Save Student'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
