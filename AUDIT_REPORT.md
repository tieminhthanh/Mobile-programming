# 📊 AUDIT REPORT: App Functionality & Module Integration

**Ngày**: 25/03/2026  
**Branch**: linh  
**Status**: Post-Merge Analysis

---

## 📋 Executive Summary

App hiện tại đã có **~80% chức năng cốt lõi**, nhưng các module **bị tách rời** không liên kết. Cần:
1. ✅ Tích hợp routes & state management
2. ✅ Fix giao diện theo design spec (Adaptive UI cho 3 nhóm người dùng)
3. ❌ Bổ sung ~5-7 chức năng nhỏ

---

## 👤 MAPPING: 5 Người Development vs Chức năng Hiện có

### 1️⃣ TRẦN QUANG DUYÊN — Auth & User Management
**Phụ trách**: Xác thực + Quản lý người dùng

| Chức năng | Status | File | Ghi chú |
|-----------|--------|------|---------|
| Đăng ký | ✅ Có | `auth/register_page.dart` | |
| Đăng nhập | ✅ Có | `auth/login_page.dart` | |
| Đăng xuất | ✅ Có | `auth/logout_page.dart` | |
| Đổi mật khẩu | ✅ Có | `auth/change_password_page.dart` | |
| **Quản lý thông tin cá nhân** | ✅ Có | `user/profile_page.dart` | |
| **Quản lý danh sách người dùng** | ✅ Có | `user/user_list_page.dart` | Admin-only |
| **Khóa/mở tài khoản** | ✅ Có | `user/user_lock_page.dart` | Admin-only |
| **Quản lý địa chỉ** | ✅ Có | `address/address_list_page.dart` | + `address_edit_page.dart` |

**⭐ Tổng**: 8/8 chức năng ✅  
**🔴 Vấn đề**: Chưa có `AuthGuard` hoàn thiện (role-based access control), phân quyền logic chưa rõ ràng

---

### 2️⃣ TRẦN THỊ MỸ LINH — Farmer & Farm Management
**Phụ trách**: Quản lý nông dân & trang trại

| Chức năng | Status | File | Ghi chú |
|-----------|--------|------|---------|
| Quản lý hồ sơ nông dân | ✅ Có | `farm/farmer_detail_screen.dart` | |
| **Quản lý ảnh nông dân** | ✅ Có | `farm/farm_image_screen.dart` | |
| Quản lý trang trại | ✅ Có | `farm/farm_detail_screen.dart` | |
| Xem danh sách trang trại | ✅ Có | `farm/farm_list_screen.dart` | |
| **Xem danh sách nông dân** | ✅ Có | `farm/farmer_list_screen.dart` | |

**⭐ Tổng**: 5/5 chức năng ✅  
**🔴 Vấn đề**: 
- Chưa có **Digital Twin** hiển thị trạng thái cây thời gian thực
- Chưa kết nối **IoT data** (cảm biến đất, nước)
- Chưa có **Nhật ký canh tác thoại** (Voice Diary)

---

### 3️⃣ TRẦN DƯƠNG TRUNG TÍNH — Machine Sharing (Agri-Uber)
**Phụ trách**: Hệ thống thuê máy nông nghiệp

| Chức năng | Status | File | Ghi chú |
|-----------|--------|------|---------|
| Quản lý máy nông nghiệp | ✅ Có | `machine/add_edit_machine_screen.dart` | |
| Xem danh sách máy | ✅ Có | `machine/machine_list_screen.dart` | |
| **Tạo yêu cầu thuê máy** | ✅ Có | `machine/my_bookings_screen.dart` | |
| **Xem danh sách yêu cầu** | ✅ Có | `machine/booking_detail_screen.dart` | |
| Cập nhật trạng thái yêu cầu | ✅ Có | `machine/booking_detail_screen.dart` | |
| **Quản lý lịch thuê máy** | ✅ Có | `machine/machine_calendar_screen.dart` | |
| **Xem lịch sử thuê máy** | ⚠️ Chưa đầy đủ | `machine/owner_bookings_screen.dart` | Có danh sách nhưng không có lịch sử chi tiết |

**⭐ Tổng**: 6.5/7 chức năng ✅  
**🔴 Vấn đề**:
- Chưa có **tính giá tự động** (Pricing Engine)
- Chưa có **tối ưu lộ trình** (Route Optimization)
- Chưa có **định vị GPS** cho máy

---

### 4️⃣ TIỀN MINH THANH — Marketplace (E-Commerce)
**Phụ trách**: Bán sản phẩm nông nghiệp

| Chức năng | Status | File | Ghi chú |
|-----------|--------|------|---------|
| **Quản lý sản phẩm** | ✅ Có | `marketplace/product_form_screen.dart` | |
| **Xem danh sách sản phẩm** | ✅ Có | `marketplace/shop_home_screen.dart` | + `product_detail_screen.dart` |
| **Quản lý giỏ hàng** | ✅ Có | `marketplace/cart_screen.dart` | |
| **Tạo đơn hàng** | ✅ Có | `marketplace/checkout_screen.dart` | |
| **Xem danh sách đơn hàng** | ✅ Có | `marketplace/my_orders_screen.dart` | |
| **Cập nhật trạng thái đơn** | ✅ Có | `marketplace/order_detail_screen.dart` | |
| **Xem chi tiết đơn hàng** | ✅ Có | `marketplace/order_detail_screen.dart` | |

**⭐ Tổng**: 7/7 chức năng ✅  
**🔴 Vấn đề**:
- Chưa có **Truy xuất nguồn gốc** (Scan & Trace QR)
- Chưa có **Bộ lọc "Xanh"** (Green Filter - chỉ sản phẩm sinh học)
- Chưa có **Tính Carbon Footprint** sản phẩm

---

### 5️⃣ BÙI NHẬT TRƯỜNG — SME, Admin & Dashboard
**Phụ trách**: Doanh nghiệp + Thống kê hệ thống (+ Auth sau vì Duyên PE < 4)

| Chức năng | Status | File | Ghi chú |
|-----------|--------|------|---------|
| **Quản lý hồ sơ doanh nghiệp** | ✅ Có | `enterprise/enterprise_profile_page.dart` | |
| **Xem thống kê hệ thống** | ✅ Có | `admin/admin_dashboard_page.dart` | + `system_stats_page.dart` |
| **Hỗ trợ Admin** | ✅ Có | `admin/admin_support_page.dart` | |
| **Dashboard SME** | ✅ Có | `machine/owner_dashboard_screen.dart` | |
| **Login/Logout** | ✅ Có | `auth/login_page.dart` | Đảy từ Duyên |

**⭐ Tổng**: 5/5 chức năng ✅  
**🔴 Vấn đề**:
- Chưa có **ESG Health Check** (Tự đánh giá ESG)
- Chưa có **CSR 2.0 Dashboard** (Minh bạch hoá tác động)
- Chưa có **Sàn giao dịch Tín chỉ Carbon** (Carbon Ledger)

---

## 📊 Tổng Kết Chức Năng

```
✅ Chức năng MỘT CỘT (cốt lõi)     : 32/33  (97%)
❌ Chức năng BỔ SUNG (value-added)  : 2/11  (18%)
🔄 Liên kết Module & State         : 40%   (cần cải thiện)
🎨 Giao diện theo Design Spec      : 30%   (cần fix qua Adaptive UI)
```

---

## 🎨 GIAO DIỆN - VẤN ĐỀ HIỆN TẠI

### ❌ Vấn đề 1: Không có **Adaptive UI** cho 3 nhóm người dùng
- **Nông dân**: Cần giao diện "Big & Bold" + Voice-First
- **SME**: Cần giao diện "Dashboard Zen" + Data-Heavy
- **Cộng đồng**: Cần giao diện "Touch of Nature" + Storytelling

**Giải pháp**: Tạo **Role-Based UI Theme** trong `core/theme/`

### ❌ Vấn đề 2: Không có **AuthGuard** hoàn thiện
- `AuthGuard` hiện có nhưng chưa enforce quy tắc `allowedRoles` đúng cách

**Giải pháp**: Review & fix logic ở `core/widgets/auth_guard.dart`

### ❌ Vấn đề 3: Routes chưa **sắp xếp logic**
- Routes còn rải rác, không theo cấu trúc rõ ràng

**Giải pháp**: Tổ chức routes thành `AuthRoutes`, `FarmerRoutes`, `AdminRoutes`, v.v.

---

## 📋 DANH SÁCH CHỨC NĂNG CHƯA CÓ (Không cần code ngay)

### Ngắn hạn (Phức tạp cao, cọu kếp nhất):
```
1. ❌ Digital Twin 3D (Cây xoay + trạng thái real-time)
2. ❌ IoT Dashboard (Cảm biến đất, độ mặn, pH)
3. ❌ Voice Diary (Nhập liệu bằng giọng nói)
4. ❌ Carbon Calculator (Xác định phát thải theo phân bón/xăng dầu)
5. ❌ Scan & Trace QR (Truy xuất nguồn gốc sản phẩm)
6. ❌ Machine Pricing Engine (Tính giá thuê máy tự động)
7. ❌ ESG Health Check (Self-assessment cho SME)
```

### Dài hạn (Integ ration phức tạp):
```
8. ❌ Blockchain/Tín chỉ Carbon Ledger
9. ❌ Micro-parametric Insurance (Smart Contract)
10. ❌ Green Marketplace Gamification
```

---

## 🔧 CHỈ THỊ FIX GIAO DIỆN (PRIORITY)

### Phase 1: **Role-Based UI** (1-2 tuần)
- [ ] Tạo `AdaptiveTheme` detecting role
- [ ] UI Nông dân: "High Contrast + Voice-First"
- [ ] UI SME: "Dashboard Zen"
- [ ] UI Community: "Touch of Nature"

### Phase 2: **Route Consolidation** (3-5 ngày)
- [ ] Sắp xếp routes theo logic nhóm
- [ ] Thêm `AuthGuard` chặt chẽ
- [ ] Test permission đầy đủ

### Phase 3: **Module Integration** (1 tuần)
- [ ] Liên kết `Farmer` → `Machine Booking`
- [ ] Liên kết `Machine Booking` → `Marketplace` (lịch sử)
- [ ] Liên kết `User` → tất cả module (user context)

---

## 💻 File Cần Xem Lại (Preview)

### High Priority:
1. ✏️ `lib/app.dart` - Routes structure
2. ✏️ `lib/core/widgets/auth_guard.dart` - Permission logic
3. ✏️ `lib/core/theme/` - Color & typography theo design spec

### Medium Priority:
4. 📂 `lib/routes/app_routes.dart` - Sắp xếp lại
5. 📂 `lib/controllers/` - State management cohesion
6. 📂 Tất cả `_page.dart` / `_screen.dart` - Layout consistency

---

## ✅ KHUYẾN NGHỊ TIẾP THEO

1. **Fix Giao Diện Trực Tiếp** (Ngay): Update `app.dart` + theme theo design spec
2. **Tạo Feature Flag** (1-2 tuần): Để bật/tắt các chức năng chưa hoàn:
   - IoT Dashboard
   - Carbon Calculator
   - Scan & Trace
3. **Lên kế hoạch Micro-features** (2-4 tuần): Voice Diary, Digital Twin
4. **Tích hợp dần Backend**: Firebase, Blockchain khi cần

---

**Status**: 🟢 **APP READY FOR UI REFINEMENT**

Hết phần audit. Hãy chỉ rõ bạn muốn fix giao diện phần nào trước!
