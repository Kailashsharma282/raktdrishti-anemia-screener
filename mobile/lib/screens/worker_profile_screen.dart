import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class WorkerProfileScreen extends StatelessWidget {
  const WorkerProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = AuthService(api: ApiService());
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppConstants.colorPrimary,
                    child: Text(
                      user?.fullName.isNotEmpty == true ? user!.fullName[0] : 'A',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? 'Anita Devi',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${user?.role.replaceAll("_", " ").toUpperCase()} • ${user?.workerCode}',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProfileRow(Icons.location_city, 'Assigned Block', 'Varanasi Block A'),
                    const Divider(),
                    _buildProfileRow(Icons.villa_outlined, 'Primary Village', user?.village ?? 'Demo Village'),
                    const Divider(),
                    _buildProfileRow(Icons.phone_outlined, 'Registered Mobile', '+91-9876501234'),
                    const Divider(),
                    _buildProfileRow(Icons.security, 'Authentication Mode', 'Offline Pin / JWT'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              icon: const Icon(Icons.logout),
              label: const Text('Log Out of Device'),
              onPressed: () {
                auth.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
