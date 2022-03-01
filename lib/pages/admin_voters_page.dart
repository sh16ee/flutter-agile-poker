import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agile_poker/style.dart';

class AdminVotersPage extends StatefulWidget {
  const AdminVotersPage({ Key? key }) : super(key: key);

  @override
  _AdminVotersPageState createState() => _AdminVotersPageState();
}

class _AdminVotersPageState extends State<AdminVotersPage> {

  final Stream<QuerySnapshot> users = FirebaseFirestore.instance.collection('users').snapshots();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: text("Voters:", 20, black),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: StreamBuilder(
              stream: users,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }
        
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }
        
                return GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5
                  ),
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                  List<dynamic> votedTasks = data['voted_tasks'];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              text(data['name'], 18, black),
                              divider,
                              text("Voted tasks:", 14, black),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: votedTasks.map((e) => 
                                      text(e, 14, black)
                                    ).toList(),
                                  ),
                                )
                              )
                            ],
                          )
                        )
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}