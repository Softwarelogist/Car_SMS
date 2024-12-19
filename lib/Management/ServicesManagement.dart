import 'package:flutter/material.dart';
import '../DashboardPage.dart';
import '../db_helper.dart'; // Assuming the DBHelper class is in db_helper.dart
import '../MyTextField.dart'; // Import MyTextField widget
import 'dart:async'; // For debouncing

class ServicesManagement extends StatefulWidget {
  @override
  _ServicesManagementState createState() => _ServicesManagementState();
}

class _ServicesManagementState extends State<ServicesManagement> {
  final DBHelper dbHelper = DBHelper(); // Database helper instance
  final TextEditingController serviceIDController = TextEditingController();
  final TextEditingController carIDController = TextEditingController();
  final TextEditingController customerIDController = TextEditingController();
  final TextEditingController serviceDateController = TextEditingController();
  final TextEditingController serviceDescriptionController =
  TextEditingController();
  final TextEditingController costController = TextEditingController();

  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> filteredServices = [];

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchServices(); // Load services when the widget is initialized
  }

  Future<void> _fetchServices({String query = ''}) async {
    final data = await DBHelper().fetchServices(); // Fetch data from DBHelper
    setState(() {
      services = data;
      filteredServices = services.where((service) {
        final serviceID = service['ServiceID'].toString().toLowerCase();
        final carID = service['CarID'].toString().toLowerCase();
        final customerID = service['CustomerID'].toString().toLowerCase();
        final serviceDate = service['ServiceDate'].toString().toLowerCase();
        final serviceDescription =
        service['ServiceDescription'].toString().toLowerCase();
        final cost = service['Cost'].toString().toLowerCase();
        final queryLower = query.toLowerCase();

        // Perform case-insensitive search across all fields
        return serviceID.contains(queryLower) ||
            carID.contains(queryLower) ||
            customerID.contains(queryLower) ||
            serviceDate.contains(queryLower) ||
            serviceDescription.contains(queryLower) ||
            cost.contains(queryLower);
      }).toList();
    });
  }

  Future<void> _addService() async {
    final service = {
      'ServiceID': int.tryParse(serviceIDController.text),
      'CarID': int.tryParse(carIDController.text),
      'CustomerID': int.tryParse(customerIDController.text),
      'ServiceDate': serviceDateController.text,
      'ServiceDescription': serviceDescriptionController.text,
      'Cost': double.tryParse(costController.text),
    };

    await dbHelper.insertService(service);
    _clearFields();
    _fetchServices(); // Reload the service list
  }

  Future<void> _updateService(int id) async {
    final existingService =
    services.firstWhere((service) => service['ServiceID'] == id,
        orElse: () => {});

    if (existingService.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service with ID $id not found')),
      );
      return;
    }

    final updatedService = {
      'ServiceID': id,
      'CarID': carIDController.text.isNotEmpty
          ? int.tryParse(carIDController.text)
          : existingService['CarID'],
      'CustomerID': customerIDController.text.isNotEmpty
          ? int.tryParse(customerIDController.text)
          : existingService['CustomerID'],
      'ServiceDate': serviceDateController.text.isNotEmpty
          ? serviceDateController.text
          : existingService['ServiceDate'],
      'ServiceDescription': serviceDescriptionController.text.isNotEmpty
          ? serviceDescriptionController.text
          : existingService['ServiceDescription'],
      'Cost': costController.text.isNotEmpty
          ? double.tryParse(costController.text)
          : existingService['Cost'],
    };

    await dbHelper.updateService(id, updatedService);
    _clearFields();
    _fetchServices();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Service with ID $id updated successfully')),
    );
  }

  Future<void> _deleteService(int id) async {
    await dbHelper.deleteService(id);
    _fetchServices();
  }

  void _clearFields() {
    serviceIDController.clear();
    carIDController.clear();
    customerIDController.clear();
    serviceDateController.clear();
    serviceDescriptionController.clear();
    costController.clear();
  }

  void _onSearchChanged(dynamic value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchServices(query: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Services Management"),
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
          child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('ServiceID')),
                      DataColumn(label: Text('Car ID')),
                      DataColumn(label: Text('Customer ID')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Description')),
                      DataColumn(label: Text('Cost')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: filteredServices.map((service) {
                      return DataRow(cells: [
                        DataCell(Text(service['ServiceID'].toString())),
                        DataCell(Text(service['CarID'].toString())),
                        DataCell(Text(service['CustomerID'].toString())),
                        DataCell(Text(service['ServiceDate'])),
                        DataCell(Text(service['ServiceDescription'])),
                        DataCell(Text(service['Cost'].toString())),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  setState(() {
                                    serviceIDController.text =
                                        service['ServiceID'].toString();
                                    carIDController.text =
                                        service['CarID'].toString();
                                    customerIDController.text =
                                        service['CustomerID'].toString();
                                    serviceDateController.text =
                                    service['ServiceDate'];
                                    serviceDescriptionController.text =
                                    service['ServiceDescription'];
                                    costController.text =
                                        service['Cost'].toString();
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _deleteService(service['ServiceID']),
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
                        hintText: 'Service ID',
                        obscureText: false,
                        controller: serviceIDController,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 150,
                      child: MyTextField(
                        hintText: 'Car ID',
                        obscureText: false,
                        controller: carIDController,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 150,
                      child: MyTextField(
                        hintText: 'Customer ID',
                        obscureText: false,
                        controller: customerIDController,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 150,
                      child: MyTextField(
                        hintText: 'Date',
                        obscureText: false,
                        controller: serviceDateController,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 150,
                      child: MyTextField(
                        hintText: 'Description',
                        obscureText: false,
                        controller: serviceDescriptionController,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 150,
                      child: MyTextField(
                        hintText: 'Cost',
                        obscureText: false,
                        controller: costController,
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
                    onPressed: _addService,
                    child: const Text("Add Service"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      final id = int.tryParse(serviceIDController.text);
                      if (id != null) {
                        _updateService(id);
                      }
                    },
                    child: const Text("Update Service"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
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
