// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:aig/API/disease_recognition.dart';
import 'package:aig/display_pages/history.dart';
import 'package:aig/update_pages/farm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aig/theme.dart';
import 'package:aig/API/database.dart';

class FarmProfileDetailPage extends StatefulWidget {
  final Map<String, dynamic> profile;
  final String colName;
  final String userId;

  const FarmProfileDetailPage({
    super.key,
    required this.profile,
    required this.colName,
    required this.userId,
  });

  @override
  State<FarmProfileDetailPage> createState() => _FarmProfileDetailPageState();
}

class _FarmProfileDetailPageState extends State<FarmProfileDetailPage> {
  Database db = Database();
  // Success message from update pages
  String? _message;

  // Current profile data
  late Map<String, dynamic> profile;
  Map<String, dynamic> fertilizers = {};
  Map<String, dynamic> pesticides = {};
  String? _model;
  String? plant;

  // Loading
  bool isLoading = false;

  // Dropdown Memu
  bool _isManage = false;
  bool _isDDS = false;
  bool _isDH = false;
  bool _isAH = false;

  void _toggleManage() {
    setState(() {
      _isManage = !_isManage;
    });
  }

  void _toggleDDS() {
    setState(() {
      _isDDS = !_isDDS;
    });
  }

  void _toggleDH() {
    setState(() {
      _isDH = !_isDH;
    });
  }

  void _toggleAH() {
    setState(() {
      _isAH = !_isAH;
    });
  }

  @override
  void initState() {
    super.initState();
    profile = widget.profile;
    fetchFerPest();
    fetchModel();
  }

  Future<void> fetchFerPest() async {
    setState(() {
      isLoading = true;
    });

    fertilizers =
        await db.retrieve_pest_fer(profile['id'], widget.userId, 'Fertilizer');

    pesticides =
        await db.retrieve_pest_fer(profile['id'], widget.userId, 'Pesticide');

    setState(() {
      isLoading = false;
    });
  }

  void fetchModel() {
    final int model = profile['Model'];

    setState(() {
      if (model == 1) {
        _model = 'Potato Model';
        plant = 'Potato';
      } else if (model == 2) {
        _model = 'Strawberry Model';
        plant = 'Strawberry';
      } else if (model == 3) {
        _model = 'Tomato Model';
        plant = 'Tomato';
      }
    });
  }

  Widget buildDiseaseHistory(String historyType) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: db.retrieveHistory(widget.userId, profile['id'], historyType),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text(
              'No history available',
              style: AppText.text2,
            ));
          }
          final historyList = snapshot.data!;
          return ListView.builder(
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final history = historyList[index];
              return ListTile(
                title: Text(
                  '${history['Date']} - ${history['Disease Name']}',
                  style: AppText.text,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiseaseHistory(history: history),
                    ),
                  );
                },
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // padding
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double paddingWidth = screenWidth * 0.05;
    double paddingHeight = screenHeight * 0.05;

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
            title: Text('Profile Details', style: AppText.title),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                if (_message != null) ...[
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: paddingWidth),
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
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: paddingWidth,
                    vertical: paddingHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            profile['Url'] ?? '',
                            height: 200,
                            width: 165.2,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      InkWell(
                        onTap: _toggleManage,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            color: AppC.purple,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Manage Profile',
                                  style: AppText.text,
                                ),
                                Icon(
                                  _isManage
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down,
                                  color: AppC.dPurple,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_isManage)
                        Container(
                          width: 350,
                          color: AppC.lPurple,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: OutlinedButton(
                                  style: AppButton.buttonStyleFarm,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UpdateFarmProfilePage(
                                          colName: widget.colName,
                                          docId: profile['id'],
                                          userId: widget.userId,
                                        ),
                                      ),
                                    ).then((result) {
                                      if (result != null) {
                                        setState(() {
                                          _message = result;
                                        });
                                        refreshData();
                                        Future.delayed(Duration(seconds: 5),
                                            () {
                                          if (mounted) {
                                            setState(() {
                                              _message = null;
                                            });
                                          }
                                        });
                                      }
                                    });
                                  },
                                  child: Text(
                                    'Update Profile',
                                    style: AppText.title2,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: OutlinedButton(
                                  style: AppButton.buttonStyleFarm,
                                  onPressed: () {
                                    deleteConfirmation(context);
                                  },
                                  child: Text(
                                    'Delete Profile',
                                    style: AppText.title2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 30),
                      InkWell(
                        onTap: _toggleDDS,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            color: AppC.purple,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Decision Support Features',
                                    style: AppText.text),
                                Icon(
                                  _isDDS
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down,
                                  color: AppC.dPurple,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_isDDS)
                        Container(
                          width: 350,
                          color: AppC.lPurple,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: OutlinedButton(
                                  style: AppButton.buttonStyleFarm,
                                  onPressed: () {},
                                  child: Text(
                                    'Farm Navigation',
                                    style: AppText.title2,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: OutlinedButton(
                                  style: AppButton.buttonStyleFarm,
                                  onPressed: () {},
                                  child: Text(
                                    'Weather Forecast',
                                    style: AppText.title2,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: OutlinedButton(
                                  style: AppButton.buttonStyleFarm,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DiseaseRecognition(
                                                uId: widget.userId,
                                                farmId: profile['id'],
                                                modelId: profile['Model'],
                                                plant: plant!),
                                      ),
                                    ).then((result) {
                                      if (result != null) {
                                        setState(() {
                                          _message = result;
                                        });
                                        refreshData();
                                        Future.delayed(Duration(seconds: 10),
                                            () {
                                          if (mounted) {
                                            setState(() {
                                              _message = null;
                                            });
                                          }
                                        });
                                      }
                                    });
                                  },
                                  child: Text(
                                    'Disease Recognition',
                                    style: AppText.title2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 30),
                      InkWell(
                        onTap: _toggleDH,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            color: AppC.purple,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Disease Recognition History',
                                    style: AppText.text),
                                Icon(
                                  _isDH
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down,
                                  color: AppC.dPurple,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_isDH)
                        Container(
                            constraints: AppBoxDecoration.boxConstraints2,
                            color: AppC.lPurple,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: buildDiseaseHistory('Disease History')),
                      SizedBox(height: 30),
                      InkWell(
                        onTap: _toggleAH,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            color: AppC.purple,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('AI History', style: AppText.text),
                                Icon(
                                  _isAH
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down,
                                  color: AppC.dPurple,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_isAH)
                        Container(
                            constraints: AppBoxDecoration.boxConstraints2,
                            color: AppC.lPurple,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: buildDiseaseHistory('AI History')),
                      SizedBox(height: 30),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: paddingWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name', style: AppText.title2),
                            SizedBox(height: 10),
                            Container(
                              height: 50,
                              width: 300,
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              decoration: AppBoxDecoration.box,
                              child: Text(
                                profile['Name'] ?? 'No Name',
                                style: AppText.text,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text('Description', style: AppText.title2),
                            SizedBox(height: 10),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              constraints: AppBoxDecoration.boxConstraints,
                              decoration: AppBoxDecoration.box,
                              child: SingleChildScrollView(
                                child: Text(
                                  profile['Description'] ?? 'No Description',
                                  style: AppText.text,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Text('Address', style: AppText.title2),
                            SizedBox(height: 10),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              constraints: AppBoxDecoration.boxConstraints,
                              decoration: AppBoxDecoration.box,
                              child: SingleChildScrollView(
                                child: Text(
                                  profile['Address'] ?? 'No Address',
                                  style: AppText.text,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Text('Farm Status', style: AppText.title2),
                            SizedBox(height: 10),
                            Container(
                              height: 50,
                              width: 300,
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              decoration: AppBoxDecoration.box,
                              child: Row(
                                children: [
                                  Icon(
                                    profile['Status'] == 1
                                        ? Icons.eco
                                        : Icons.warning,
                                    color: profile['Status'] == 1
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  SizedBox(width: 5.0),
                                  Text(
                                    profile['Status'] == 1
                                        ? 'Healthy'
                                        : 'Disease',
                                    style: profile['Status'] == 1
                                        ? AppText.status2
                                        : AppText.status1,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            Text('Disease Recognition Model',
                                style: AppText.title2),
                            SizedBox(height: 10),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              constraints: AppBoxDecoration.boxConstraints,
                              decoration: AppBoxDecoration.box,
                              child: Text(
                                _model!,
                                style: AppText.text,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text('Fertilizer Application Amount',
                                style: AppText.title2),
                            SizedBox(height: 10),
                            Container(
                              height: 200,
                              width: 300,
                              decoration: AppBoxDecoration.box,
                              padding: EdgeInsets.all(8.0),
                              child: fertilizers.isEmpty
                                  ? Center(
                                      child: Text('No Available Fertilizer',
                                          style: AppText.text))
                                  : SingleChildScrollView(
                                      child: Column(
                                        children: fertilizers.keys.map((id) {
                                          final fertilizer = fertilizers[id];
                                          return Column(
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5.0,
                                                        horizontal: 10),
                                                decoration:
                                                    AppBoxDecoration.box2,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                        fertilizer['Name'] ??
                                                            'Unknown',
                                                        style: AppText.text),
                                                    Spacer(),
                                                    IconButton(
                                                      icon: Icon(Icons.remove),
                                                      onPressed: () {
                                                        setState(() {
                                                          if (fertilizer[
                                                                  'amount'] >
                                                              0) {
                                                            fertilizer[
                                                                'amount']--;
                                                            updateAmount(
                                                                id,
                                                                fertilizer[
                                                                    'amount'],
                                                                'Fertilizer');
                                                          }
                                                        });
                                                      },
                                                    ),
                                                    Text(
                                                        fertilizer['amount']
                                                            .toString(),
                                                        style: AppText.text),
                                                    IconButton(
                                                      icon: Icon(Icons.add),
                                                      onPressed: () {
                                                        setState(() {
                                                          fertilizer[
                                                              'amount']++;
                                                          updateAmount(
                                                              id,
                                                              fertilizer[
                                                                  'amount'],
                                                              'Fertilizer');
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                            ),
                            SizedBox(height: 20),
                            Text('Pesticide Application Amount',
                                style: AppText.title2),
                            SizedBox(height: 10),
                            Container(
                              height: 200,
                              width: 300,
                              decoration: AppBoxDecoration.box,
                              padding: EdgeInsets.all(8.0),
                              child: pesticides.isEmpty
                                  ? Center(
                                      child: Text('No Available Pesticide',
                                          style: AppText.text))
                                  : SingleChildScrollView(
                                      child: Column(
                                        children: pesticides.keys.map((id) {
                                          final pesticide = pesticides[id];
                                          return Column(
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5.0,
                                                        horizontal: 10),
                                                decoration:
                                                    AppBoxDecoration.box2,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                        pesticide['Name'] ??
                                                            'Unknown',
                                                        style: AppText.text),
                                                    Spacer(),
                                                    IconButton(
                                                      icon: Icon(Icons.remove),
                                                      onPressed: () {
                                                        setState(() {
                                                          if (pesticide[
                                                                  'amount'] >
                                                              0) {
                                                            pesticide[
                                                                'amount']--;
                                                            updateAmount(
                                                                id,
                                                                pesticide[
                                                                    'amount'],
                                                                'Pesticide');
                                                          }
                                                        });
                                                      },
                                                    ),
                                                    Text(
                                                        pesticide['amount']
                                                            .toString(),
                                                        style: AppText.text),
                                                    IconButton(
                                                      icon: Icon(Icons.add),
                                                      onPressed: () {
                                                        setState(() {
                                                          pesticide['amount']++;
                                                          updateAmount(
                                                              id,
                                                              pesticide[
                                                                  'amount'],
                                                              'Pesticide');
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  void deleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this profile?'),
          actions: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Dismiss the dialog
                  },
                  child: Text('Cancel'),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    _deleteProfile(context);
                  },
                  child: Text('Confirm'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _deleteProfile(BuildContext context) async {
    final Database db = Database();
    await db.delete(widget.colName, profile['id'], widget.userId);
    Navigator.of(context).pop(); // Dismiss the confirmation dialog
    Navigator.of(context).pop(); // Go back to the previous page
  }

  Future<void> refreshData() async {
    final Database db = Database();
    DocumentSnapshot profileSnapshot =
        await db.retrieve_update(widget.colName, profile['id'], widget.userId);
    if (mounted) {
      setState(() {
        profile = {
          ...profileSnapshot.data() as Map<String, dynamic>,
          'id': profile['id']
        };
      });
      fetchFerPest();
      fetchModel();
    }
  }

  Future<void> updateAmount(String id, int amount, String name) async {
    final Database db = Database();
    await db.update_amount(profile['id'], id, name, amount, widget.userId);
  }
}
