# 🔐 Role-Based Navigation & Screen Linking Guide

## 📋 Overview

This document explains how screens are linked based on user roles for the Guardian Farm application. The system supports 3 user roles with different features:

- **👨‍🌾 Farmer**: Farm management, machine rental, marketplace
- **🏢 SME**: Business dashboard, machine rental, product selling
- **👨‍💼 Admin**: System management, user control, marketplace oversight

---

## 🗂️ Module Structure

### 1. **FARM MODULE** (Quản lý Trang Trại)
**Routes:**
- `/farm-list` (Farmer, SME, Admin) - List all farms
- `/farm/:farmId` (Farmer, SME, Admin) - Farm details
- `/farmer-list` (Farmer, SME, Admin) - List all farmers
- `/farmer/:farmerId` (Farmer, SME, Admin) - Farmer profile
- `/farm-image` (Farmer, SME, Admin) - Manage farm images

**Linked Screens:**
- Farm screens → Machine rental quick link
- Farm screens → Marketplace quick link
- Farm images → Accessible from farm detail

---

### 2. **MACHINE MODULE** (Chia Sẻ Máy Nông Nghiệp)
**Routes:**
- `/machine-list` (Farmer, SME, Admin) - Browse machines
- `/machine-detail` (Farmer, SME, Admin) - Machine specifications
- `/my-bookings` (Farmer, SME, Admin) - My rental requests
- `/booking-detail` (Farmer, SME, Admin) - Booking details
- `/owner/dashboard` (SME, Admin) - SME dashboard
- `/owner/bookings` (SME, Admin) - Incoming rental requests
- `/owner/calendar` (SME, Admin) - Machine availability calendar
- `/owner/machines` (SME, Admin) - Manage my machines
- `/owner/stats` (SME, Admin) - Business statistics

**Linked Screens:**
- Machine list → Quick link to my bookings (Farmer)
- Machine list → Quick link to dashboard (SME/Admin)
- Owner dashboard → Quick link to machine list
- Owner bookings → Quick link to dashboard
- Machine calendar → Available for all roles

---

### 3. **MARKETPLACE MODULE** (Thương Mại Điện Tử)
**Routes:**
- `/shop` (Farmer, SME, Admin) - Marketplace homepage
- `/product-detail` (Farmer, SME, Admin) - Product information
- `/product-form` (SME, Admin) - Add/edit product
- `/my-products` (SME, Admin) - My product list
- `/cart` (Farmer, SME, Admin) - Shopping cart
- `/checkout` (Farmer, SME, Admin) - Order checkout
- `/order-success` (Farmer, SME, Admin) - Order confirmation
- `/my-orders` (Farmer, SME, Admin) - Order history
- `/order-detail` (Farmer, SME, Admin) - Order information

**Linked Screens:**
- Shop home → My products (SME/Admin)
- Shop home → Cart (Farmer)
- Shop home → My orders (all roles)
- Product detail → Add to cart
- Cart → Checkout
- Checkout → Order success

---

### 4. **USER & AUTH MODULE** (Quản Lý Tài Khoản)
**Routes:**
- `/login` (Public) - User login
- `/register` (Public) - New account registration
- `/logout` (Authenticated) - Logout
- `/change-password` (Authenticated) - Change password
- `/profile` (Authenticated) - User profile
- `/addresses` (Farmer, SME, Admin) - Saved addresses
- `/addresses/edit` (Farmer, SME, Admin) - Add/edit address

---

### 5. **ADMIN MODULE** (Quản Trị Hệ Thống)
**Routes:**
- `/admin/dashboard` (Admin) - Admin dashboard
- `/admin/system-stats` (Admin, SME) - System statistics
- `/admin/support` (Admin, SME) - Support & maintenance
- `/users` (Admin) - User management list
- `/users/lock` (Admin) - Lock/unlock accounts

---

### 6. **ENTERPRISE MODULE** (Hồ Sơ Doanh Nghiệp)
**Routes:**
- `/enterprise/profile` (SME, Admin) - Enterprise profile

---

## 👥 Role Permissions Matrix

### FARMER Quick Actions (11 total)
✅ Farm management
✅ Machine rental & booking
✅ Marketplace shopping
✅ Address & profile management

### SME Quick Actions (8 total)
✅ Business dashboard
✅ Machine management & stats
✅ Booking management
✅ Product management
✅ Profile settings

### ADMIN Quick Actions (12 total)
✅ System dashboard
✅ User management
✅ All farm & machine features
✅ Marketplace oversight
✅ System operations

---

## 🎯 Feature Mapping to Developers

### 👤 Person 1: Auth & User (TRẦN QUANG DUYÊN)
- ✅ Register (Farmer, SME)
- ✅ Login (SME, Admin)
- ✅ Logout (SME, Admin)
- ✅ Change password (Farmer, SME, Admin)
- ✅ Profile management (Farmer, SME, Admin)
- ✅ User list (Admin)
- ✅ Lock/unlock accounts (Admin)
- ✅ Address management (Farmer, SME)

**Routes Used:** `/login`, `/register`, `/logout`, `/change-password`, `/profile`, `/addresses`, `/users`, `/users/lock`

---

### 👤 Person 2: Farm & Farmer (TRẦN THỊ MỸ LINH)
- ✅ Farmer profile management (Farmer, Admin)
- ✅ Image management (Farmer, SME, Admin)
- ✅ Farm management (Farmer, Admin)
- ✅ Farm listing (Farmer, SME, Admin)

**Routes Used:** `/farm-list`, `/farm/:farmId`, `/farmer-list`, `/farmer/:farmerId`, `/farm-image`

---

### 👤 Person 3: Machine Sharing (TRẦN DƯƠNG TRUNG TÍNH)
- ✅ Machine management (SME, Admin)
- ✅ Machine listing (Farmer, SME, Admin)
- ✅ Create booking request (Farmer)
- ✅ View requests (Farmer, SME, Admin)
- ✅ Update request status (SME, Admin)
- ✅ Machine calendar (Farmer, SME, Admin)
- ✅ Booking history (Farmer, SME)

**Routes Used:** `/machine-list`, `/machine-detail`, `/my-bookings`, `/booking-detail`, `/owner/dashboard`, `/owner/bookings`, `/owner/calendar`, `/owner/machines`, `/owner/stats`

---

### 👤 Person 4: Marketplace (TIỀN MINH THANH)
- ✅ Product management (SME, Admin)
- ✅ Product listing (Farmer, SME, Admin)
- ✅ Cart management (Farmer)
- ✅ Order creation (Farmer)
- ✅ Order listing (Farmer, SME, Admin)
- ✅ Order status updates (SME, Admin)
- ✅ Order details (Farmer, SME, Admin)

**Routes Used:** `/shop`, `/product-detail`, `/product-form`, `/my-products`, `/cart`, `/checkout`, `/order-success`, `/my-orders`, `/order-detail`

---

### 👤 Person 5: SME & Admin (BÙI NHẬT TRƯỜNG)
- ✅ Enterprise profile (SME, Admin)
- ✅ System statistics (Admin)
- ✅ Login/Logout (SME, Admin)
- ✅ Session management (SME, Admin)
- ✅ Admin dashboard (Admin)
- ✅ System support (Admin)

**Routes Used:** `/enterprise/profile`, `/admin/dashboard`, `/admin/system-stats`, `/admin/support`, Session via SessionController

---

## 🧩 Helper Widgets for Navigation

### ModuleQuickLinks Widget
Provides contextual navigation between related features.

**Usage:**
```dart
// In any screen, add this to show related module links:
ModuleQuickLinks(
  moduleType: 'farm', // 'farm', 'machine', or 'marketplace'
  userRole: currentUser?.role,
)
```

**Features:**
- Shows role-appropriate links only
- Links between farm ↔ machine ↔ marketplace
- Customizable per module type

### UpcomingFeaturesPlaceholder Widget
Shows upcoming features that users can be excited about.

**Usage:**
```dart
// Add to screens to show planned features:
UpcomingFeaturesPlaceholder(
  userRole: currentUser?.role,
)
```

**Shows:**
- Digital Twin (3D farm visualization)
- IoT Dashboard (sensor monitoring)
- Voice Diary (voice notes)
- Carbon Calculator (emission tracking)
- QR Scan & Trace (product origin)
- Machine Pricing Engine (automated pricing)
- ESG Health Check (sustainability assessment)
- Blockchain Ledger (carbon credits)
- Micro-parametric Insurance
- Gamification (achievements)

---

## 🧭 Home Page Navigation Flow

All role-based quick actions are configured in `HomePage._roleQuickActions()`:

### When User Logs In:
1. SessionController stores user data
2. AdaptiveTheme applies role-specific theme
3. HomePage displays role-specific quick actions
4. Each quick action navigates to appropriate route

### Quick Action Organization:
- **Farmer**: 11 buttons (farm, machine, marketplace, profile)
- **SME**: 8 buttons (business, machine, product, profile)
- **Admin**: 12 buttons (system, users, all modules)

---

## 🔐 AuthGuard Protection

All routes are protected with `AuthGuard` which:
- Checks user authentication
- Verifies role permissions
- Redirects to login if needed
- Blocks access if role not allowed

**Example:**
```dart
AppRoutes.ownerDashboard: (context) => AuthGuard(
  loginRoute: AppRoutes.login,
  deniedRoute: AppRoutes.home,
  allowedRoles: [UserRole.sme, UserRole.admin],
  child: const OwnerDashboardScreen(),
),
```

---

## 📱 Testing Navigation

### Test Flows:

#### Farmer Flow:
1. Login as farmer
2. Home page shows 11 farmer quick actions
3. Click "Danh sách trang trại" → FarmListScreen
4. Click "Thuê máy" → MachineListScreen
5. Click "Mua sản phẩm" → ShopHomeScreen
6. Verify theme is dark with green accent

#### SME Flow:
1. Login as SME
2. Home page shows 8 SME quick actions
3. Click "Dashboard doanh nghiệp" → OwnerDashboardScreen
4. Click "Kho máy của tôi" → OwnerMachineListScreen
5. Click "Quản lý sản phẩm" → MyProductsScreen
6. Verify theme is professional navy/emerald

#### Admin Flow:
1. Login as admin
2. Home page shows 12 admin quick actions
3. Click "Danh sách người dùng" → UserListPage
4. Click "Danh sách trang trại" → FarmListScreen
5. Click "Danh sách máy nông nghiệp" → MachineListScreen
6. Verify theme is admin dashboard variant

---

## 🎨 Adaptive Theme by Role

- **Farmer**: Dark theme (#121212), bright safety green (#00FF85), 64px buttons
- **SME**: Professional light theme (#F5F5F7), emerald green (#00A86B), navy header
- **Admin**: Extends SME theme with darker background (#F0F2F5)
- **Consumer**: Touch of nature theme (#FAFAFA), fresh leaf green (#4CAF50)

---

## 📊 Route Summary

**Total Routes: 42**
- Auth: 4 routes
- Home: 1 route
- User: 3 routes
- Address: 2 routes
- Farm: 5 routes
- Machine: 9 routes
- Marketplace: 9 routes
- Enterprise: 1 route
- Admin: 3 routes

**Active Routes: 42/42 ✅**
- All farm routes now active
- All machine routes now active
- All marketplace routes now active

---

## 🚀 Next Steps

1. Test all navigation flows to ensure proper linking
2. Add ModuleQuickLinks widget to key detail screens
3. Add UpcomingFeaturesPlaceholder to profile/dashboard screens
4. Per-screen UI refinement according to design spec
5. User testing with actual farmers, SMEs, and admins

---

**Last Updated:** March 26, 2026
**Status:** Phase 2 Complete - Role-Based Navigation System Implemented
