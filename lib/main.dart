import 'package:flutter/material.dart';
import 'DashboardPage.dart';
import 'LoginPage.dart';
import 'SessionManager.dart';
import 'db_helper.dart'; // Import the DBHelper class

void main() {
  runApp(const CarShopApp());
}

class CarShopApp extends StatelessWidget {
  const CarShopApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Shop Management System',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();
  final DBHelper dbHelper = DBHelper(); // Instance of DBHelper
  List<Map<String, dynamic>> filteredCars = []; // Stores filtered cars
  bool isSearching = false; // Tracks whether the user is searching

  Future<void> searchCar(String query) async {
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        filteredCars = [];
      });
      return;
    }

    // Fetch all cars from the database and filter based on the query
    final cars = await dbHelper.fetchCars();
    setState(() {
      isSearching = true;
      filteredCars = cars.where((car) {
        final make = car['Make'].toString().toLowerCase();
        final model = car['Model'].toString().toLowerCase();
        return make.contains(query.toLowerCase()) || model.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
        title: const Text('Car Shop Management System'),
        actions: [
          TextButton(
            onPressed: () {
              bool isLoggedIn = SessionManager.isLoggedIn();
              if (isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DashboardPage()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              }
            },
            child: Text(
              SessionManager.isLoggedIn() ? 'Dashboard' : 'Login',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isLargeScreen = constraints.maxWidth > 600;
          return Stack(
            children: [
              Container(
                width: screenWidth,
                height: screenHeight,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/hbg.jpg'),
                    fit: BoxFit.fill,
                    alignment: Alignment.center,
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 55),
                        child: Text(
                          'Search',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isLargeScreen ? constraints.maxWidth * 0.2 : 20,
                        ),
                        child: TextField(
                          controller: searchController,
                          onChanged: searchCar, // Trigger search logic on text input
                          decoration: const InputDecoration(
                            labelText: 'Search Cars',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),

                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Show search results only when searching
                      if (isSearching && filteredCars.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredCars.length,
                          itemBuilder: (context, index) {
                            final car = filteredCars[index];
                            return ListTile(
                              title: Text(
                                '${car['Make']} ${car['Model']}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'Year: ${car['Year']} | Price: \$${car['Price']}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      if (isSearching && filteredCars.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            'No cars found.',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
