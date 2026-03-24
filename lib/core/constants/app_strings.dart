// =============================================================
// app_strings.dart
// Toàn bộ text cố định của app PRM393
// Refactor: không lạm dụng static
// =============================================================

class AppStrings {
  final AppInfo app;
  final AuthStrings auth;
  final NavStrings nav;
  final OrderStrings orders;
  final RoleStrings roles;
  final ProductStrings products;
  final FarmStrings farm;
  final MachineStrings machines;
  final ProfileStrings profile;
  final NotificationStrings notifications;
  final ActionStrings actions;
  final ValidationStrings validation;
  final ErrorStrings errors;
  final SuccessStrings success;
  final EmptyStrings empty;
  final DialogStrings dialog;

  const AppStrings({
    this.app = const AppInfo(),
    this.auth = const AuthStrings(),
    this.nav = const NavStrings(),
    this.orders = const OrderStrings(),
    this.roles = const RoleStrings(),
    this.products = const ProductStrings(),
    this.farm = const FarmStrings(),
    this.machines = const MachineStrings(),
    this.profile = const ProfileStrings(),
    this.notifications = const NotificationStrings(),
    this.actions = const ActionStrings(),
    this.validation = const ValidationStrings(),
    this.errors = const ErrorStrings(),
    this.success = const SuccessStrings(),
    this.empty = const EmptyStrings(),
    this.dialog = const DialogStrings(),
  });
}

///////////////////////////////////////////////////////////////
/// APP
///////////////////////////////////////////////////////////////

class AppInfo {
  final String name;
  final String tagline;
  final String version;

  const AppInfo({
    this.name = 'AgriConnect',
    this.tagline = 'Kết nối nông nghiệp thông minh',
    this.version = 'Phiên bản',
  });
}

///////////////////////////////////////////////////////////////
/// AUTH
///////////////////////////////////////////////////////////////

class AuthStrings {
  final String login;
  final String logout;
  final String register;
  final String phoneNumber;
  final String password;
  final String confirmPassword;
  final String forgotPassword;

  const AuthStrings({
    this.login = 'Đăng nhập',
    this.logout = 'Đăng xuất',
    this.register = 'Đăng ký',
    this.phoneNumber = 'Số điện thoại',
    this.password = 'Mật khẩu',
    this.confirmPassword = 'Xác nhận mật khẩu',
    this.forgotPassword = 'Quên mật khẩu?',
  });
}

///////////////////////////////////////////////////////////////
/// NAVIGATION
///////////////////////////////////////////////////////////////

class NavStrings {
  final String home;
  final String orders;
  final String schedule;
  final String profile;
  final String farm;
  final String market;
  final String iot;
  final String notification;

  const NavStrings({
    this.home = 'Trang chủ',
    this.orders = 'Đơn hàng',
    this.schedule = 'Lịch trình',
    this.profile = 'Cá nhân',
    this.farm = 'Nông trại',
    this.market = 'Chợ',
    this.iot = 'Cảm biến',
    this.notification = 'Thông báo',
  });
}

///////////////////////////////////////////////////////////////
/// ORDERS
///////////////////////////////////////////////////////////////

class OrderStrings {
  final String tabAll;
  final String tabPending;
  final String tabInProgress;
  final String tabCompleted;
  final String tabCancelled;

  const OrderStrings({
    this.tabAll = 'Tất cả',
    this.tabPending = 'Chờ điều động',
    this.tabInProgress = 'Đang thực hiện',
    this.tabCompleted = 'Hoàn thành',
    this.tabCancelled = 'Đã hủy',
  });

  String statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'CREATED':
        return 'Mới tạo';
      case 'BOOKED':
        return 'Đang chờ điều động';
      case 'IN_PROGRESS':
        return 'Đang thực hiện';
      case 'PAID':
        return 'Đã thanh toán';
      case 'SHIPPING':
        return 'Đang giao hàng';
      case 'COMPLETED':
        return 'Hoàn thành';
      case 'CANCELLED':
        return 'Đã hủy';
      case 'MATCHING':
        return 'Đang khớp lệnh';
      default:
        return status;
    }
  }
}

///////////////////////////////////////////////////////////////
/// ROLES
///////////////////////////////////////////////////////////////

class RoleStrings {
  final String farmer;
  final String sme;
  final String admin;

  const RoleStrings({
    this.farmer = 'Nông dân',
    this.sme = 'Doanh nghiệp',
    this.admin = 'Quản trị viên',
  });

  String label(String role) {
    switch (role.toUpperCase()) {
      case 'FARMER':
        return farmer;
      case 'SME':
        return sme;
      case 'ADMIN':
        return admin;
      default:
        return role;
    }
  }
}

///////////////////////////////////////////////////////////////
/// PRODUCTS
///////////////////////////////////////////////////////////////

class ProductStrings {
  final String products;
  final String addToCart;
  final String cart;
  final String checkout;
  final String quantity;
  final String price;

  const ProductStrings({
    this.products = 'Sản phẩm',
    this.addToCart = 'Thêm vào giỏ',
    this.cart = 'Giỏ hàng',
    this.checkout = 'Đặt hàng',
    this.quantity = 'Số lượng',
    this.price = 'Giá',
  });
}

///////////////////////////////////////////////////////////////
/// FARM
///////////////////////////////////////////////////////////////

class FarmStrings {
  final String farm;
  final String farms;
  final String addFarm;
  final String cropType;
  final String location;

  const FarmStrings({
    this.farm = 'Nông trại',
    this.farms = 'Danh sách nông trại',
    this.addFarm = 'Thêm nông trại',
    this.cropType = 'Loại cây trồng',
    this.location = 'Vị trí',
  });

  String deviceType(String type) {
    switch (type.toUpperCase()) {
      case 'SOIL':
        return 'Cảm biến đất';
      case 'AIR':
        return 'Cảm biến không khí';
      case 'WATER':
        return 'Cảm biến nước';
      case 'GATEWAY':
        return 'Trạm trung tâm';
      default:
        return type;
    }
  }
}

///////////////////////////////////////////////////////////////
/// MACHINES
///////////////////////////////////////////////////////////////

class MachineStrings {
  final String machines;
  final String bookMachine;
  final String pricePerHour;
  final String startTime;
  final String endTime;

  const MachineStrings({
    this.machines = 'Máy nông nghiệp',
    this.bookMachine = 'Đặt thuê máy',
    this.pricePerHour = 'Giá / giờ',
    this.startTime = 'Bắt đầu',
    this.endTime = 'Kết thúc',
  });
}

///////////////////////////////////////////////////////////////
/// PROFILE
///////////////////////////////////////////////////////////////

class ProfileStrings {
  final String profile;
  final String editProfile;
  final String fullName;
  final String email;
  final String phone;
  final String address;

  const ProfileStrings({
    this.profile = 'Hồ sơ',
    this.editProfile = 'Chỉnh sửa hồ sơ',
    this.fullName = 'Họ và tên',
    this.email = 'Email',
    this.phone = 'Số điện thoại',
    this.address = 'Địa chỉ',
  });
}

///////////////////////////////////////////////////////////////
/// NOTIFICATION
///////////////////////////////////////////////////////////////

class NotificationStrings {
  final String notifications;
  final String markAllRead;
  final String noNotifications;

  const NotificationStrings({
    this.notifications = 'Thông báo',
    this.markAllRead = 'Đánh dấu tất cả đã đọc',
    this.noNotifications = 'Không có thông báo mới',
  });
}

///////////////////////////////////////////////////////////////
/// ACTIONS
///////////////////////////////////////////////////////////////

class ActionStrings {
  final String confirm;
  final String cancel;
  final String save;
  final String delete;
  final String add;
  final String search;

  const ActionStrings({
    this.confirm = 'Xác nhận',
    this.cancel = 'Hủy',
    this.save = 'Lưu',
    this.delete = 'Xóa',
    this.add = 'Thêm',
    this.search = 'Tìm kiếm',
  });
}

///////////////////////////////////////////////////////////////
/// VALIDATION
///////////////////////////////////////////////////////////////

class ValidationStrings {
  final String required;
  final String phoneInvalid;
  final String emailInvalid;

  const ValidationStrings({
    this.required = 'Trường này không được để trống',
    this.phoneInvalid = 'Số điện thoại không hợp lệ',
    this.emailInvalid = 'Email không đúng định dạng',
  });
}

///////////////////////////////////////////////////////////////
/// ERRORS
///////////////////////////////////////////////////////////////

class ErrorStrings {
  final String general;
  final String network;
  final String timeout;
  final String unauthorized;

  const ErrorStrings({
    this.general = 'Có lỗi xảy ra, vui lòng thử lại',
    this.network = 'Không có kết nối mạng',
    this.timeout = 'Kết nối hết thời gian',
    this.unauthorized = 'Phiên đăng nhập hết hạn',
  });
}

///////////////////////////////////////////////////////////////
/// SUCCESS
///////////////////////////////////////////////////////////////

class SuccessStrings {
  final String saved;
  final String deleted;
  final String orderPlaced;

  const SuccessStrings({
    this.saved = 'Lưu thành công',
    this.deleted = 'Xóa thành công',
    this.orderPlaced = 'Đặt hàng thành công',
  });
}

///////////////////////////////////////////////////////////////
/// EMPTY
///////////////////////////////////////////////////////////////

class EmptyStrings {
  final String defaultEmpty;
  final String search;
  final String cart;

  const EmptyStrings({
    this.defaultEmpty = 'Không có dữ liệu',
    this.search = 'Không tìm thấy kết quả',
    this.cart = 'Giỏ hàng đang trống',
  });
}

///////////////////////////////////////////////////////////////
/// DIALOG
///////////////////////////////////////////////////////////////

class DialogStrings {
  final String confirmTitle;
  final String deleteTitle;
  final String deleteMessage;

  const DialogStrings({
    this.confirmTitle = 'Xác nhận',
    this.deleteTitle = 'Xóa dữ liệu',
    this.deleteMessage =
        'Bạn có chắc muốn xóa? Thao tác này không thể hoàn tác.',
  });
}
