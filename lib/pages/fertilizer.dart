import 'dart:async';

import 'package:aig/pages/auth.dart';
import 'package:aig/pages/weather_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aig/add_pages/fertilizer.dart';
import 'package:aig/display_pages/both.dart';
import 'package:aig/theme.dart';
import 'package:aig/API/database.dart';

class FertilizerPage extends StatefulWidget {
  final String userId;

  const FertilizerPage({super.key, required this.userId});

  @override
  State<FertilizerPage> createState() => _FertilizerPageState();
}

class _FertilizerPageState extends State<FertilizerPage> {
  // Database
  Database db = Database();

  // Success message from add pages
  String? _message;
  Timer? _messageClearTimer;

  bool _showButton = false;

  @override
  void dispose() {
    _messageClearTimer?.cancel();
    super.dispose();
  }

  void _toggleButton() {
    setState(() {
      _showButton = !_showButton;
    });
  }

  void _hideButtons() {
    if (_showButton) {
      setState(() {
        _showButton = false;
      });
    }
  }

  void _signOut() async {
    _hideButtons();
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

    // User ID
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
            title: Text('AIG - Fertilizer', style: AppText.title),
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
      body: GestureDetector(
        onTap: _hideButtons,
        child: Stack(
          children: [Column(
            children: [
              if (_message != null) ...[
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingValue),
                  child: Container(
                    color: AppC.gold,
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppC.green2,
                          size: 30.0,
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _message!,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                color: AppC.green2,
                                fontWeight: FontWeight.normal,
                                fontSize: 20.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              SizedBox(height: 10),
              Center(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddFertilizer(userId: userId)),
                    ).then((result) {
                      if (result != null) {
                        setState(() {
                          _message = result;
                        });
                        _messageClearTimer = Timer(Duration(seconds: 5), () {
                          if (mounted) {
                            setState(() {
                              _message = null;
                            });
                          }
                        });
                      }
                    });
                  },
                  style: AppButton.buttonStyleAdd,
                  child: Text(
                    'Add New Profile',
                    style: AppText.button,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: db.retrieve_fertilizer(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
          
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
          
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No fertilizer profiles found.'));
                      }
          
                      final profiles = snapshot.data!.docs;
          
                      return ListView.builder(
                        itemCount: profiles.length,
                        itemBuilder: (context, index) {
                          final doc = profiles[index];
                          final profile =
                              profiles[index].data() as Map<String, dynamic>;
                          profile['id'] = doc.id;
                          return ProfileCard(
                            profile: profile,
                            userId: userId,
                            onProfileTap: _hideButtons
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          if (_showButton)
              ...[
                Positioned(
                  bottom: 50,
                  left: 220,
                  child: FloatingActionButton(
                    backgroundColor: AppC.lBlurGrey,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WeatherPage(uId: widget.userId, farmId: '', selection: 1,)),
                      );
                    },
                    heroTag: 'weatherForecastButton', // Unique tag
                    tooltip: 'Weather Forecast',
                    child: Icon(Icons.cloud),
                  ),
                ),
                Positioned(
                  bottom: 100,
                  left: 285,
                  child: FloatingActionButton(
                    backgroundColor: AppC.lBlurGrey,
                    onPressed: () {
                      // Implement AI chatbot functionality here
                    },
                    heroTag: 'aiChatbotButton', 
                    tooltip: 'AI Assistant',
                    child: Icon(Icons.miscellaneous_services),
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
          ]
        ),
      ),
    );
  }

  // Control for the success create message
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final String? message =
        ModalRoute.of(context)!.settings.arguments as String?;
    if (message != null) {
      setState(() {
        _message = message;
      });

      _messageClearTimer = Timer(Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _message = null;
          });
        }
      });
    }
  }
}

class ProfileCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  final String userId;
  final VoidCallback onProfileTap;

  const ProfileCard({super.key, required this.profile, required this.userId, required this.onProfileTap});

  // Function for handling maximum characters display
  String truncateWithEllipsis(int maxLength, String text) {
    return (text.length <= maxLength)
        ? text
        : '${text.substring(0, maxLength - 3)}...';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onProfileTap();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProfileDetailPage(
                      profile: profile,
                      colName: 'fertilizer',
                      userId: userId,
                    )));
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: AppC.dGrey, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.0),
                  child: Image.network(
                    profile['Url'] ?? '',
                    height: 100,
                    width: 85,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      truncateWithEllipsis(22, profile['Name'] ?? 'No Name'),
                      style: AppText.text,
                    ),
                    Row(
                      children: [
                        Icon(
                          profile['Status'] == 1
                              ? Icons.check_circle
                              : Icons.cancel,
                          color:
                              profile['Status'] == 1 ? AppC.green1 : AppC.red,
                        ),
                        SizedBox(width: 5.0),
                        Text(
                          profile['Status'] == 1 ? 'Available' : 'Out of Stock',
                          style: profile['Status'] == 1
                              ? AppText.status2
                              : AppText.status1,
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      truncateWithEllipsis(
                          75, profile['Description'] ?? 'No Description'),
                      style: AppText.text2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
