import 'package:flutter/material.dart';
import '../DashboardPage.dart';
import '../db_helper.dart'; // Assuming the DBHelper class is in db_helper.dart
import '../MyTextField.dart'; // Import MyTextField widget
import 'dart:async';

class CarManagement extends StatefulWidget {
  @override
  _CarManagementState createState() => _CarManagementState();
}

class _CarManagementState extends State<CarManagement> {
  final DBHelper dbHelper = DBHelper(); // Database helper instance
  final TextEditingController carIDController = TextEditingController();
  final TextEditingController makeController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  List<Map<String, dynamic>> cars = [];
  List<Map<String, dynamic>> filteredCars = [];

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchCars(); // Load cars when the widget is initialized
  }

  Future<void> _fetchCars({String query = ''}) async {
    final data = await DBHelper().fetchCars(); // Fetch data from DBHelper
    setState(() {
      cars = data;
      filteredCars = cars.where((car) {
        final make = car['Make'].toString().toLowerCase();
        final model = car['Model'].toString().toLowerCase();
        final year = car['Year'].toString();
        final price = car['Price'].toString();
        final stock = car['Stock'].toString();
        final carID = car['CarID'].toString();
        final queryLower = query.toLowerCase();

        // Perform case-insensitive search across all fields
        return make.contains(queryLower) ||
            model.contains(queryLower) ||
            year.contains(queryLower) ||
            price.contains(queryLower) ||
            stock.contains(queryLower) ||
            carID.contains(queryLower);
      }).toList();
    });
  }

  Future<void> _addCar() async {
    final car = {
      'CarID': int.tryParse(carIDController.text),
      'Make': makeController.text,
      'Model': modelController.text,
      'Year': int.tryParse(yearController.text),
      'Price': double.tryParse(priceController.text),
      'Stock': int.tryParse(stockController.text),
    };

    await dbHelper.insertCar(car);
    _clearFields();
    _fetchCars(); // Reload the car list
  }

  Future<void> _updateCar(int id) async {
    final existingCar = cars.firstWhere((car) => car['CarID'] == id, orElse: () => {});

    if (existingCar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Car with ID $id not found')),
      );
      return;
    }

    final updatedCar = {
      'CarID': id,
      'Make': makeController.text.isNotEmpty ? makeController.text : existingCar['Make'],
      'Model': modelController.text.isNotEmpty ? modelController.text : existingCar['Model'],
      'Year': yearController.text.isNotEmpty ? int.tryParse(yearController.text) : existingCar['Year'],
      'Price': priceController.text.isNotEmpty ? double.tryParse(priceController.text) : existingCar['Price'],
      'Stock': stockController.text.isNotEmpty ? int.tryParse(stockController.text) : existingCar['Stock'],
    };

    await dbHelper.updateCar(id, updatedCar);
    _clearFields();
    _fetchCars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Car with ID $id updated successfully')),
    );
  }

  Future<void> _deleteCar(int id) async {
    await dbHelper.deleteCar(id);
    _fetchCars();
  }

  void _clearFields() {
    carIDController.clear();
    makeController.clear();
    modelController.clear();
    yearController.clear();
    priceController.clear();
    stockController.clear();
  }

  void _onSearchChanged(dynamic value) {
    // Cancel the previous debounce if it exists
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // Start a new debounce for the search input
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchCars(query: value); // Call _fetchCars after delay
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent, // Transparent background
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Transparent scaffold
          appBar: AppBar(
          title: const Text("Car Management"),
          backgroundColor: Colors.black.withOpacity(0.2), // Semi-transparent AppBar
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
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Make')),
                      DataColumn(label: Text('Model')),
                      DataColumn(label: Text('Year')),
                      DataColumn(label: Text('Price')),
                      DataColumn(label: Text('Stock')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: filteredCars.map((car) {
                      return DataRow(
                         cells: [
                        DataCell(Text(car['CarID'].toString())),
                        DataCell(Text(car['Make'])),
                        DataCell(Text(car['Model'])),
                        DataCell(Text(car['Year'].toString())),
                        DataCell(Text(car['Price'].toString())),
                        DataCell(Text(car['Stock'].toString())),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  setState(() {
                                    makeController.text = car['Make'];
                                    modelController.text = car['Model'];
                                    yearController.text = car['Year'].toString();
                                    priceController.text = car['Price'].toString();
                                    stockController.text = car['Stock'].toString();
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteCar(car['CarID']),
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
              // Input Fields for Car Details in a Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: MyTextField(
                        hintText: 'CarID',
                        obscureText: false,
                        controller: carIDController,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 150,
                      child: MyTextField(
                        hintText: 'Make',
                        obscureText: false,
                        controller: makeController,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 150,
                      child: MyTextField(
                        hintText: 'Model',
                        obscureText: false,
                        controller: modelController,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 150,
                      child: MyTextField(
                        hintText: 'Year',
                        obscureText: false,
                        controller: yearController,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 150,
                      child: MyTextField(
                        hintText: 'Price',
                        obscureText: false,
                        controller: priceController,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 150,
                      child: MyTextField(
                        hintText: 'Stock',
                        obscureText: false,
                        controller: stockController,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Add or Update Button
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _addCar,
                    child: const Text("Add Car"),
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
                      final id = int.tryParse(carIDController.text);
                      if (id != null) {
                        _updateCar(id);
                      }
                    },
                    child: const Text("Update Car"),
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
