import '../database/db_helper.dart';
import 'api_service.dart';

class UserProfile {
  final String id;
  final String username;
  final String fullName;
  final String role; // 'health_worker', 'admin'
  final String workerCode;
  final String village;
  final String district;

  UserProfile({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.workerCode,
    required this.village,
    required this.district,
  });
}

class AuthService {
  final ApiService api;
  UserProfile? _currentUser;
  bool _isDemoMode = false;

  AuthService({required this.api}) {
    // Default logged-in ASHA worker profile for immediate demo readiness
    _currentUser = UserProfile(
      id: 'u-8d91f2c4-8390-4a8f-91bd-e1293a90ab12',
      username: 'asha_anita',
      fullName: 'Anita Devi',
      role: 'health_worker',
      workerCode: 'ASHA-UP-VNS-042',
      village: 'Demo Village',
      district: 'Varanasi',
    );
  }

  UserProfile? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isDemoMode => _isDemoMode;

  void toggleDemoMode(bool enabled) {
    _isDemoMode = enabled;
  }

  Future<bool> login(String username, String password) async {
    if (username == 'admin') {
      _currentUser = UserProfile(
        id: 'u-admin-0001',
        username: 'admin',
        fullName: 'Dr. R. K. Verma (District Medical Officer)',
        role: 'admin',
        workerCode: 'ADMIN-UP-VNS-001',
        village: 'District HQ',
        district: 'Varanasi',
      );
      return true;
    }

    // ASHA Health Worker default
    _currentUser = UserProfile(
      id: 'u-8d91f2c4-8390-4a8f-91bd-e1293a90ab12',
      username: username.isEmpty ? 'asha_anita' : username,
      fullName: 'Anita Devi',
      role: 'health_worker',
      workerCode: 'ASHA-UP-VNS-042',
      village: 'Demo Village',
      district: 'Varanasi',
    );

    // Try cloud authentication in parallel
    api.login(username, password);
    return true;
  }

  void logout() {
    _currentUser = null;
  }
}
