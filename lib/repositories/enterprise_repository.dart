import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/models/enterprise_profile.dart';

// Repository contract for enterprise profile management.
abstract class EnterpriseRepository {
  Future<List<EnterpriseProfile>> fetchEnterpriseProfiles();

  Future<EnterpriseProfile> loadEnterpriseProfile({int? userId});

  Future<void> saveEnterpriseProfile(EnterpriseProfile profile);
}

class SessionEnterpriseRepository implements EnterpriseRepository {
  SessionEnterpriseRepository({SessionController? controller})
	  : _controller = controller ?? SessionController.instance;

  final SessionController _controller;

  @override
  Future<List<EnterpriseProfile>> fetchEnterpriseProfiles() =>
	  _controller.fetchEnterpriseProfiles();

  @override
  Future<EnterpriseProfile> loadEnterpriseProfile({int? userId}) =>
	  _controller.loadEnterpriseProfile(userId: userId);

  @override
  Future<void> saveEnterpriseProfile(EnterpriseProfile profile) =>
	  _controller.saveEnterpriseProfile(profile);
}
