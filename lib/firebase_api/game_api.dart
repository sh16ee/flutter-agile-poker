import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Game with ChangeNotifier{

  bool isStarted = false;

  void notify() {
    notifyListeners();
  }

  Future<void> startGame() async {
    QuerySnapshot snap = await FirebaseFirestore.instance.collection('game').where('game_name', isEqualTo: 'agile-poker').get();
    QueryDocumentSnapshot doc = snap.docs[0];
    DocumentReference game = doc.reference;
    game.update(
      {
        'in_game': true
      }
    )
    .then((value) => print("Game started"))
    .catchError((error) => print("Failed to start a game: $error"));

    isStarted = true;
    notifyListeners();
  }

  Future<void> endGame() async {
    QuerySnapshot snap = await FirebaseFirestore.instance.collection('game').where('game_name', isEqualTo: 'agile-poker').get();
    QueryDocumentSnapshot doc = snap.docs[0];
    DocumentReference task = doc.reference;
    task.update(
      {
        'in_game': false
      }
    )
    .then((value) => print("Game ended"))
    .catchError((error) => print("Failed to end a game: $error"));

    isStarted = false;
    notifyListeners();
  }
}