// Old version checkpoint
// ignore_for_file: avoid_print

import 'package:aig/bot/chatbot.dart';
import 'package:aig/pages/weather_page.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'pages/auth.dart';
import 'pages/disease.dart';
import 'pages/farm.dart';
import 'pages/fertilizer.dart';
import 'pages/pesticide.dart';
import 'package:firebase_core/firebase_core.dart';
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
      initialRoute: '/',
      routes: {
        '/': (context) => AuthScreen(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final String userId;
  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _showButton = false;
  final ValueNotifier<bool> _isAdd = ValueNotifier<bool>(false);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isAdd.value = false;
    });
    hideButtons();
  }

  void _toggleButton() {
    setState(() {
      _showButton = !_showButton;
    });
  }

  void hideButtons() {
    if (_showButton) {
      setState(() {
        _showButton = false;
      });
    }
  }

  void _handleStatus(int status) {
    final newIndex = status - 1;

    setState(() {
      _selectedIndex = newIndex;
      _isAdd.value = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isAdd.value = true;
    });
  }

    @override
  void dispose() {
    _isAdd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String userId = widget.userId;

    final List<Widget> widgetOptions = <Widget>[
      FarmPage(userId: userId, isAdd: _isAdd,),
      FertilizerPage(userId: userId, isAdd: _isAdd),
      PesticidePage(userId: userId, isAdd: _isAdd),
      DiseaseDetails(userId: userId),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: widgetOptions.elementAt(_selectedIndex),
          ),
          if (_showButton) ...[
            Positioned(
              bottom: 50,
              left: 220,
              child: FloatingActionButton(
                backgroundColor: AppC.lBlurGrey,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeatherPage(
                        uId: userId,
                        farmId: '',
                        selection: 1,
                      ),
                    ),
                  );
                },
                heroTag: 'weatherForecastButton',
                tooltip: 'Weather Forecast',
                child: Icon(Icons.cloud),
              ),
            ),
            Positioned(
              bottom: 100,
              left: 285,
              child: FloatingActionButton(
                backgroundColor: AppC.lBlurGrey,
                onPressed: () async {
                  final status = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ChatbotDialog(userId: userId);
                    },
                  );
                  if (status != null && status != 0) {
                    _handleStatus(status);
                  }
                },
                heroTag: 'aiChatbotButton',
                tooltip: 'AI Assistant',
                child: Icon(Icons.engineering_rounded),
              ),
            ),
          ],
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                onPressed: _toggleButton,
                shape: CircleBorder(),
                backgroundColor: _showButton ? AppC.white : AppC.lBlurGrey,
                child: Icon(
                  _showButton ? Icons.close : Icons.lightbulb_outline,
                ),
              ),
            ),
          ),
        ],
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
              label: 'Disease',
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
