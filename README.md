# Guardian - Farm Management Application

A comprehensive Flutter mobile application designed for managing agricultural operations including farms, machinery, products, and orders. Guardian provides a complete solution for farmers and agricultural businesses to streamline operations through an intuitive mobile interface with offline-first capabilities.

## 📱 Overview

Guardian is a cross-platform mobile application built with Flutter that helps agricultural businesses manage:
- **Farms**: Track and manage multiple farm properties and their details
- **Machinery**: Maintain an inventory of agricultural equipment and machines
- **Products**: Catalog and track agricultural products
- **Orders**: Manage customer orders and sales

The application features a local SQLite database for offline functionality, user authentication, and role-based access control.

## ✨ Features

### Core Features
- 🔐 **User Authentication**: Secure login system with role-based access control
- 🗄️ **Local Database**: SQLite database for offline data access
- 👥 **User Management**: User profiles with role-based permissions
- 🏠 **Farm Management**: Create, update, and manage farm information
- 🚜 **Machine/Equipment Tracking**: Inventory management for agricultural equipment
- 📦 **Product Management**: Track agricultural products and inventory
- 📋 **Order Management**: Process and manage customer orders
- ⚡ **Offline-First**: Full functionality without internet connection

### Technical Features
- Clean Architecture (Data, Domain, Presentation layers)
- Responsive Design for multiple screen sizes
- Material Design UI
- Cross-Platform Support (Android, iOS, Web, Windows, macOS, Linux)

## 🏗️ Architecture

The project follows **Clean Architecture** pattern with separation of concerns:

```
lib
│
├── main.dart                     # Entry point của ứng dụng Flutter (chạy runApp)
│
├── app.dart                      # Cấu hình app tổng thể: MaterialApp, Theme, Route
│
├── core                          # Các thành phần dùng CHUNG cho toàn bộ ứng dụng
│   │
│   ├── constants                 # Các giá trị cố định (tránh hardcode)
│   │   ├── app_colors.dart       # Định nghĩa màu sắc chung của app
│   │   ├── app_strings.dart      # Text cố định của hệ thống (Login, Logout, Error...)
│   │   └── api_constants.dart    # URL API, endpoint, timeout...
│   │
│   ├── database                  # Quản lý Local Database (SQLite)
│   │   ├── database_helper.dart  # Class mở database, query, insert, update, delete
│   │   ├── tables.dart           # Định nghĩa tên bảng và cột database
│   │   └── migrations.dart       # Quản lý version database khi nâng cấp schema
│   │
│   ├── network                   # Phần giao tiếp với server
│   │   └── api_client.dart       # HTTP client để gọi REST API (GET, POST, PUT...)
│   │
│   ├── utils                     # Các hàm tiện ích dùng lại nhiều nơi
│   │   ├── validator.dart        # Validate dữ liệu (email, password, phone...)
│   │   ├── date_utils.dart       # Format ngày tháng
│   │   └── formatter.dart        # Format tiền, số, text...
│   │
│   └── widgets                   # Widget dùng chung cho toàn app
│       ├── custom_button.dart    # Button thiết kế riêng của hệ thống
│       ├── custom_textfield.dart # TextField chuẩn của app
│       └── loading_widget.dart   # Widget loading spinner
│
├── features                      # Các MODULE chức năng chính của hệ thống
│
│   ├── auth                      # Module xác thực người dùng (login/register)
│   │   │
│   │   ├── data                  # Layer truy cập dữ liệu
│   │   │   ├── models            # Model mapping JSON/API
│   │   │   │   └── user_model.dart
│   │   │   │
│   │   │   ├── datasource        # Nơi lấy dữ liệu
│   │   │   │   ├── auth_local_datasource.dart   # Lấy dữ liệu từ local (SQLite/Cache)
│   │   │   │   └── auth_remote_datasource.dart  # Lấy dữ liệu từ API server
│   │   │   │
│   │   │   └── repositories
│   │   │       └── auth_repository_impl.dart   # Implementation repository
│   │   │
│   │   ├── domain                # Business logic (logic hệ thống)
│   │   │   ├── entities          # Đối tượng nghiệp vụ
│   │   │   │   └── user.dart
│   │   │   │
│   │   │   ├── repositories      # Interface repository
│   │   │   │   └── auth_repository.dart
│   │   │   │
│   │   │   └── usecases          # Các hành động hệ thống
│   │   │       ├── login.dart
│   │   │       ├── register.dart
│   │   │       └── logout.dart
│   │   │
│   │   └── presentation          # UI Layer
│   │       ├── pages             # Các màn hình
│   │       │   ├── login_page.dart
│   │       │   └── register_page.dart
│   │       │
│   │       ├── widgets           # Widget riêng của module auth
│   │       │   └── auth_form.dart
│   │       │
│   │       └── bloc              # Quản lý state (BLoC pattern)
│   │           └── auth_bloc.dart
│
│   ├── farm                      # Module quản lý nông trại
│   │   │
│   │   ├── data                  # Lấy dữ liệu farm
│   │   │   ├── models
│   │   │   │   └── farm_model.dart
│   │   │   │
│   │   │   ├── datasource
│   │   │   │   └── farm_local_datasource.dart
│   │   │   │
│   │   │   └── repositories
│   │   │       └── farm_repository_impl.dart
│   │   │
│   │   ├── domain                # Logic nghiệp vụ farm
│   │   │   ├── entities
│   │   │   │   └── farm.dart
│   │   │   │
│   │   │   └── usecases
│   │   │       ├── create_farm.dart
│   │   │       └── get_farms.dart
│   │   │
│   │   └── presentation          # UI của farm
│   │       ├── pages
│   │       │   ├── farm_list_page.dart
│   │       │   └── farm_detail_page.dart
│   │       │
│   │       └── bloc
│   │           └── farm_bloc.dart
│
│   ├── machine                   # Module máy nông nghiệp
│   │   ├── data
│   │   ├── domain
│   │   └── presentation
│
│   ├── product                   # Module sản phẩm nông nghiệp
│   │   ├── data
│   │   ├── domain
│   │   └── presentation
│
│   ├── order                     # Module đơn hàng
│   │   ├── data
│   │   ├── domain
│   │   └── presentation
│
│   └── profile                   # Module hồ sơ người dùng
│       ├── data
│       ├── domain
│       └── presentation
│ └── error # Module hiển thị lỗi hệ thống
│ 	│
│ 	└── presentation
│	 │
│	 ├── pages
│		 │ ├── error_404_page.dart # Không tìm thấy trang
│ 		 │ ├── error_500_page.dart # Lỗi server
│		 │ ├── no_internet_page.dart # Không có kết nối mạng
│		 │ └── maintenance_page.dart # Hệ thống bảo trì
│ 		 │
│		 └── widgets
│			 └── error_view.dart # Widget UI chung cho trang lỗi
│
│
└── routes
    └── app_routes.dart           # Định nghĩa route navigation toàn app



```

Each feature follows this structure:
- **data/**: Data sources, repositories, models
- **domain/**: Entities, use cases, repository interfaces
- **presentation/**: UI widgets, pages, state management

## 📊 Database Schema

The application uses SQLite with the following main tables:
- **Users**: User accounts with authentication and role information
- **Farms**: Farm properties and information
- **Machines**: Agricultural equipment and machinery
- **Products**: Agricultural products catalog
- **Orders**: Customer orders and transactions

## 🔧 Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>= 3.10.0, < 4.0.0)
- [Dart SDK](https://dart.dev/get-dart) (>= 3.10.0)
- A code editor (VS Code, Android Studio, or IntelliJ)
- Android Studio or Xcode for mobile development
- Git for version control

## 📦 Dependencies

Main dependencies:
- `sqflite`: SQLite database for Flutter
- `path`: File path utilities
- `cupertino_icons`: iOS-style icons
- `flutter_lints`: Linting rules

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/guardian.git
cd guardian
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the Application

**For Android:**
```bash
flutter run -d android
```

**For iOS:**
```bash
flutter run -d ios
```

**For Web:**
```bash
flutter run -d web
```

**For Windows:**
```bash
flutter run -d windows
```

**For macOS:**
```bash
flutter run -d macos
```

**For Linux:**
```bash
flutter run -d linux
```

### 4. Run Tests

```bash
flutter test
```

## 🔄 Hot Reload & Hot Restart

During development, use hot reload to see changes instantly:

- **Hot Reload** (r): Applies code changes while preserving app state
- **Hot Restart** (R): Restarts the app completely

## 📁 Project Structure Details

### Core Module
- **database/**: Manages SQLite database initialization, schema, and operations
- **constants/**: Application-wide constants and configurations
- **utils/**: Helper functions and utilities
- **widgets/**: Reusable UI components
- **network/**: Network communication utilities

### Feature Modules

#### Auth Feature
Authentication and user management
- User login/signup
- Session management
- Password handling

#### Farm Feature
Farm property management
- Add/edit/delete farms
- View farm details
- Track farm information

#### Machine Feature
Equipment and machinery inventory
- Machinery inventory management
- Equipment tracking
- Maintenance records

#### Product Feature
Product catalog management
- Product listing
- Inventory tracking
- Product details

#### Order Feature
Order and sales management
- Create orders
- Order status tracking
- Order history

#### Profile Feature
User profile and settings
- User information
- Profile settings
- Preferences

## 🛠️ Development

### Code Guidelines
- Follow Dart style guide
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### Running Dev Server
```bash
flutter pub get
flutter run --verbose
```

### Building for Release

**Android:**
```bash
flutter build apk
```

**iOS:**
```bash
flutter build ios
```

**Web:**
```bash
flutter build web
```

## 📝 Configuration

The application uses configuration files in the project root:
- `pubspec.yaml`: Package configuration and dependencies
- `analysis_options.yaml`: Linting rules and static analysis options

## 🐛 Troubleshooting

### Flutter Doctor Check
Verify your development environment:
```bash
flutter doctor
```

### Clear Cache
If you encounter issues:
```bash
flutter clean
flutter pub get
flutter run
```

### Common Issues

**Issue**: App won't start on Android
- **Solution**: Run `flutter clean` and rebuild, or check Android SDK version

**Issue**: iOS build fails
- **Solution**: Run `pod repo update` and `flutter clean`

**Issue**: Database errors
- **Solution**: Ensure SQLite is properly configured in your build settings

## 📄 License

This project is part of the PRM393 (Project Resource Management) coursework.

## 👥 Contributors

- Development Team: PRM393 Project Group

## 📞 Support

For issues, questions, or suggestions, please create an issue in the repository or contact the development team.

## 🙏 Acknowledgments

- [Flutter Documentation](https://flutter.dev/)
- [SqlFlite Package](https://pub.dev/packages/sqflite)
- [Clean Architecture](https://resocoder.com/clean-architecture-tdd)

## 🔗 Additional Resources

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter Documentation](https://docs.flutter.dev/)
