import 'package:flutter/material.dart';
import 'dart:async';
import '../DashboardPage.dart';
import '../db_helper.dart'; // Assuming the DBHelper class is in db_helper.dart
import '../MyTextField.dart'; // Import MyTextField widget

class EmployeeManagement extends StatefulWidget {
  @override
  _EmployeeManagementState createState() => _EmployeeManagementState();
}

class _EmployeeManagementState extends State<EmployeeManagement> {
  final DBHelper dbHelper = DBHelper();
  final TextEditingController employeeIDController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController hireDateController = TextEditingController();
  List<Map<String, dynamic>> employees = [];
  List<Map<String, dynamic>> filteredEmployees = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees({String query = ''}) async {
    final data = await dbHelper.fetchEmployees();
    setState(() {
      employees = data;
      filteredEmployees = employees.where((employee) {
        final employeeID=employee['EmployeeID'].toString().toLowerCase();
        final firstname=employee['FirstName'].toString().toLowerCase();
        final lastname=employee[ 'LastName'].toString().toLowerCase();
        final position=employee[ 'Position'].toString().toLowerCase();
        final salary=employee['Salary'].toString().toLowerCase();
        final hireDate=employee['HireDate'].toString().toLowerCase();
        final queryLower = query.toLowerCase();
        return employeeID.contains(queryLower) ||
            firstname.contains(queryLower) ||
            lastname.contains(queryLower) ||
            position.contains(queryLower) ||
            salary.contains(queryLower) ||
            hireDate.contains(queryLower);
      }).toList();
    });
  }

  Future<void> _addEmployee() async {
    final employee = {
      'EmployeeID': int.tryParse(employeeIDController.text),
      'FirstName': firstNameController.text,
      'LastName': lastNameController.text,
      'Position': positionController.text,
      'Salary': double.tryParse(salaryController.text),
      'HireDate': hireDateController.text,
    };
    await dbHelper.insertEmployee(employee);
    _clearFields();
    _fetchEmployees();
  }

  Future<void> _updateEmployee(int id) async {
    final existingEmployee =
    employees.firstWhere((employee) => employee['EmployeeID'] == id, orElse:() => {});

    if (existingEmployee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Employee with ID $id not found')),
      );
      return;
    }

    final updatedEmployee = {
      'EmployeeID': id,
      'FirstName': firstNameController.text.isNotEmpty
          ? firstNameController.text
          : existingEmployee['FirstName'],
      'LastName': lastNameController.text.isNotEmpty
          ? lastNameController.text
          : existingEmployee['LastName'],
      'Position': positionController.text.isNotEmpty
          ? positionController.text
          : existingEmployee['Position'],
      'Salary': salaryController.text.isNotEmpty
          ? double.tryParse(salaryController.text) ?? existingEmployee['Salary']
          : existingEmployee['Salary'],
      'HireDate': hireDateController.text.isNotEmpty
          ? hireDateController.text
          : existingEmployee['HireDate'],
    };

    await dbHelper.updateEmployee(id, updatedEmployee);
    _clearFields();
    _fetchEmployees();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Employee with ID $id updated successfully')),
    );
  }

  Future<void> _deleteEmployee(int id) async {
    await dbHelper.deleteEmployee(id);
    _fetchEmployees();
  }

  void _clearFields() {
    employeeIDController.clear();
    firstNameController.clear();
    lastNameController.clear();
    positionController.clear();
    salaryController.clear();
    hireDateController.clear();
  }

  void _onSearchChanged(dynamic value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchEmployees(query: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Employee Management"),
          backgroundColor: Colors.black.withOpacity(0.2),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
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
                        DataColumn(label: Text('Employee ID')),
                        DataColumn(label: Text('First Name')),
                        DataColumn(label: Text('Last Name')),
                        DataColumn(label: Text('Position')),
                        DataColumn(label: Text('Salary')),
                        DataColumn(label: Text('Hire Date')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: filteredEmployees.map((employee) {
                        return DataRow(cells: [
                          DataCell(Text(employee['EmployeeID'].toString())),
                          DataCell(Text(employee['FirstName'])),
                          DataCell(Text(employee['LastName'])),
                          DataCell(Text(employee['Position'])),
                          DataCell(Text(employee['Salary'].toString())),
                          DataCell(Text(employee['HireDate'])),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    setState(() {
                                      employeeIDController.text =
                                          employee['EmployeeID'].toString();
                                      firstNameController.text = employee['FirstName'];
                                      lastNameController.text = employee['LastName'];
                                      positionController.text = employee['Position'];
                                      salaryController.text =
                                          employee['Salary'].toString();
                                      hireDateController.text = employee['HireDate'];
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () =>
                                      _deleteEmployee(employee['EmployeeID']),
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
                    buildField('Employee ID', employeeIDController),
                    buildField('First Name', firstNameController),
                    buildField('Last Name', lastNameController),
                    buildField('Position', positionController),
                    buildField('Salary', salaryController),
                    buildField('Hire Date', hireDateController),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  buildActionButton("Add Employee", _addEmployee),
                  buildActionButton("Update Employee", () {
                    final id = int.tryParse(employeeIDController.text);
                    if (id != null) _updateEmployee(id);
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildField(String hint, TextEditingController controller) {
    return SizedBox(
      width: 150,
      child: MyTextField(
        hintText: hint,
        controller: controller,
        obscureText: false,
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget buildActionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        side: const BorderSide(color: Colors.blue),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
