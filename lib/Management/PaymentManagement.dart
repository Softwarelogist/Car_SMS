import 'package:flutter/material.dart';
import 'dart:async';
import '../DashboardPage.dart';
import '../db_helper.dart'; // Assuming the DBHelper class is in db_helper.dart
import '../MyTextField.dart'; // Import MyTextField widget

class PaymentManagement extends StatefulWidget {
  @override
  _PaymentManagementState createState() => _PaymentManagementState();
}

class _PaymentManagementState extends State<PaymentManagement> {
  final DBHelper dbHelper = DBHelper();

  // Controllers for managing form inputs
  final TextEditingController paymentIDController = TextEditingController();
  final TextEditingController orderIDController = TextEditingController();
  final TextEditingController paymentDateController = TextEditingController();
  final TextEditingController paymentMethodController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  List<Map<String, dynamic>> payments = [];
  List<Map<String, dynamic>> filteredPayments = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  // Fetch payments and optionally filter by query
  Future<void> _fetchPayments({String query = ''}) async {
    final data = await dbHelper.fetchPayments();
    setState(() {
      payments = data;
      filteredPayments = payments.where((payment) {
        final paymentID = payment['PaymentID'].toString().toLowerCase();
        final orderID = payment['OrderID'].toString().toLowerCase();
        final paymentDate = payment['PaymentDate'].toLowerCase();
        final paymentMethod = payment['PaymentMethod'].toLowerCase();
        final amount = payment['Amount'].toString().toLowerCase();
        final queryLower = query.toLowerCase();

        return paymentID.contains(queryLower) ||
            orderID.contains(queryLower) ||
            paymentDate.contains(queryLower) ||
            paymentMethod.contains(queryLower) ||
            amount.contains(queryLower);
      }).toList();
    });
  }

  // Add a new payment
  Future<void> _addPayment() async {
    final payment = {
      'PaymentID': int.tryParse(paymentIDController.text),
      'OrderID': int.tryParse(orderIDController.text),
      'PaymentDate': paymentDateController.text,
      'PaymentMethod': paymentMethodController.text,
      'Amount': double.tryParse(amountController.text),
    };
    await dbHelper.insertPayment(payment);
    _clearFields();
    _fetchPayments();
  }

  // Update an existing payment
  Future<void> _updatePayment(int id) async {
    final existingPayment =
    payments.firstWhere((payment) => payment['PaymentID'] == id, orElse: () => {});

    if (existingPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment with ID $id not found')),
      );
      return;
    }

    final updatedPayment = {
      'PaymentID': id,
      'OrderID': orderIDController.text.isNotEmpty
          ? int.tryParse(orderIDController.text)
          : existingPayment['OrderID'],
      'PaymentDate': paymentDateController.text.isNotEmpty
          ? paymentDateController.text
          : existingPayment['PaymentDate'],
      'PaymentMethod': paymentMethodController.text.isNotEmpty
          ? paymentMethodController.text
          : existingPayment['PaymentMethod'],
      'Amount': amountController.text.isNotEmpty
          ? double.tryParse(amountController.text)
          : existingPayment['Amount'],
    };

    await dbHelper.updatePayment(id, updatedPayment);
    _clearFields();
    _fetchPayments();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment with ID $id updated successfully')),
    );
  }

  // Delete a payment
  Future<void> _deletePayment(int id) async {
    await dbHelper.deletePayment(id);
    _fetchPayments();
  }

  // Clear input fields
  void _clearFields() {
    paymentIDController.clear();
    orderIDController.clear();
    paymentDateController.clear();
    paymentMethodController.clear();
    amountController.clear();
  }

  // Handle search input with debounce
  void _onSearchChanged(dynamic value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchPayments(query: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Payment Management"),
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
                      DataColumn(label: Text('Payment ID')),
                      DataColumn(label: Text('Order ID')),
                      DataColumn(label: Text('Payment Date')),
                      DataColumn(label: Text('Payment Method')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: filteredPayments.map((payment) {
                      return DataRow(cells: [
                        DataCell(Text(payment['PaymentID'].toString())),
                        DataCell(Text(payment['OrderID'].toString())),
                        DataCell(Text(payment['PaymentDate'])),
                        DataCell(Text(payment['PaymentMethod'])),
                        DataCell(Text(payment['Amount'].toString())),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  setState(() {
                                    orderIDController.text = payment['OrderID'].toString();
                                    paymentDateController.text = payment['PaymentDate'];
                                    paymentMethodController.text = payment['PaymentMethod'];
                                    amountController.text = payment['Amount'].toString();
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deletePayment(payment['PaymentID']),
                              ),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: MyTextField(
                        hintText: 'Payment ID',
                        controller: paymentIDController,
                        obscureText: false,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
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
                        hintText: 'Payment Date',
                        controller: paymentDateController,
                        obscureText: false,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 150,
                      child: MyTextField(
                        hintText: 'Payment Method',
                        controller: paymentMethodController,
                        obscureText: false,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 150,
                      child: MyTextField(
                        hintText: 'Amount',
                        controller: amountController,
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
                    onPressed: _addPayment,
                    child: const Text("Add Payment"),
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
                      final id = int.tryParse(paymentIDController.text);
                      if (id != null) {
                        _updatePayment(id);
                      }
                    },
                    child: const Text("Update Payment"),
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
