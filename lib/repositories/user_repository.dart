import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/models/user.dart';

// Repository contract for user management.
abstract class UserRepository {
	Future<List<AppUser>> fetchUsers();

	Future<bool> toggleUserLock(int userId);
}

class SessionUserRepository implements UserRepository {
	SessionUserRepository({SessionController? controller})
			: _controller = controller ?? SessionController.instance;

	final SessionController _controller;

	@override
	Future<List<AppUser>> fetchUsers() => _controller.fetchUsers();

	@override
	Future<bool> toggleUserLock(int userId) => _controller.toggleUserLock(userId);
}
