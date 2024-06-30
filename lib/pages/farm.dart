//checkpoint
// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:aig/API/database.dart';
import 'package:aig/add_pages/farm.dart';
import 'package:aig/display_pages/farm.dart';
import 'package:aig/pages/auth.dart';
import 'package:aig/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aig/main.dart';

// ignore: must_be_immutable
class FarmPage extends StatefulWidget {
  final String userId;
  final ValueNotifier<bool> isAdd;

  const FarmPage({super.key, required this.userId, required this.isAdd});

  @override
  State<FarmPage> createState() => _FarmPageState();
}

class _FarmPageState extends State<FarmPage> {
  final Database db = Database();

  // Success message from add pages
  String? _message;
  Timer? _messageClearTimer;

  @override
  void initState() {
    super.initState();
    widget.isAdd.addListener(_checkAdd);
  }

  @override
  void dispose() {
    _messageClearTimer?.cancel();
    widget.isAdd.removeListener(_checkAdd);
    super.dispose();
  }

  void _checkAdd() {
    if (widget.isAdd.value) {
      _navigateToAddFarm();
      widget.isAdd.value = false;  // Reset after handling
    }
  }

  void _hideButtons() {
    HomePageState? homePageState =
        context.findAncestorStateOfType<HomePageState>();
    homePageState?.hideButtons();
  }

  void _signOut() async {
    _hideButtons();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _navigateToAddFarm() async {
    _hideButtons();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddFarm(userId: widget.userId)),
    );
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
  }

  @override
  Widget build(BuildContext context) {
    // padding
    double screenWidth = MediaQuery.of(context).size.width;
    double paddingValue = screenWidth * 0.05;

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
            title: Text('AIG - Farm', style: AppText.title),
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
          children: [
            Column(
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
                    onPressed: _navigateToAddFarm,
                    style: AppButton.buttonStyleAdd,
                    child: Text('Add New Profile', style: AppText.button),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: db.retrieve_farm(widget.userId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No farm profiles found.'));
                        }

                        final profiles = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: profiles.length,
                          itemBuilder: (context, index) {
                            final doc = profiles[index];
                            final profile = doc.data() as Map<String, dynamic>;
                            profile['id'] = doc.id;
                            return ProfileCard(
                                profile: profile,
                                userId: widget.userId,
                                onProfileTap: _hideButtons);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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

  const ProfileCard({
    super.key,
    required this.profile,
    required this.userId,
    required this.onProfileTap,
  });

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
            builder: (context) => FarmProfileDetailPage(
              profile: profile,
              colName: 'farm',
              userId: userId,
            ),
          ),
        );
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
                  borderRadius: BorderRadius.circular(8.0),
                ),
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
                          profile['Status'] == 1 ? Icons.eco : Icons.warning,
                          color:
                              profile['Status'] == 1 ? AppC.green1 : AppC.red,
                        ),
                        SizedBox(width: 5.0),
                        Text(
                          profile['Status'] == 1 ? 'Healthy' : 'Disease',
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
