import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/models/address.dart';

// Repository contract for address management.
abstract class AddressRepository {
	Future<List<Address>> addressesForUser(int userId);

	Future<void> saveAddress(Address address);

	Future<void> deleteAddress(int addressId);
}

class SessionAddressRepository implements AddressRepository {
	SessionAddressRepository({SessionController? controller})
			: _controller = controller ?? SessionController.instance;

	final SessionController _controller;

	@override
	Future<List<Address>> addressesForUser(int userId) =>
			_controller.addressesForUser(userId);

	@override
	Future<void> saveAddress(Address address) => _controller.saveAddress(address);

	@override
	Future<void> deleteAddress(int addressId) => _controller.deleteAddress(addressId);
}
