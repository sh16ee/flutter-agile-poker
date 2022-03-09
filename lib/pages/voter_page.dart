import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agile_poker/firebase_api/game_api.dart';
import 'package:flutter_agile_poker/firebase_api/tasks_api.dart';
import 'package:flutter_agile_poker/firebase_api/users_api.dart';
import 'package:flutter_agile_poker/pages/main_page.dart';
import 'package:flutter_agile_poker/style.dart';


// class NumberButton extends StatefulWidget {
//   NumberButton({ Key? key, this.voter, this.taskNumber, this.buttonText = 1, this.changeColor, this.available = true}) : super(key: key);
//   String? voter;
//   String? taskNumber;
//   int buttonText;
//   bool available;
//   Function? changeColor;

//   @override
//   State<NumberButton> createState() => _NumberButtonState();
// }

// class _NumberButtonState extends State<NumberButton> {
//   final users = FirebaseUsers();
//   final tasks = FirebaseTasks();
//   final game = Game();

//   final Stream<QuerySnapshot> tasksSnapshots = FirebaseFirestore.instance.collection('tasks')
//                                                                          .orderBy('finished')
//                                                                          .orderBy('date_time', descending: true)
//                                                                          .snapshots();

//   bool selected = false;
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: StreamBuilder<QuerySnapshot>(
//         stream: tasksSnapshots,
//         builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.hasError) {
//             return Text('Something went wrong');
//           }
    
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           return Wrap(
//             children: snapshot.data!.docs.map((DocumentSnapshot document) { 
//                 Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
//                 List<dynamic> voters = data['users'];
//                 bool voted = voters.contains(widget.voter);
//                 return TextButton(
//                   onPressed: !selected && !voted ? () {
//                     tasks.addVoter(
//                       Voter(name: widget.voter, points: widget.buttonText).toJson(), 
//                       widget.taskNumber
//                     );
//                     users.addTask(widget.voter, widget.taskNumber);
//                     setState(() {
//                       selected = !selected;
//                     });
//                   } : null,
//                   child: Container(
//                     alignment: Alignment.center,
//                     height: height(context, 20),
//                     width: width(context, 5),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: selected ? Colors.green : voted && !selected ? black : blue),
//                       borderRadius: BorderRadius.circular(5)
//                     ),
//                     child: text("${widget.buttonText}", 14, selected ? Colors.green : voted && !selected ? black : blue),
//                   ),
//                 );
//               }
//             ).toList()
//           );
//         }
//       ),
//     );
//   }
// }

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

  Color _pointsColor = blue;

  int? points;
  
  final Stream<QuerySnapshot> tasksSnapshots = FirebaseFirestore.instance.collection('tasks')
                                                                         .orderBy('finished')
                                                                         .orderBy('date_time', descending: true)
                                                                         .snapshots();

  final Stream<QuerySnapshot> gameSnaps = FirebaseFirestore.instance.collection('game').snapshots();                                                                                                                                    


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text("Active voix:", 14, black),
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
                        bool voted = voters.contains(widget.voter);
                        List<int> storyPoints = [1 ,2, 3, 5, 8, 13, 20, 40, 100];
                        List<dynamic> usersList = data['voters'];
                        String pointsGiven = "";
                        usersList.forEach((user) {
                          if (widget.voter == user['name']) {
                            pointsGiven = user['points'].toString();
                          } 
                        });
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
                                          !voted ?
                                          Container() :
                                          Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: text("Your score: $pointsGiven", 18, black),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: text(data['task_description'], 14, black),
                                      ),
                                      Wrap(
                                        alignment: WrapAlignment.spaceEvenly,
                                        children: storyPoints.map((e) {
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 2),
                                              child: TextButton(
                                                onPressed: !voted ? () {
                                                  tasks.addVoter(
                                                    Voter(name: widget.voter, points: e).toJson(), 
                                                    data['task_number']
                                                  );
                                                  users.addTask(widget.voter, data['task_number']);
                                                } : null,
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  height: height(context, 20),
                                                  width: width(context, 5),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: !voted ? blue : black),
                                                    borderRadius: BorderRadius.circular(5)
                                                  ),
                                                  child: text("$e", 14,  !voted ? blue : black),
                                                ),
                                              ),
                                            );
                                          }
                                        ).toList()
                                      )
                                    ],
                                  ),
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
                              child: text("QUIT", 20, white),
                            ),
                          );
                        }).toList()
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
    );
  }
}