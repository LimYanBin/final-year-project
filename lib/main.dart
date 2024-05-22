import 'package:aig/pages/auth.dart';
import 'package:aig/pages/farm.dart';
import 'package:aig/pages/loading.dart';
import 'package:aig/pages/treatment.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
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
      initialRoute: '/loading',
      routes: {
        '/': (context) => AuthScreen(),
        '/loading': (context) => LoadingPage(userId: '4KEoqXQquLzvrG04kyLx'),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final String userId;
  const HomePage({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String userId = widget.userId;

    final List<Widget> widgetOptions = <Widget>[
      FarmPage(userId: userId),
      FertilizerPage(userId: userId),
      PesticidePage(userId: userId),
      TreatmentPage(userId: userId),
    ];

    return Scaffold(
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Farm',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grass),
              label: 'Fertilizer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bug_report),
              label: 'Pesticide',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: 'Treatment',
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
