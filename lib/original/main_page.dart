import 'package:flutter/material.dart';
import '../API/database.dart';

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'AIG'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Database db = Database();
  final firstController = TextEditingController();
  final secondController = TextEditingController();
  final thirdController = TextEditingController();
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('First box'),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Please enter a text',
            ),
          ),
          Text('Second box'),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Please enter a text',
            ),
          ),
          Text('Third box'),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Please enter a text',
            ),
          ),
        ],
      ),
    ),
    Center(
      child: Text(
        'Farm Page',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
    Center(
      child: Text(
        'Pesticide Page',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
  ];

  @override
  void dispose() {
    firstController.dispose();
    secondController.dispose();
    thirdController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: 
      _widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //db.create_farm(firstController.text, secondController.text, thirdController.text);
        },
        tooltip: 'Submit',
        child: const Icon(Icons.add),
      ),
       bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Fertilizer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Farm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Pesticide',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
