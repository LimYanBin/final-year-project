import 'package:aig/API/database.dart';
import 'package:aig/Treatment/content.dart';
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
  // Database
  Database db = Database();

  

  @override
  void initState() {
    super.initState();
  }

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
    double screenHeight = MediaQuery.of(context).size.height;
    double paddingWidth = screenWidth * 0.1;
    double paddingHeight = screenHeight * 0.08;

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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingWidth,vertical: paddingHeight,),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date', style: AppText.title2,),
              SizedBox(height: 10,),
              //Text(treatments['Description'], style: AppText.treatment,textAlign: TextAlign.justify,),
              SizedBox(height: 10,),
              //Text(treatments['Reason'], style: AppText.treatment, textAlign: TextAlign.justify),
              SizedBox(height: 10,),
              //Text(treatments['Treatment'], style: AppText.treatment, textAlign: TextAlign.left),
            ],
          ),
        ),
      ),
    );
  }
}
