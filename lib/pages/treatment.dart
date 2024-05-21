import 'package:aig/pages/auth.dart';
import 'package:aig/theme.dart';
import 'package:flutter/material.dart';

class TreatmentPage extends StatefulWidget {
  final String userId;
  const TreatmentPage({super.key, required this.userId});

  @override
  State<TreatmentPage> createState() => _TreatmentPageState();
}

class _TreatmentPageState extends State<TreatmentPage> {
  
  void _signOut() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen()),
      (Route<dynamic> route) => false,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // padding
    double screenWidth = MediaQuery.of(context).size.width;
    double paddingValue = screenWidth * 0.05;

    String userId = widget.userId;

    return Scaffold(
        backgroundColor: AppC.bgdWhite,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20.0),
            ),
            child: AppBar(
              backgroundColor: AppC.dBlue,
              title: Text(
                'AIG - Treatment',
                style: AppText.title,
              ),
              centerTitle: true,
              actions: <Widget>[
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: _signOut,
              ),
            ],
            ),
          ),
        ));
  }
}
