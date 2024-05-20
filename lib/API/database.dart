// ignore_for_file: non_constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  Future<void> create_fertilizer(
      String name, String description, String url, int status) async {
    final col = FirebaseFirestore.instance.collection('fertilizer');
    final data = <String, dynamic>{
      "Name": name,
      "Description": description,
      'Url': url,
      'Status': status
    };

    await col.add(data);
  }

  Future<void> create_pesticide(
      String name, String description, String url, int status) async {
    final col = FirebaseFirestore.instance.collection('pesticide');
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
    }) async {

    final col = FirebaseFirestore.instance.collection('farm');
    final data = <String, dynamic>{
      "Name": name,
      "Description": description,
      'Address': address,
      'Url': url,
      'Status': status,
      'Model': model,
      'Fertilizer': { for (var e in fertilizer) e : {'amount': 0} },
      'Pestcide': { for (var e in pesticide) e : {'amount': 0} },
    };

    await col.add(data);
  }

  Stream<QuerySnapshot> retrieve_fertilizer() {
    final col = FirebaseFirestore.instance.collection('fertilizer');
    return col.snapshots();
  }

  Stream<QuerySnapshot> retrieve_pesticide() {
    final col = FirebaseFirestore.instance.collection('pesticide');
    return col.snapshots();
  }

  Stream<QuerySnapshot> retrieve_farm() {
    final col = FirebaseFirestore.instance.collection('farm');
    return col.snapshots();
  }

  //retrieve operations for Update operations
  Future<DocumentSnapshot> retrieve_update(String colName, String docId) async {
    return await FirebaseFirestore.instance.collection(colName).doc(docId).get();
  }

  //delete operations for pesticide, fertilizer and farm
  Future<void> delete(String colName, String docId) async {
    final col = FirebaseFirestore.instance.collection(colName).doc(docId);
    await col.delete();
  }

  //update operation for pesticide, fertilizer and farm
  Future<void> update(String colName, String docId, Map <String, dynamic> data) async {
    final col = FirebaseFirestore.instance.collection(colName).doc(docId);
    await col.update(data);
  }
}
