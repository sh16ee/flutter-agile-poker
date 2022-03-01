import 'dart:convert';
import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_agile_poker/firebase_api/game_api.dart';
import 'package:flutter_agile_poker/firebase_api/tasks_api.dart';
import 'package:flutter_agile_poker/firebase_api/users_api.dart';
import 'package:flutter_agile_poker/pages/main_page.dart';
import 'package:flutter_agile_poker/style.dart';
import 'package:provider/provider.dart';

class Voter {
  String? name;
  int? points;

  Voter({this.name, this.points});

  Map<String, dynamic> toJson() => {
    'name': this.name,
    'points': this.points
  };

  Voter.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    points = json['points'];
  }
}

class TaskCard with ChangeNotifier{
  String? taskName;
  String? taskDescription;
  int? points = 1;

  TaskCard({this.taskName, this.taskDescription, this.points});

  void notify() {
    notifyListeners();
  }

  void setPoints (int value) {
    print('your value $value and you gay');
      points = value;
      notifyListeners();
  }

  TaskCard.fromJson(Map<String, dynamic> json) {
    taskName = json['task_number'];
    taskDescription = json['task_descritption'];
  }
}

class VoterPage extends StatefulWidget {
  String? voter;
  VoterPage({Key? key, this.voter}) : super(key: key);

  @override
  State<VoterPage> createState() => _VoterPageState();
}

class _VoterPageState extends State<VoterPage> {

  final users = FirebaseUsers();
  final tasks = FirebaseTasks();
  final game = Game();


  int? points;
  
  final Stream<QuerySnapshot> tasksSnapshots = FirebaseFirestore.instance.collection('tasks')
                                                                         .orderBy('finished')
                                                                         .orderBy('date_time', descending: true)
                                                                         .snapshots();

  final Stream<QuerySnapshot> gameSnaps = FirebaseFirestore.instance.collection('game').snapshots();                                                                                                                                    


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TaskCard>(
      create: (context) => TaskCard(),
      child: Scaffold(
        body: Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text("Active voteseuax:", 14, black),
                  Flexible(
                    child: StreamBuilder(
                      stream: tasksSnapshots,
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Something went wrong');
                        }
                  
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text("Loading");
                        }
                  
                        return ListView(
                          children: snapshot.data!.docs.map((DocumentSnapshot document) {
                          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                          List<dynamic> voters = data['users'];
                          TaskCard card = TaskCard(taskName: data['task_number'], taskDescription: data['task_description'], points: 1);
                          // card.notify;
                            return Card(
                              child: 
                              !data['finished'] ?
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Column(
                                  children: [
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: text(data['task_number'], 18, black),
                                            ),
                                            DropdownButton<int>(
                                                value: card.points,
                                                onChanged: (int? newValue) {
                                                  setState(() {
                                                    card.points = newValue;
                                                  });
                                                  card.setPoints(newValue!);
                                                },
                                                items: <int>[1, 2, 3, 5, 8, 13, 20, 40, 100]
                                                    .map<DropdownMenuItem<int>>((int value) {
                                                  return DropdownMenuItem<int>(
                                                    value: value,
                                                    child: Text(value.toString()),
                                                  );
                                                }).toList(),
                                              ),
                                            // Padding(
                                            //   padding: const EdgeInsets.all(10),
                                            //   child: Container(
                                            //     width: width(context, 5),
                                            //     child: Row(
                                            //       mainAxisAlignment: MainAxisAlignment.end,
                                            //       children: [
                                            //         text('Points: ', 14, black),
                                            //         Flexible(child: TextField(
                                            //           keyboardType: TextInputType.number,
                                            //           inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                            //           onChanged: (value) => points = int.parse(value),
                                            //         ))
                                            //       ],
                                            //     ),
                                            //   ),
                                            // )
                                          ],
                                        ),
                                        text(data['task_description'], 14, black)
                                      ],
                                    ),
                                    !voters.contains(widget.voter) ?
                                    Container(
                                      width: width(context, 1),
                                      height: 40,
                                      child: TextButton(
                                        onPressed: () {
                                          tasks.addVoter(
                                            Voter(name: widget.voter, points: points).toJson(), 
                                            data['task_number']
                                          );
                                          users.addTask(widget.voter, data['task_number']);
                                        },
                                        child: text("VOTE", 14, blue),
                                      ),
                                    )
                                    :
                                    Container(
                                      width: width(context, 1),
                                      height: 40,
                                      child: Center(child: text("VOTED!", 14, black)),
                                    )
                                  ],
                                ),
                              ) :
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Center(
                                  child: text("Vote for task ${data['task_number']} has ended.", 14, black))
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
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
                        height: 40,
                        child: ListView(
                          children: snapshot.data!.docs.map((DocumentSnapshot document) {
                          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                            return Container(
                              height: 40,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(blue)
                                ),
                                onPressed: () {
                                  if (data['in_game']) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Game has not ended yet!"))
                                    );
                                  } else {
                                    users.deleteUser(widget.voter);
                                    Navigator
                                    .pushReplacement(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (BuildContext context) => MainPage(),
                                      )
                                    );
                                  }
                                },
                                child: text("${data['in_game']}", 20, white),
                              ),
                            );
                          }).toList()
                        ),
                      );
                      // return Padding(
                      //   padding: const EdgeInsets.all(5),
                      //   child: Container(
                      //     width: width(context, 1),
                      //     height: 40,
                      //     child: ElevatedButton(
                      //         style: ButtonStyle(
                      //           backgroundColor: MaterialStateProperty.all<Color>(blue)
                      //         ),
                      //         onPressed: () {
                      //             users.deleteUser(widget.voter);
                      //             Navigator
                      //             .pushReplacement(
                      //               context,
                      //               MaterialPageRoute<void>(
                      //                 builder: (BuildContext context) => MainPage(),
                      //               )
                      //             );
                      //           },
                      //         child: text("", 20, white),
                      //       )
                      //   ),
                      // );
                    },
                  ),
                ],
              ),
            ),
          ),
      ),
    );
  }
}