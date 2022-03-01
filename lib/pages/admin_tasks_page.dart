import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agile_poker/firebase_api/game_api.dart';
import 'package:flutter_agile_poker/firebase_api/tasks_api.dart';
import 'package:flutter_agile_poker/pages/main_page.dart';
import 'package:flutter_agile_poker/style.dart';

class AdminTasksPage extends StatefulWidget {
  AdminTasksPage({Key? key}) : super(key: key);

  @override
  State<AdminTasksPage> createState() => _AdminTasksPageState();
}

class _AdminTasksPageState extends State<AdminTasksPage> {

  final tasks = FirebaseTasks();
  final game = Game();

  final Stream<QuerySnapshot> activeTasks = FirebaseFirestore.instance.collection('tasks')
                                                                      .orderBy('finished', descending: true)
                                                                      .orderBy('date_time', descending: true)
                                                                      .snapshots();
  CollectionReference activeVoters = FirebaseFirestore.instance.collection('tasks');

  String newTask = '';
  String newDescription = '';
  bool showVoteResults = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Container(
            height: 40,
            child: TextField(
              onChanged: (value) => newTask = value,
              decoration: InputDecoration(
                hintText: "Enter task number",
                hintStyle: TextStyle(
                  fontSize: 14
                ),
                border: OutlineInputBorder()
              ) 
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            height: 40,
            child: TextField(
              onChanged: (value) => newDescription = value,
              decoration: InputDecoration(
                hintText: "Enter task description",
                hintStyle: TextStyle(
                  fontSize: 14
                ),
                border: OutlineInputBorder()
              ) 
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            width: width(context, 1),
            height: 40,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(blue)
              ),
              onPressed: () {
                tasks.addTask(newTask, newDescription);
              },
              child: text("ADD TASK", 20, white),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: text("Tasks:", 20, black),
        ),
        Flexible(
          child: StreamBuilder(
            stream: activeTasks,
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
                List<dynamic> usersList = data['voters'];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    text(data['task_number'], 18, black),
                                    text("  Voted: ${data['voters'].length}", 14, black),
                                  ],
                                ),
                                text(data['task_description'], 14, black)
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(blue)
                                ),
                                onPressed: () {
                                  tasks.restartVote(data['task_number'], data['users']);
                                }, 
                                child: text("RESTART VOTE", 14, white)),
                              if(!data['finished'])
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(blue)
                                ),
                                onPressed: () {
                                  int total = data['points'].fold(0, (a, b) => a + b) ~/ data['points'].length;
                                  tasks.endVote(data['task_number'], true, total);
                                },
                                child: text("END VOTE", 14, white)),
                            ],
                          ),
                          if(data['finished'])
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                text("VOTE RESULTS", 14, black),
                                text("Total: ${data['total']}", 20, black),
                                Container(
                                  width: width(context, 1),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: Wrap(
                                      spacing: 5,
                                      runSpacing: 5,
                                      children: usersList.map((e) {
                                          return Chip(
                                            backgroundColor: blue,
                                            label: text('${e['name']}: ${e['points']}', 14, white)
                                          );
                                        }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            width: width(context, 1),
            height: 40,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(blue)
              ),
              onPressed: () {
                game.endGame();
                Navigator
                .pushReplacement(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => MainPage(),
                  )
                );
              },
              child: text("END GAME", 14, white),
            ),
          ),
        ),
      ],
    );
  }
}