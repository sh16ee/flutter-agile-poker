import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUsers {

  Future<void> clearUsers() async {
    var users = await FirebaseFirestore.instance.collection('users').get();
    if (users.docs.isNotEmpty) {
      users.docs.forEach((doc) async {
        await doc.reference
                  .delete()
                  .then((value) => print("User deleted"))
                  .catchError((error) => print("Failed to delete user: $error"));
      });
    }
  }

  Future<void> addUser(String name) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return users
        .add({ 
          'name': name,
          'role': 'voter',
          'voted_tasks': []
        })
        .then((value) => print("User added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> deleteUser(String? name) async {
    QuerySnapshot snap = await FirebaseFirestore.instance.collection('users').where('name', isEqualTo: name).get();
    QueryDocumentSnapshot doc = snap.docs[0];
    DocumentReference user = doc.reference;
    user.delete()
        .then((value) => print("User deleted"))
        .catchError((error) => print("Failed to delete user: $error"));
  }

  Future<void> addTask(String? voter, String? taskNumber) async {
    QuerySnapshot snap = await FirebaseFirestore.instance.collection('users').where('name', isEqualTo: voter).get();
    QueryDocumentSnapshot doc = snap.docs[0];
    DocumentReference user = doc.reference;
    user.update(
      {'voted_tasks': FieldValue.arrayUnion([taskNumber])}
    )
    .then((value) => print("Task added"))
    .catchError((error) => print("Failed to add task: $error"));;
  }
}