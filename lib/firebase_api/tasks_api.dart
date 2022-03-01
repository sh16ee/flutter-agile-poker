import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTasks {

  Future<void> clearTasks() async {
    var tasks = await FirebaseFirestore.instance.collection('tasks').get();
    if (tasks.docs.isNotEmpty) {
      tasks.docs.forEach((doc) async {
        await doc.reference
                  .delete()
                  .then((value) => print("Task deleted"))
                  .catchError((error) => print("Failed to delete task: $error"));
      });
    }
  }

  Future<void> addTask(String task, String description) {  
  CollectionReference tasks = FirebaseFirestore.instance.collection('tasks');
    return tasks
        .add({ 
          'date_time': DateTime.now(),
          'finished': false,
          'task_number': task,
          'task_description': description,
          'voters': [],
          'users': [],
          'points': [],
          'total': 0
        })
        .then((value) => print("Task Added"))
        .catchError((error) => print("Failed to add task: $error"));
  }

  Future<void> addVoter(Map<String, dynamic> user, String? taskNumber) async {
    QuerySnapshot snap = await FirebaseFirestore.instance.collection('tasks').where('task_number', isEqualTo: taskNumber).get();
    QueryDocumentSnapshot doc = snap.docs[0];
    DocumentReference task = doc.reference;
    task.update(
      {
        'voters': FieldValue.arrayUnion([user]),
        'users': FieldValue.arrayUnion([user['name']]),
        'points': FieldValue.arrayUnion([user['points']])
      }
    )
    .then((value) => print("Voter added to task with ${user['points']} points"))
    .catchError((error) => print("Failed to add voter: $error"));
  }

  Future<void> restartVote(String? taskNumber, List<dynamic> voters) async {
    for (int i = 0; i < voters.length; i++) {
      QuerySnapshot snap = await FirebaseFirestore.instance.collection('users').where('name', isEqualTo: voters[i]).get();
      QueryDocumentSnapshot doc = snap.docs[0];
      DocumentReference user = doc.reference;
      user.update(
        {'voted_tasks': FieldValue.arrayRemove([taskNumber])}
      )
      .then((value) => print("User updated"))
      .catchError((error) => print("Failed to update user: $error"));
    }

    QuerySnapshot snap = await FirebaseFirestore.instance.collection('tasks').where('task_number', isEqualTo: taskNumber).get();
    QueryDocumentSnapshot doc = snap.docs[0];
    DocumentReference task = doc.reference;
    task.update(
      {
        'date_time': DateTime.now(),
        'finished': false,
        'voters': [],
        'users': [],
        'points': [],
        'total': 0
      }
    )
    .then((value) => print("Task Updated"))
    .catchError((error) => print("Failed to update task: $error"));
  }

  Future<void> endVote(String? taskNumber, bool? finished, int total) async {
    QuerySnapshot snap = await FirebaseFirestore.instance.collection('tasks').where('task_number', isEqualTo: taskNumber).get();
    QueryDocumentSnapshot doc = snap.docs[0];
    DocumentReference task = doc.reference;
    task.update(
      {
        'finished': true,
        'total': total
      }
    )
    .then((value) => print("Task Updated"))
    .catchError((error) => print("Failed to update task: $error"));
  }
}