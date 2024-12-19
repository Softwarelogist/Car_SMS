import 'package:flutter/material.dart';
import 'NavBar.dart';
import 'Management/CarManagement.dart';
import 'Management/ServicesManagement.dart';
import 'Management/CustomerManagement.dart';
import 'Management/PaymentManagement.dart';
import 'Management/OrderManagement.dart';
import 'Management/EmployeeManagement.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedPage = 'Dashboard';

  Widget currentPage = Center(
    child: Text(
      'Welcome to the Dashboard!',
      style: const TextStyle(
        fontSize: 24,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  void updatePage(String page) {
    setState(() {
      selectedPage = page;
      switch (page) {
        case 'Cars':
          currentPage = CarManagement();
        case 'Customers':
          currentPage = CustomerManagement();
          break;
       case 'Services':
          currentPage = ServicesManagement();
          break;
       case 'Employees':
          currentPage = EmployeeManagement();
          break;
        case 'Orders':
          currentPage = OrderManagement();
          break;
        case 'Payment':
          currentPage = PaymentManagement();
          break;

        default:
          currentPage = Center(
            child: Text(
              'Welcome to the $page!',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(selectedPage),
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
      ),
      drawer: NavBar(
        onItemSelected: updatePage,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          image: const DecorationImage(
            image: AssetImage('assets/images/mainbg.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black54,
              BlendMode.darken,
            ),
          ),
        ),
        child: currentPage,
      ),
    );
  }
}
