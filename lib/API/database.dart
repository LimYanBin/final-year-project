// ignore_for_file: non_constant_identifier_names, unnecessary_null_comparison
import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  final ref = FirebaseFirestore.instance.collection('users');

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

  Future<void> create_pesticide(
      String name, String description, String url, int status, String uId) async {
    final col = ref.doc(uId).collection('pesticide');
    final data = <String, dynamic>{
      "Name": name,
      "Description": description,
      'Url': url,
      'Status': status
    };

    await col.add(data);
  }

  Future<void> create_farm({
    required String name,
    required String description,
    required String address,
    required String url,
    required int status,
    required int model,
    required List<String> fertilizer,
    required List<String> pesticide,
    required String uId
  }) async {
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
      'Pestcide': {
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

  //retrieve operations for Update operations
  Future<DocumentSnapshot> retrieve_update(String colName, String docId, String uId) async {
    return await ref.doc(uId)
        .collection(colName)
        .doc(docId)
        .get();
  }

  //delete operations for pesticide, fertilizer and farm
  Future<void> delete(String colName, String docId, String uId) async {
    final col = ref.doc(uId).collection(colName).doc(docId);
    await col.delete();
  }

  //update operation for pesticide, fertilizer and farm
  Future<void> update(
      String colName, String docId, Map<String, dynamic> data, String uId) async {
    final col = ref.doc(uId).collection(colName).doc(docId);
    await col.update(data);
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

    await ref.add(data);
    return true;
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
}
