// ignore_for_file: non_constant_identifier_names, avoid_print

import 'package:aig/Treatment/content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  final ref = FirebaseFirestore.instance.collection('users');
  final tre = FirebaseFirestore.instance.collection('treatment');
  TreatmentRecommendation tr = TreatmentRecommendation();

  Future<void> create_fertilizer(String name, String description, String url,
      int status, String uId) async {
    final col = ref.doc(uId).collection('fertilizer');
    final data = <String, dynamic>{
      "Name": name,
      "Description": description,
      'Url': url,
      'Status': status
    };

    await col.add(data);
  }

  Future<void> create_pesticide(String name, String description, String url,
      int status, String uId) async {
    final col = ref.doc(uId).collection('pesticide');
    final data = <String, dynamic>{
      "Name": name,
      "Description": description,
      'Url': url,
      'Status': status
    };

    await col.add(data);
  }

  Future<void> create_farm(
      {required String name,
      required String description,
      required String address,
      required String url,
      required int status,
      required int model,
      required List<String> fertilizer,
      required List<String> pesticide,
      required String uId}) async {
    final col = ref.doc(uId).collection('farm');
    final data = <String, dynamic>{
      "Name": name,
      "Description": description,
      'Address': address,
      'Url': url,
      'Status': status,
      'Model': model,
      'Fertilizer': {
        for (var e in fertilizer) e: {'amount': 0}
      },
      'Pesticide': {
        for (var e in pesticide) e: {'amount': 0}
      },
    };

    await col.add(data);
  }

  Stream<QuerySnapshot> retrieve_fertilizer(String uId) {
    final col = ref.doc(uId).collection('fertilizer');
    return col.snapshots();
  }

  Stream<QuerySnapshot> retrieve_pesticide(String uId) {
    final col = ref.doc(uId).collection('pesticide');
    return col.snapshots();
  }

  Stream<QuerySnapshot> retrieve_farm(String uId) {
    final col = ref.doc(uId).collection('farm');
    return col.snapshots();
  }

  Stream<QuerySnapshot> retrieve_treatment(String uId) {
    final col = ref.doc(uId).collection('treatment');
    return col.snapshots();
  }

  //retrieve operations for Update operations
  Future<DocumentSnapshot> retrieve_update(
      String colName, String docId, String uId) async {
    return await ref.doc(uId).collection(colName).doc(docId).get();
  }

  //delete operations for pesticide, fertilizer and farm
  Future<void> delete(String colName, String docId, String uId) async {
    final col = ref.doc(uId).collection(colName).doc(docId);
    await col.delete();
  }

  //update operation for pesticide, fertilizer and farm
  Future<void> update(String colName, String docId, Map<String, dynamic> data,
      String uId) async {
    final col = ref.doc(uId).collection(colName).doc(docId);
    await col.update(data);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> retrieve_disease(String uId, String docId) {
    return ref.doc(uId).collection('treatment').doc(docId).get();
  }

  //update operation for disease
  Future<void> updateDisease(Map<String, dynamic> data, String uId, String docId) async {
        await ref.doc(uId).collection('treatment').doc(docId).update(data);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> reset_disease(String docId) async{
    return tre.doc(docId).get();
  }

  //authentication
  Future<bool> registerUser(String username, String password) async {
    var result = await ref.where('username', isEqualTo: username).get();

    if (result.docs.isNotEmpty) {
      return false;
    }

    final data = <String, dynamic>{
      "username": username,
      "password": password,
    };

    var docRef = await ref.add(data);

    await storeTreatment(docRef.id);

    return true;
  }

  Future<void> storeTreatment(String userId) async {
    final potatoRecommendations = {
      'Early Blight': tr.potato(1),
      'Late Blight': tr.potato(2),
    };

    final strawberryRecommendations = {
      'Leaf Scorch': tr.strawberry(1),
    };

    final tomatoRecommendations = {
      'Bacterial Spot': tr.tomato(1),
      'Early Blight': tr.tomato(2),
      'Late Blight': tr.tomato(3),
      'Yellow Leaf Curl Virus': tr.tomato(4),
    };

    final treatmentRef = ref.doc(userId).collection('treatment');

    await treatmentRef.doc('Potato').set(potatoRecommendations);
    await treatmentRef.doc('Strawberry').set(strawberryRecommendations);
    await treatmentRef.doc('Tomato').set(tomatoRecommendations);
  }

  // Login user
  Future<String> loginUser(String username, String password) async {
    var result = await ref
        .where('username', isEqualTo: username)
        .where('password', isEqualTo: password)
        .get();
    if (result.docs.isEmpty) {
      return '';
    }
    return result.docs.first.id;
  }

  // Retrieve fertilizers and pesticide for a specific farm
  Future<Map<String, dynamic>> retrieve_pest_fer(
      String farmId, String uId, String col) async {
    final farmDoc = await ref.doc(uId).collection('farm').doc(farmId).get();
    if (!farmDoc.exists) {
      return {};
    }

    final farmData = farmDoc.data();
    if (farmData == null) {
      return {};
    }

    final String name = col.toLowerCase();
    final result = farmData[col] as Map<String, dynamic>?;
    if (result == null) {
      return {};
    }
    final validResult = <String, dynamic>{};

    for (var resultId in result.keys) {
      final resultDoc = await ref.doc(uId).collection(name).doc(resultId).get();
      if (resultDoc.exists) {
        validResult[resultId] = {
          'amount': result[resultId]['amount'],
          'Name': resultDoc.data()!['Name']
        };
      } else {
        // Remove invalid ID from farm collection
        await ref.doc(uId).collection('farm').doc(farmId).update({
          '$col.$resultId': FieldValue.delete(),
        });
      }
    }

    return validResult;
  }

  // Update fertilizer and pesticide amount for a specific farm
  Future<void> update_amount(
      String farmId, String id, String col, int amount, String userId) async {
    final farmDoc = ref.doc(userId).collection('farm').doc(farmId);
    await farmDoc.update({
      '$col.$id.amount': amount,
    });
  }

  Future<void> storeHistory(String uId, String plantName, String diseaseName, String farmId, String date, Map<String, dynamic> data, String history_type) async {
    try {
      await ref.doc(uId).collection('farm').doc(farmId).collection(history_type).add({
        'Plant': plantName,
        'Disease Name': diseaseName,
        'Data': data,
        'Date': date,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Failed to store history: $e");
    }
  }

  Future<List<Map<String, dynamic>>> retrieveHistory(String uId, String farmId, String history_type) async {
  try {
    QuerySnapshot querySnapshot = await ref.doc(uId).collection('farm').doc(farmId)
        .collection(history_type)
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  } catch (e) {
    print("Failed to retrieve history: $e");
    return [];
  }
}
}
