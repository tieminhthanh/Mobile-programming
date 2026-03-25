import 'package:flutter/foundation.dart';
import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/models/user.dart';

// Repository contract for authentication and session.
abstract class AuthRepository {
	ValueListenable<AppUser?> get currentUser;

	Future<void> init();

	Future<LoginResult> login(String username, String password);

	Future<void> logout();

	Future<RegisterResult> register({
		required String phoneNumber,
		required String password,
		String? email,
		String? displayName,
	});

	Future<ChangePasswordResult> changePassword({
		required String oldPassword,
		required String newPassword,
	});

	Future<UpdateProfileResult> updateProfile({
		required String displayName,
		required String email,
		required String phone,
	});
}

class SessionAuthRepository implements AuthRepository {
	SessionAuthRepository({SessionController? controller})
			: _controller = controller ?? SessionController.instance;

	final SessionController _controller;

	@override
	ValueListenable<AppUser?> get currentUser => _controller.currentUser;

	@override
	Future<void> init() => _controller.init();

	@override
	Future<LoginResult> login(String username, String password) =>
			_controller.login(username, password);

	@override
	Future<void> logout() => _controller.logout();

	@override
	Future<RegisterResult> register({
		required String phoneNumber,
		required String password,
		String? email,
		String? displayName,
	}) {
		return _controller.register(
			phoneNumber: phoneNumber,
			password: password,
			email: email,
			displayName: displayName,
		);
	}

	@override
	Future<ChangePasswordResult> changePassword({
		required String oldPassword,
		required String newPassword,
	}) {
		return _controller.changePassword(
			oldPassword: oldPassword,
			newPassword: newPassword,
		);
	}

	@override
	Future<UpdateProfileResult> updateProfile({
		required String displayName,
		required String email,
		required String phone,
	}) {
		return _controller.updateProfile(
			displayName: displayName,
			email: email,
			phone: phone,
		);
	}
}
