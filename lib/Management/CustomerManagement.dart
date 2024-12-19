import 'package:flutter/material.dart';
import 'dart:async';
import '../DashboardPage.dart';
import '../db_helper.dart'; // Assuming DBHelper class handles Customer-related queries
import '../MyTextField.dart'; // Assuming a reusable TextField widget

class CustomerManagement extends StatefulWidget {
  @override
  _CustomerManagementState createState() => _CustomerManagementState();
}

class _CustomerManagementState extends State<CustomerManagement> {
  final DBHelper dbHelper = DBHelper();
  final TextEditingController customerIDController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();

  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> filteredCustomers = [];
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers({String query = ''}) async {
    final data = await dbHelper.fetchCustomers();
    setState(() {
      customers = data;
      filteredCustomers = customers.where((customer) {
        final combinedData = [
          customer['CustomerID'].toString(),
          customer['FirstName'],
          customer['LastName'],
          customer['Email'],
          customer['Phone'],
          customer['Address'],
          customer['City'],
          customer['State']
        ].join(' ').toLowerCase();

        return combinedData.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _addCustomer() async {
    final customer = {
      ' CustomerID': customerIDController.text,
      'FirstName': firstNameController.text,
      'LastName': lastNameController.text,
      'Email': emailController.text,
      'Phone': phoneController.text,
      'Address': addressController.text,
      'City': cityController.text,
      'State': stateController.text,
    };

    await dbHelper.insertCustomer(customer);
    _clearFields();
    _fetchCustomers();
  }

  Future<void> _updateCustomer(int id) async {
    final updatedCustomer = {
      ' CustomerID':customerIDController.text,
      'FirstName': firstNameController.text,
      'LastName': lastNameController.text,
      'Email': emailController.text,
      'Phone': phoneController.text,
      'Address': addressController.text,
      'City': cityController.text,
      'State': stateController.text,
    };

    await dbHelper.updateCustomer(id, updatedCustomer);
    _clearFields();
    _fetchCustomers();
  }

  Future<void> _deleteCustomer(int id) async {
    await dbHelper.deleteCustomer(id);
    _fetchCustomers();
  }

  void _clearFields() {
    customerIDController.clear();
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    cityController.clear();
    stateController.clear();
  }

  void _onSearchChanged(dynamic value) {
    // Cancel the previous debounce if it exists
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // Start a new debounce for the search input
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchCustomers(query: value); // Call _fetchCars after delay
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          color: Colors.transparent, // Transparent background
        ),
    child:  Scaffold(
    backgroundColor: Colors.transparent,
    appBar: AppBar(
        title: Text("Customer Management"),
    backgroundColor: Colors.black.withOpacity(0.5),
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
              child:SingleChildScrollView(
             scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Customer ID')),
                    DataColumn(label: Text('First Name')),
                    DataColumn(label: Text('Last Name')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Phone')),
                    DataColumn(label: Text('Address')),
                    DataColumn(label: Text('City')),
                    DataColumn(label: Text('State')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: filteredCustomers.map((customer) {
                    return DataRow(
                      cells: [
                        DataCell(Text(customer['CustomerID'].toString())),
                        DataCell(Text(customer['FirstName'] ?? '')),
                        DataCell(Text(customer['LastName'] ?? '')),
                        DataCell(Text(customer['Email'] ?? '')),
                        DataCell(Text(customer['Phone'] ?? '')),
                        DataCell(Text(customer['Address'] ?? '')),
                        DataCell(Text(customer['City'] ?? '')),
                        DataCell(Text(customer['State'] ?? '')),
                        DataCell(
                             Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                setState(() {
                                  customerIDController.text =
                                      customer['CustomerID'].toString();
                                  firstNameController.text =
                                      customer['FirstName'] ?? '';
                                  lastNameController.text =
                                      customer['LastName'] ?? '';
                                  emailController.text = customer['Email'] ?? '';
                                  phoneController.text = customer['Phone'] ?? '';
                                  addressController.text =
                                      customer['Address'] ?? '';
                                  cityController.text = customer['City'] ?? '';
                                  stateController.text = customer['State'] ?? '';
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deleteCustomer(customer['CustomerID']),
                            ),
                          ],
                        )
                        ),
                      ],
                    );
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
                    hintText: 'CustomerID',
                    obscureText: false,
                    controller: customerIDController,
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 150,
                  child: MyTextField(
                    hintText: 'First Name',
                    obscureText: false,
                    controller: firstNameController,
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 150,
                  child: MyTextField(
                    hintText: 'Last Name',
                    obscureText: false,
                    controller: lastNameController,
                    onChanged: _onSearchChanged,
                  ),
                ),
              const SizedBox(width: 10),
              SizedBox(
                width: 150,
                  child: MyTextField(
                    hintText: 'Email',
                    obscureText: false,
                    controller: emailController,
                      onChanged: _onSearchChanged,
                  ),
                ),
              const SizedBox(width: 10),
              SizedBox(
                width: 150,
                  child: MyTextField(
                    hintText: 'Phone',
                    obscureText: false,
                    controller: phoneController,
                    onChanged: _onSearchChanged,
                  ),
                ),
               const SizedBox(width: 10),
            SizedBox(
              width: 150,
                  child: MyTextField(
                    hintText: 'Address',
                    obscureText: false,
                    controller: addressController,
                    onChanged: _onSearchChanged,
                  ),
                ),
               const SizedBox(width: 10),
                SizedBox(
                 width: 150,
                  child: MyTextField(
                    hintText: 'City',
                    controller: cityController,
                    obscureText: false,
                    onChanged: _onSearchChanged,
                  ),
                ),
               const SizedBox(width: 10),
               SizedBox(
               width: 150,
                  child: MyTextField(
                    hintText: 'State',
                    controller: stateController,
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
                  onPressed: _addCustomer,
                  child: Text("Add"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    )
                ),
                ElevatedButton(
                  onPressed: () {
                    final id = int.tryParse(customerIDController.text);
                    if (id != null) {
                      _updateCustomer(id);
                    }
                  },
                  child: Text("Update"),
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
