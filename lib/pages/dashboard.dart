import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pets.dart';
import 'settings.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;

  // Dito pinag-uugnay ang tatlong pangunahing tab sa ibaba (Dashboard, Pets, Settings)
  final List<Widget> _pages = [
    const _HomeOverviewTab(),
    const PetsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      // Modern Floating Rounded Navigation Bar (Pill Box Style)
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.teal.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            indicatorColor: Colors.teal.shade100,
            elevation: 0,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard, color: Color(0xFF00796B)),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.pets_outlined),
                selectedIcon: Icon(Icons.pets, color: Color(0xFF00796B)),
                label: 'Pets',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings, color: Color(0xFF00796B)),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// Home Overview Tab (Dashboard Content & Live Stats)
// ---------------------------------------------------------
class _HomeOverviewTab extends StatelessWidget {
  const _HomeOverviewTab();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final petsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('pets');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PawCare Clinic Log',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00796B),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.teal.shade100,
                  child: const Icon(Icons.pets, color: Color(0xFF00796B), size: 28),
                ),
                title: const Text(
                  'Welcome back!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(user?.email ?? 'Veterinary Staff'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Live Clinic Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: petsCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                final totalPets = docs.length;
                final pendingCount = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['status'] == 'Pending';
                }).length;

                return Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Registered Pets',
                        count: totalPets.toString(),
                        icon: Icons.pets,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Pending Visits',
                        count: pendingCount.toString(),
                        icon: Icons.pending_actions,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 12),
          Text(
            count,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}