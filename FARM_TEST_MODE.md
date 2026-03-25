# Farm Features - TEST MODE Configuration

## 📋 Overview

The app has been temporarily configured to **test farm features** instead of marketplace features.

Initial route: **`/farm-test`** → FarmTestHomeScreen

---

## 🔄 Current Mode: FARM TESTING

| Aspect | Status |
|--------|--------|
| **Initial Screen** | FarmTestHomeScreen (Test Navigation Hub) |
| **App Title** | "Guardian - Farm Features (TEST MODE)" |
| **Feature Set** | Farmer & Farm Management |
| **Marketplace** | DISABLED (commented out) |

---

## 📍 Farm Routes Available

### Static Routes (no parameters):
```
/farm-test          → FarmTestHomeScreen (main navigation)
/farmers            → FarmerListScreen (danh sách nông dân)
/farms              → FarmListScreen (danh sách trang trại)
/farmer-detail      → FarmerDetailScreen (tạo file nông dân mới)
/farm-detail        → FarmDetailScreen (tạo trang trại mới)
```

### Dynamic Routes (with parameters):
```
/farmer-detail/edit → Edit existing Farmer (pass Farmer object)
/farm-detail/edit   → Edit existing Farm (pass Farm object)
/farm-detail/add    → Add Farm with Farmer ID (pass farmerId: String)
/farm-images        → Manage images (pass referenceId, referenceType, title)
```

---

## 🎯 Farm Features Being Tested

### 1. **Farmer Management**
- `FarmerListScreen` - Xem danh sách tất cả nông dân
- `FarmerDetailScreen` - Thêm/Sửa thông tin nông dân
- `FarmImageScreen` - Quản lý ảnh nông dân

### 2. **Farm Management**
- `FarmListScreen` - Xem danh sách tất cả trang trại
- `FarmDetailScreen` - Thêm/Sửa thông tin trang trại
- `FarmImageScreen` - Quản lý ảnh trang trại

### 3. **Navigation Hub**
- `FarmTestHomeScreen` - Test navigation dashboard với buttons để vào các features

---

## 🔙 How to Switch Back to Marketplace

When farm testing is complete, to switch back to **Marketplace features**:

### 1. In `app.dart`, uncomment marketplace imports:
```dart
// Change from:
// import 'package:guardian/screens/marketplace/shop_home_screen.dart';

// To:
import 'package:guardian/screens/marketplace/shop_home_screen.dart';
// ... (all other marketplace imports)
```

### 2. Change initialRoute back to marketplace:
```dart
// Change from:
initialRoute: '/farm-test',

// To:
initialRoute: '/',
```

### 3. Update routes map:
```dart
routes: {
  '/': (context) => const ShopHomeScreen(),
  // ... restore all marketplace routes
},
```

### 4. Update onGenerateRoute:
```dart
// Restore marketplace-related dynamic routes
```

---

## 🚀 How to Run

```bash
flutter run -d windows
```

This will start at `FarmTestHomeScreen` where you can navigate to various farm features.

---

## 🧪 Testing Checklist

- [ ] FarmTestHomeScreen loads correctly
- [ ] FarmerListScreen displays farmer list
- [ ] Can add new farmer via FarmerDetailScreen
- [ ] Can edit existing farmer
- [ ] Can add farmer images via FarmImageScreen
- [ ] FarmListScreen displays farm list
- [ ] Can add new farm via FarmDetailScreen
- [ ] Can edit existing farm
- [ ] Can add farm images via FarmImageScreen
- [ ] Navigation between screens works properly

---

## 📝 Database Tables Used

Farm features use these database tables:

1. **Farmers** - Farmer information
   - FarmerId, PhoneNumber, DisplayName, etc.

2. **Farms** - Farm/Plot information
   - FarmId, FarmerId (foreign key), Name, Area, etc.

3. **Images** - Image storage
   - ImageId, ReferenceId (FarmerId or FarmId)
   - ReferenceType ('Farmer' or 'Farm')

---

## ⚙️ Controller: FarmerController

The `FarmerController` (ChangeNotifier) manages:
- Farmer list state
- Farm list state
- Image management
- CRUD operations for farmers and farms

Injected via:
```dart
ChangeNotifierProvider<FarmerController>(
  create: (_) => farmerController,
)
```

---

## 💡 Quick Links

- **Main Screen**: `lib/screens/farm/farm_test_home_screen.dart`
- **Controller**: `lib/controllers/farmer_controller.dart`
- **Models**: 
  - `lib/models/farmer.dart`
  - `lib/models/farm.dart`
  - `lib/models/farmer_image.dart`
- **App Config**: `lib/app.dart`

---

## 📌 Important Notes

1. **Test Mode Status**: This is a **TEMPORARY** configuration for testing
2. **Not Production**: Remove notes when switching back to marketplace
3. **All Features**: Both marketplace and farm features are available in the codebase
4. **Easy Switch**: Simple comment/uncomment changes to switch between modes
5. **Database**: Same database is used for both marketplace and farm features

---

## ✅ Status

- ✅ Farm routes configured
- ✅ Dynamic routes set up for object parameters
- ✅ No compilation errors
- ✅ Ready for testing

Run `flutter run -d windows` to start testing farm features!
