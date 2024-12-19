import 'package:flutter/material.dart';
import 'dart:async';
import '../DashboardPage.dart';
import '../db_helper.dart'; // Assuming the DBHelper class is in db_helper.dart
import '../MyTextField.dart'; // Import MyTextField widget

class OrderManagement extends StatefulWidget {
  @override
  _OrderManagementState createState() => _OrderManagementState();
}

class _OrderManagementState extends State<OrderManagement> {
  final DBHelper dbHelper = DBHelper();

  // Controllers for managing form inputs
  final TextEditingController orderIDController = TextEditingController();
  final TextEditingController orderDateController = TextEditingController();
  final TextEditingController carIDController = TextEditingController();
  final TextEditingController customerIDController = TextEditingController();
  final TextEditingController employeeIDController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController totalPriceController = TextEditingController();

  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> filteredOrders = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // Fetch orders and optionally filter by query
  Future<void> _fetchOrders({String query = ''}) async {
    final data = await dbHelper.fetchOrders();
    setState(() {
      orders = data;
      filteredOrders = orders.where((order) {
        final orderID = order['OrderID'].toString().toLowerCase();
        final orderDate = order['OrderDate'].toString().toLowerCase();
        final carID = order['CarID'].toString().toLowerCase();
        final customerID = order['CustomerID'].toString().toLowerCase();
        final employeeID = order['EmployeeID'].toString().toLowerCase();
        final quantity = order['Quantity'].toString().toLowerCase();
        final totalPrice = order['TotalPrice'].toString().toLowerCase();
        final queryLower = query.toLowerCase();

        return orderID.contains(queryLower) ||
            orderDate.contains(queryLower) ||
            carID.contains(queryLower) ||
            customerID.contains(queryLower) ||
            employeeID.contains(queryLower) ||
            quantity.contains(queryLower) ||
            totalPrice.contains(queryLower);
      }).toList();
    });
  }

  // Add a new order
  Future<void> _addOrder() async {
    final order = {
      'OrderID': int.tryParse(orderIDController.text),
      'OrderDate': orderDateController.text,
      'CarID': int.tryParse(carIDController.text),
      'CustomerID': int.tryParse(customerIDController.text),
      'EmployeeID': int.tryParse(employeeIDController.text),
      'Quantity': int.tryParse(quantityController.text),
      'TotalPrice': double.tryParse(totalPriceController.text),
    };
    await dbHelper.insertOrder(order);
    _clearFields();
    _fetchOrders();
  }

  // Update an existing order
  Future<void> _updateOrder(int id) async {
    final existingOrder =
    orders.firstWhere((order) => order['OrderID'] == id, orElse: () => {});

    if (existingOrder == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order with ID $id not found')),
      );
      return;
    }

    final updatedOrder = {
      'OrderID': id,
      'OrderDate': orderDateController.text.isNotEmpty
          ? orderDateController.text
          : existingOrder['OrderDate'],
      'CarID': carIDController.text.isNotEmpty
          ? int.tryParse(carIDController.text)
          : existingOrder['CarID'],
      'CustomerID': customerIDController.text.isNotEmpty
          ? int.tryParse(customerIDController.text)
          : existingOrder['CustomerID'],
      'EmployeeID': employeeIDController.text.isNotEmpty
          ? int.tryParse(employeeIDController.text)
          : existingOrder['EmployeeID'],
      'Quantity': quantityController.text.isNotEmpty
          ? int.tryParse(quantityController.text)
          : existingOrder['Quantity'],
      'TotalPrice': totalPriceController.text.isNotEmpty
          ? double.tryParse(totalPriceController.text)
          : existingOrder['TotalPrice'],
    };

    await dbHelper.updateOrder(id, updatedOrder);
    _clearFields();
    _fetchOrders();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order with ID $id updated successfully')),
    );
  }

  // Delete an order
  Future<void> _deleteOrder(int id) async {
    await dbHelper.deleteOrder(id);
    _fetchOrders();
  }

  // Clear input fields
  void _clearFields() {
    orderIDController.clear();
    orderDateController.clear();
    carIDController.clear();
    customerIDController.clear();
    employeeIDController.clear();
    quantityController.clear();
    totalPriceController.clear();
  }

  // Handle search input with debounce
  void _onSearchChanged(dynamic value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchOrders(query: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Order Management"),
          backgroundColor: Colors.black.withOpacity(0.2),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Navigate back to DashboardPage when back button is pressed
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const DashboardPage()),
              );
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Order ID')),
                      DataColumn(label: Text('Order Date')),
                      DataColumn(label: Text('Car ID')),
                      DataColumn(label: Text('Customer ID')),
                      DataColumn(label: Text('Employee ID')),
                      DataColumn(label: Text('Quantity')),
                      DataColumn(label: Text('Total Price')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: filteredOrders.map((order) {
                      return DataRow(cells: [
                        DataCell(Text(order['OrderID'].toString())),
                        DataCell(Text(order['OrderDate'])),
                        DataCell(Text(order['CarID'].toString())),
                        DataCell(Text(order['CustomerID'].toString())),
                        DataCell(Text(order['EmployeeID'].toString())),
                        DataCell(Text(order['Quantity'].toString())),
                        DataCell(Text(order['TotalPrice'].toString())),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  setState(() {
                                    orderDateController.text = order['OrderDate'];
                                    carIDController.text = order['CarID'].toString();
                                    customerIDController.text =
                                        order['CustomerID'].toString();
                                    employeeIDController.text =
                                        order['EmployeeID'].toString();
                                    quantityController.text =
                                        order['Quantity'].toString();
                                    totalPriceController.text =
                                        order['TotalPrice'].toString();
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteOrder(order['OrderID']),
                              ),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
                ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: MyTextField(
                        hintText: 'Order ID',
                        controller: orderIDController,
                        obscureText: false,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 150,
                      child: MyTextField(
                        hintText: 'Order Date',
                        controller: orderDateController,
                        obscureText: false,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 150,
                      child: MyTextField(
                        hintText: 'Car ID',
                        controller: carIDController,
                        obscureText: false,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 150,
                      child: MyTextField(
                        hintText: 'Customer ID',
                        controller: customerIDController,
                        obscureText: false,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 150,
                      child: MyTextField(
                        hintText: 'Employee ID',
                        controller: employeeIDController,
                        obscureText: false,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 150,
                      child: MyTextField(
                        hintText: 'Quantity',
                        controller: quantityController,
                        obscureText: false,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 150,
                      child: MyTextField(
                        hintText: 'Total Price',
                        controller: totalPriceController,
                        obscureText: false,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _addOrder,
                    child: const Text("Add Order"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      )
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      final id = int.tryParse(orderIDController.text);
                      if (id != null) {
                        _updateOrder(id);
                      }
                    },
                    child: const Text("Update Order"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      )
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
