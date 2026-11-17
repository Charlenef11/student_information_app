import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pet_form.dart';

class PetsScreen extends StatelessWidget {
  const PetsScreen({super.key}); // <-- Nilinis natin dito, wala nang required docId at existingData

  Future<void> _confirmDelete(
    BuildContext context,
    CollectionReference collection,
    String docId,
    String petName,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text('Are you sure you want to delete "$petName" from the clinic log?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await collection.doc(docId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$petName" deleted successfully.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final petsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('pets');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Clinic Records', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF00796B),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PetForm()),
          );
        },
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Pet'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: petsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = List<QueryDocumentSnapshot>.from(snapshot.data?.docs ?? []);
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No pet records yet.\nTap "+ Add Pet" to create one.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          docs.sort((a, b) {
            final nameA = (a['petName'] ?? '').toString().toLowerCase();
            final nameB = (b['petName'] ?? '').toString().toLowerCase();
            return nameA.compareTo(nameB);
          });

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final petName = data['petName'] ?? 'Unnamed';
              final species = data['species'] ?? 'Pet';
              final ownerName = data['ownerName'] ?? 'Unknown';
              final serviceType = data['serviceType'] ?? 'Check-up';
              final status = data['status'] ?? 'Pending';
              final isCompleted = status == 'Completed';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.teal.shade100,
                            child: const Icon(Icons.pets, color: Color(0xFF00796B)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$petName ($species)', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                Text('Owner: $ownerName', style: const TextStyle(color: Colors.black87)),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text(
                              status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isCompleted ? Colors.green.shade800 : Colors.orange.shade900,
                              ),
                            ),
                            backgroundColor: isCompleted ? Colors.green.shade100 : Colors.orange.shade100,
                            side: BorderSide.none,
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Service: $serviceType', style: const TextStyle(fontWeight: FontWeight.w500)),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PetForm(
                                        docId: doc.id,
                                        existingData: data,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red.shade700),
                                onPressed: () => _confirmDelete(context, petsCollection, doc.id, petName),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
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