import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PetForm extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? existingData;

  const PetForm({super.key, this.docId, this.existingData});

  @override
  State<PetForm> createState() => _PetFormState();
}

class _PetFormState extends State<PetForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _petNameController;
  late final TextEditingController _ownerNameController;

  String _selectedSpecies = 'Dog';
  String _selectedService = 'Grooming';
  String _selectedStatus = 'Pending';
  bool _isSaving = false;

  final List<String> _speciesOptions = ['Dog', 'Cat', 'Bird', 'Rabbit', 'Other'];
  final List<String> _serviceOptions = ['Grooming', 'Vaccination', 'General Check-up', 'Dental Care'];
  final List<String> _statusOptions = ['Pending', 'Completed'];

  bool get _isEditing => widget.docId != null;

  @override
  void initState() {
    super.initState();
    final data = widget.existingData;
    _petNameController = TextEditingController(text: data?['petName'] ?? '');
    _ownerNameController = TextEditingController(text: data?['ownerName'] ?? '');

    if (data != null) {
      if (_speciesOptions.contains(data['species'])) _selectedSpecies = data['species'];
      if (_serviceOptions.contains(data['serviceType'])) _selectedService = data['serviceType'];
      if (_statusOptions.contains(data['status'])) _selectedStatus = data['status'];
    }
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final collection = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('pets');

      final payload = {
        'petName': _petNameController.text.trim(),
        'species': _selectedSpecies,
        'ownerName': _ownerNameController.text.trim(),
        'serviceType': _selectedService,
        'status': _selectedStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_isEditing) {
        await collection.doc(widget.docId).update(payload);
      } else {
        await collection.add(payload);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Pet record updated!' : 'Pet record added!'),
            backgroundColor: Colors.teal.shade700,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red.shade700),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _petNameController.dispose();
    _ownerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Pet Record' : 'Add New Pet Record'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _petNameController,
                decoration: const InputDecoration(labelText: '1. Pet Name', prefixIcon: Icon(Icons.pets)),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter pet name' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedSpecies,
                decoration: const InputDecoration(labelText: '2. Species', prefixIcon: Icon(Icons.category_outlined)),
                items: _speciesOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _selectedSpecies = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ownerNameController,
                decoration: const InputDecoration(labelText: '3. Owner Full Name', prefixIcon: Icon(Icons.person_outline)),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter owner name' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedService,
                decoration: const InputDecoration(labelText: '4. Clinic Service Type', prefixIcon: Icon(Icons.medical_services_outlined)),
                items: _serviceOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _selectedService = val!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(labelText: '5. Visit Status', prefixIcon: Icon(Icons.check_circle_outline)),
                items: _statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _selectedStatus = val!),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveRecord,
                  icon: const Icon(Icons.save),
                  label: Text(_isSaving ? 'Saving...' : (_isEditing ? 'Update Record' : 'Save Record')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}