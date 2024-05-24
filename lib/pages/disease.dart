import 'package:aig/API/database.dart';
import 'package:aig/display_pages/disease.dart';
import 'package:aig/pages/auth.dart';
import 'package:aig/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Dropdown Memu
  bool _isPotato = false;
  bool _isStrawberry = false;
  bool _isTomato = false;

  @override
  void initState() {
    super.initState();
  }

  void _togglePotato() {
    setState(() {
      _isPotato = !_isPotato;
    });
  }

  void _toggleTomato() {
    setState(() {
      _isTomato = !_isTomato;
    });
  }

  void _toggleStrawberry() {
    setState(() {
      _isStrawberry = !_isStrawberry;
    });
  }

  void _signOut() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _navigateToDiseaseDetail(
      Map<String, dynamic> profile, String uId, String diseaseName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiseaseDetailPage(
          profile: profile,
          userId: uId,
          diseaseName: diseaseName,
        ),
      ),
    );
  }

  //diseaseName is the docId
  Widget _buildDiseaseButton(Map<String, dynamic> profile, String diseaseName,
      String uId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: OutlinedButton(
        style: AppButton.buttonStyleDisease,
        onPressed: () => _navigateToDiseaseDetail(profile, uId, diseaseName),
        child: Text(
          diseaseName,
          style: AppText.title2,
        ),
      ),
    );
  }

  Widget _buildDiseaseList(String diseaseType, String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: db.retrieve_treatment(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> documents = snapshot.data!.docs;
        if (documents.isEmpty) {
          return Center(
              child: Text(
            'No disease found',
            style: AppText.text2,
          ));
        }

        DocumentSnapshot diseaseDocument;
        try {
          diseaseDocument =
              documents.firstWhere((doc) => doc.id == diseaseType);
        } catch (e) {
          return Center(
              child: Text(
            'No $diseaseType disease found',
            style: AppText.text2,
          ));
        }

        final diseases = diseaseDocument.data() as Map<String, dynamic>;
        final diseaseNames = diseases.keys.toList();
        diseases['id'] = diseaseType;

        return Column(
          children: diseaseNames
              .map((name) =>
                  _buildDiseaseButton(diseases, name, userId))
              .toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // padding
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double paddingHeight = screenHeight * 0.05;
    double paddingWidth = screenWidth * 0.08;

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
              'AIG - Disease',
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
          padding: EdgeInsets.symmetric(
            vertical: paddingHeight,
            horizontal: paddingWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('*Click to edit disease details*', style: AppText.text2,),
              InkWell(
                onTap: _togglePotato,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    height: 70,
                    color: AppC.blurGrey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Potato Disease', style: AppText.text),
                        Icon(
                          _isPotato
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: AppC.dBlurGrey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isPotato)
                Container(
                  color: AppC.lBlurGrey,
                  constraints: AppBoxDecoration.boxConstraints2,
                  child: SingleChildScrollView(
                      child: _buildDiseaseList('Potato', userId)),
                ),
              SizedBox(height: 30),
              InkWell(
                onTap: _toggleTomato,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    height: 70,
                    color: AppC.blurGrey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tomato Disease', style: AppText.text),
                        Icon(
                          _isPotato
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: AppC.dBlurGrey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isTomato)
                Container(
                  color: AppC.lBlurGrey,
                  constraints: AppBoxDecoration.boxConstraints2,
                  child: SingleChildScrollView(
                      child: _buildDiseaseList('Tomato', userId)),
                ),
              SizedBox(height: 30),
              InkWell(
                onTap: _toggleStrawberry,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    height: 70,
                    color: AppC.blurGrey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Strawaberry Disease', style: AppText.text),
                        Icon(
                          _isPotato
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: AppC.dBlurGrey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isStrawberry)
                Container(
                  color: AppC.lBlurGrey,
                  constraints: AppBoxDecoration.boxConstraints2,
                  child: SingleChildScrollView(
                      child: _buildDiseaseList('Strawberry', userId)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
