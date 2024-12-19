import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  static const String dbName = 'CarServiceShop.db';
  static const String userTable = 'user_account';
  static const String carTable = 'cars';
  static const String customerTable = 'customers';
  static const String employeeTable = 'employees';
  static const String serviceTable = 'services';
  static const String paymentTable = 'payments';
  static const String orderTable='orders';

  // Singleton database initializer
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create tables
        await db.execute('''
          CREATE TABLE $userTable (
            username TEXT PRIMARY KEY,
            password TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE $carTable (
            CarID INTEGER PRIMARY KEY AUTOINCREMENT,
            Make TEXT,
            Model TEXT,
            Year INTEGER,
            Price REAL,
            Stock INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE $customerTable (
            CustomerID INTEGER PRIMARY KEY AUTOINCREMENT,
            FirstName TEXT,
            LastName TEXT,
            Email TEXT,
            Phone TEXT,
            Address TEXT,
            City TEXT,
            State TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE $employeeTable (
            EmployeeID INTEGER PRIMARY KEY AUTOINCREMENT,
            FirstName TEXT,
            LastName TEXT,
            Position TEXT,
            Salary REAL,
            HireDate TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE $serviceTable (
            ServiceID INTEGER PRIMARY KEY AUTOINCREMENT,
            CarID INTEGER,
            CustomerID INTEGER,
            ServiceDate TEXT,
            ServiceDescription TEXT,
            Cost REAL,
            FOREIGN KEY(CarID) REFERENCES $carTable(CarID),
            FOREIGN KEY(CustomerID) REFERENCES $customerTable(CustomerID)
          )
        ''');

        await db.execute('''
          CREATE TABLE $paymentTable (
            PaymentID INTEGER PRIMARY KEY AUTOINCREMENT,
            OrderID INTEGER,
            PaymentDate TEXT,
            PaymentMethod TEXT,
            Amount REAL
          )
        ''');

        await db.execute('''
        CREATE TABLE $orderTable(
        OrderID INTEGER PRIMARY KEY AUTOINCREMENT,
        OrderDate TEXT,
        CarID INTEGER,
        CustomerID INTEGER,
        EmployeeID INTEGER,
         Quantity INTEGER,
        TotalPrice DECIMAL,
        FOREIGN KEY(CarID) REFERENCES $carTable(CarID),
        FOREIGN KEY(CustomerID) REFERENCES $customerTable(CustomerID),
        FOREIGN KEY(EmployeeID) REFERENCES $employeeTable(EmployeeID)
       
        
        )''');
      },


    );
  }

  // User table functions
  Future<void> insertUser(String username, String password) async {
    final db = await database;
    await db.insert(
      userTable,
      {'username': username, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> fetchUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      userTable,
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Car table functions
  Future<int> insertCar(Map<String, dynamic> car) async {
    final db = await database;
    return await db.insert(
      carTable,
      car,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>>  fetchCars() async {
    final db = await database;
    return await db.query(carTable);
  }

  Future<int> updateCar(int carId, Map<String, dynamic> car) async {
    final db = await database;
    return await db.update(
      carTable,
      car,
      where: 'CarID = ?',
      whereArgs: [carId],
    );
  }

  Future<int> deleteCar(int carId) async {
    final db = await database;
    return await db.delete(
      carTable,
      where: 'CarID = ?',
      whereArgs: [carId],
    );
  }

  // Customer table functions
  Future<int> insertCustomer(Map<String, dynamic> customer) async {
    final db = await database;
    return await db.insert(
      customerTable,
      customer,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> fetchCustomers({String? filterColumn, String? filterValue}) async {
    final db = await database;

    if (filterColumn != null && filterValue != null && filterValue.isNotEmpty) {
      return await db.query(
        customerTable,
        where: '$filterColumn LIKE ?',
        whereArgs: ['%$filterValue%'],
      );
    }

    return await db.query(customerTable);
  }

  Future<int> updateCustomer(int customerId, Map<String, dynamic> customer) async {
    final db = await database;
    return await db.update(
      customerTable,
      customer,
      where: 'CustomerID = ?',
      whereArgs: [customerId],
    );
  }

  Future<int> deleteCustomer(int customerId) async {
    final db = await database;
    return await db.delete(
      customerTable,
      where: 'CustomerID = ?',
      whereArgs: [customerId],
    );
  }

  // Employee table functions
  Future<int> insertEmployee(Map<String, dynamic> employee) async {
    final db = await database;
    return await db.insert(
      employeeTable,
      employee,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> fetchEmployees({String? filterColumn, String? filterValue}) async {
    final db = await database;

    if (filterColumn != null && filterValue != null && filterValue.isNotEmpty) {
      return await db.query(
        employeeTable,
        where: '$filterColumn LIKE ?',
        whereArgs: ['%$filterValue%'],
      );
    }

    return await db.query(employeeTable);
  }

  Future<int> updateEmployee(int employeeId, Map<String, dynamic> employee) async {
    final db = await database;
    return await db.update(
      employeeTable,
      employee,
      where: 'EmployeeID = ?',
      whereArgs: [employeeId],
    );
  }

  Future<int> deleteEmployee(int employeeId) async {
    final db = await database;
    return await db.delete(
      employeeTable,
      where: 'EmployeeID = ?',
      whereArgs: [employeeId],
    );
  }

  // Service table functions
  Future<int> insertService(Map<String, dynamic> service) async {
    final db = await database;
    return await db.insert(
      serviceTable,
      service,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> fetchServices() async {
    final db = await database;
    return await db.query(serviceTable);
  }

  Future<int> updateService(int serviceId, Map<String, dynamic> service) async {
    final db = await database;
    return await db.update(
      serviceTable,
      service,
      where: 'ServiceID = ?',
      whereArgs: [serviceId],
    );
  }

  Future<int> deleteService(int serviceId) async {
    final db = await database;
    return await db.delete(
      serviceTable,
      where: 'ServiceID = ?',
      whereArgs: [serviceId],
    );
  }

  // Payment table functions
  Future<int> insertPayment(Map<String, dynamic> payment) async {
    final db = await database;
    return await db.insert(
      paymentTable,
      payment,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> fetchPayments({String? filterColumn, String? filterValue}) async {
    final db = await database;

    if (filterColumn != null && filterValue != null && filterValue.isNotEmpty) {
      return await db.query(
        paymentTable,
        where: '$filterColumn LIKE ?',
        whereArgs: ['%$filterValue%'],
      );
    }

    return await db.query(paymentTable);
  }

  Future<int> updatePayment(int paymentId, Map<String, dynamic> payment) async {
    final db = await database;
    return await db.update(
      paymentTable,
      payment,
      where: 'PaymentID = ?',
      whereArgs: [paymentId],
    );
  }

  Future<int> deletePayment(int paymentId) async {
    final db = await database;
    return await db.delete(
      paymentTable,
      where: 'PaymentID = ?',
      whereArgs: [paymentId],
    );
  }
  //Order Table functions
  Future<int> insertOrder(Map<String, dynamic> order) async {
    final db = await database;
    return await db.insert(
      orderTable,
      order,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> fetchOrders({String? filterColumn, String? filterValue}) async {
    final db = await database;
    if (filterColumn != null && filterValue != null && filterValue.isNotEmpty) {
      return await db.query(
        orderTable,
        where: '$filterColumn LIKE ?',
        whereArgs: ['%$filterValue%'],
      );
    }
    return await db.query(orderTable);
  }

  Future<int> updateOrder(int orderId, Map<String, dynamic> order) async {
    final db = await database;
    return await db.update(
      orderTable,
      order,
      where: 'OrderID = ?',
      whereArgs: [orderId],
    );
}
  Future<int> deleteOrder(int orderId) async {
    final db = await database;
    return await db.delete(
      orderTable,
      where: 'OrderID = ?',
      whereArgs: [orderId],
    );
  }
}
