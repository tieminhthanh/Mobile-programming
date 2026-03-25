import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/models/system_stat.dart';

// Repository contract for system statistics and admin support.
abstract class SystemRepository {
	Future<List<SystemStat>> systemStats();
}

class SessionSystemRepository implements SystemRepository {
	SessionSystemRepository({SessionController? controller})
			: _controller = controller ?? SessionController.instance;

	final SessionController _controller;

	@override
	Future<List<SystemStat>> systemStats() => _controller.systemStats();
}
