// =============================================================
// tables.dart
// Database Schema Definition cho PRM393
// Không lạm dụng static
// =============================================================

class TableSchema {
  final String name;
  final Map<String, String> columns;

  const TableSchema({required this.name, required this.columns});

  String column(String key) => columns[key]!;
}

// =============================================================
// USERS
// =============================================================

final usersTable = TableSchema(
  name: 'Users',
  columns: {
    'userId': 'UserId',
    'phoneNumber': 'PhoneNumber',
    'email': 'Email',
    'passwordHash': 'PasswordHash',
    'roleType': 'RoleType',
    'displayName': 'DisplayName',
    'isActive': 'IsActive',
    'createdAt': 'CreatedAt',
  },
);

// =============================================================
// ADMIN
// =============================================================

final adminProfilesTable = TableSchema(
  name: 'AdminProfiles',
  columns: {
    'adminId': 'AdminId',
    'fullName': 'FullName',
    'position': 'Position',
    'createdAt': 'CreatedAt',
  },
);

// =============================================================
// ADDRESSES
// =============================================================

final userAddressesTable = TableSchema(
  name: 'core_UserAddresses',
  columns: {
    'addressId': 'AddressId',
    'userId': 'UserId',
    'province': 'Province',
    'district': 'District',
    'commune': 'Commune',
    'addressLine': 'AddressLine',
    'createdAt': 'CreatedAt',
  },
);

// =============================================================
// FARMER
// =============================================================

final farmerProfilesTable = TableSchema(
  name: 'FarmerProfiles',
  columns: {
    'userId': 'UserId',
    'fullName': 'FullName',
    'village': 'Village',
    'contactName': 'ContactName',
    'contactPhone': 'ContactPhone',
    'preferredVoice': 'PreferredVoice',
  },
);

// =============================================================
// SME
// =============================================================

final smeProfilesTable = TableSchema(
  name: 'SMEProfiles',
  columns: {
    'userId': 'UserId',
    'companyName': 'CompanyName',
    'taxCode': 'TaxCode',
    'contactName': 'ContactName',
    'contactPhone': 'ContactPhone',
    'addressSummary': 'AddressSummary',
  },
);

// =============================================================
// IMAGES
// =============================================================

final imagesTable = TableSchema(
  name: 'Images',
  columns: {
    'imageId': 'ImageId',
    'referenceId': 'ReferenceId',
    'referenceType': 'ReferenceType',
    'imageUrl': 'ImageUrl',
    'isPrimary': 'IsPrimary',
    'displayOrder': 'DisplayOrder',
    'uploadedAt': 'UploadedAt',
  },
);

// =============================================================
// FARMS
// =============================================================

final farmsTable = TableSchema(
  name: 'iot_Farms',
  columns: {
    'farmId': 'FarmId',
    'farmerId': 'FarmerId',
    'farmName': 'FarmName',
    'location': 'Location',
    'areaHectares': 'AreaHectares',
    'cropType': 'CropType',
    'certifications': 'Certifications',
  },
);

// =============================================================
// IOT DEVICES
// =============================================================

final iotDevicesTable = TableSchema(
  name: 'iot_IoTDevices',
  columns: {
    'deviceId': 'DeviceId',
    'farmId': 'FarmId',
    'deviceType': 'DeviceType',
    'description': 'Description',
    'batteryLevel': 'BatteryLevel',
  },
);

// =============================================================
// SENSOR READINGS
// =============================================================

final sensorReadingsTable = TableSchema(
  name: 'iot_IoTSensorReadings',
  columns: {
    'readingId': 'ReadingId',
    'deviceId': 'DeviceId',
    'metricType': 'MetricType',
    'metricValue': 'MetricValue',
    'recordedAt': 'RecordedAt',
  },
);

// =============================================================
// FARMING LOGS
// =============================================================

final farmingLogsTable = TableSchema(
  name: 'iot_FarmingLogs',
  columns: {
    'logId': 'LogId',
    'farmId': 'FarmId',
    'actionType': 'ActionType',
    'materialUsed': 'MaterialUsed',
    'quantity': 'Quantity',
    'recordedAt': 'RecordedAt',
  },
);

// =============================================================
// MACHINES
// =============================================================

final agriMachinesTable = TableSchema(
  name: 'logistics_AgriMachines',
  columns: {
    'machineId': 'MachineId',
    'ownerId': 'OwnerId',
    'machineType': 'MachineType',
    'description': 'Description',
    'basePricePerHour': 'BasePricePerHour',
  },
);

// =============================================================
// MACHINE REQUESTS
// =============================================================

final machineRequestsTable = TableSchema(
  name: 'logistics_MachineHailingRequests',
  columns: {
    'requestId': 'RequestId',
    'farmId': 'FarmId',
    'machineTypeRequired': 'MachineTypeRequired',
    'expectedStartTime': 'ExpectedStartTime',
    'status': 'Status',
  },
);

// =============================================================
// MACHINE BOOKINGS
// =============================================================

final machineBookingsTable = TableSchema(
  name: 'logistics_MachineBookings',
  columns: {
    'bookingId': 'BookingId',
    'machineId': 'MachineId',
    'farmId': 'FarmId',
    'bookerId': 'BookerId',
    'startTime': 'StartTime',
    'endTime': 'EndTime',
    'totalPrice': 'TotalPrice',
    'status': 'Status',
    'createdAt': 'CreatedAt',
  },
);

// =============================================================
// PRODUCTS
// =============================================================

final productsTable = TableSchema(
  name: 'commerce_Products',
  columns: {
    'productId': 'ProductId',
    'sellerId': 'SellerId',
    'title': 'Title',
    'description': 'Description',
    'category': 'Category',
    'price': 'Price',
    'unit': 'Unit',
    'createdAt': 'CreatedAt',
  },
);

// =============================================================
// PRODUCT BATCH
// =============================================================

final productBatchesTable = TableSchema(
  name: 'commerce_ProductBatches',
  columns: {
    'productBatchId': 'ProductBatchId',
    'productId': 'ProductId',
    'batchCode': 'BatchCode',
    'productionDate': 'ProductionDate',
  },
);

// =============================================================
// CART
// =============================================================

final cartsTable = TableSchema(
  name: 'commerce_Carts',
  columns: {'cartId': 'CartId', 'userId': 'UserId', 'createdAt': 'CreatedAt'},
);

// =============================================================
// CART ITEMS
// =============================================================

final cartItemsTable = TableSchema(
  name: 'commerce_CartItems',
  columns: {
    'cartItemId': 'CartItemId',
    'cartId': 'CartId',
    'productId': 'ProductId',
    'quantity': 'Quantity',
    'addedAt': 'AddedAt',
  },
);

// =============================================================
// ORDERS
// =============================================================

final ordersTable = TableSchema(
  name: 'commerce_Orders',
  columns: {
    'orderId': 'OrderId',
    'buyerId': 'BuyerId',
    'orderTotal': 'OrderTotal',
    'status': 'Status',
    'createdAt': 'CreatedAt',
  },
);

// =============================================================
// ORDER ITEMS
// =============================================================

final orderItemsTable = TableSchema(
  name: 'commerce_OrderItems',
  columns: {
    'orderItemId': 'OrderItemId',
    'orderId': 'OrderId',
    'productId': 'ProductId',
    'quantity': 'Quantity',
    'price': 'Price',
  },
);

// =============================================================
// NOTIFICATIONS
// =============================================================

final notificationsTable = TableSchema(
  name: 'Notifications',
  columns: {
    'notificationId': 'NotificationId',
    'userId': 'UserId',
    'title': 'Title',
    'isRead': 'IsRead',
    'createdAt': 'CreatedAt',
  },
);
