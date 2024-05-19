import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/farm.dart';
import 'pages/fertilizer.dart';
import 'pages/pesticide.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agri Intelligence Guardian',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  static final List<Widget> _widgetOptions = <Widget>[
    FertilizerPage(),
    FarmPage(),
    PesticidePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.grass),
              label: 'Fertilizer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Farm',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bug_report),
              label: 'Pesticide',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppC.green1,
          unselectedItemColor: AppC.black,
          onTap: _onItemTapped,
          backgroundColor: AppC.dBlue,
        ),
      ),
    );
  }
}
