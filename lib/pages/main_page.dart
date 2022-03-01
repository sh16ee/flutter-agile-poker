import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agile_poker/firebase_api/game_api.dart';
import 'package:flutter_agile_poker/firebase_api/tasks_api.dart';
import 'package:flutter_agile_poker/firebase_api/users_api.dart';
import 'package:flutter_agile_poker/pages/admin_page.dart';
import 'package:flutter_agile_poker/pages/voter_page.dart';
import 'package:flutter_agile_poker/style.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({ Key? key }) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  
  final Stream<QuerySnapshot> gameSnaps = FirebaseFirestore.instance.collection('game').snapshots(); 

  final users = FirebaseUsers();
  final tasks = FirebaseTasks();
  final game = Game();

  String voter = "";

  void dialog() {
    showDialog(
      context: context, 
      builder: (BuildContext context) => AlertDialog(
        title: Text("Enter your name"),
        content: TextField(
          onChanged: (value) {
            voter = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              users.addUser(voter);
              Navigator
              .pushReplacement(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => VoterPage(voter: voter),
                )
              );
            }, 
            child: const Text("Enter a vote")
          )
        ],
      )
    );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/icon.png'),
            StreamBuilder<QuerySnapshot>(
              stream: gameSnaps,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                return SizedBox(
                  width: width(context, 1.5),
                  height: 200,
                  child: ListView(
                    children: <Widget>[
                      Container(
                        height: 100,
                        padding: const EdgeInsets.all(5),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(blue)
                          ),
                          onPressed: dialog,
                          child: text("VOTE", 20, white),
                        ),
                      )
                    ] + snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      return Container(
                        height: 100,
                        padding: const EdgeInsets.all(5),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(blue)
                          ),
                          onPressed: () {
                            if (data['in_game']) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Game has already started!"))
                              );
                            } else {
                              game.startGame();
                              users.clearUsers();
                              tasks.clearTasks();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) => AdminPage(),
                                )
                              );
                            }
                          },
                          child: text("START A VOTE", 20, white),
                        ),
                      );
                    }).toList()
                  ),
                );
              },
            ),
            // Padding(
            //   padding: const EdgeInsets.all(5),
            //   child: TextButton(
            //     onPressed: dialog,
            //     child: Container(
            //       width: width(context, 1.5),
            //       height: 100,
            //       alignment: Alignment.center,
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(10),
            //         color: blue
            //       ),
            //       child: text("VOTE", 20, white)
            //     ),
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.all(5),
            //   child: TextButton(
            //     onPressed: () async {
            //       users.clearUsers();
            //       tasks.clearTasks();
            //       game.startGame();
            //       Navigator.pushReplacement(
            //         context, 
            //         MaterialPageRoute<void>(
            //           builder: (BuildContext context) => AdminPage(),
            //         )
            //       );
            //     },
            //     child: Container(
            //       width: width(context, 1.5),
            //       height: 100,
            //       alignment: Alignment.center,
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(10),
            //         color: blue,
            //       ),
            //       child: text("START A VOTE", 20, white),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}