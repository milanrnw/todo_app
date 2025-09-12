import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_todo_app/models/user_details.dart';

class StreamEg extends StatefulWidget {
  const StreamEg({super.key});

  @override
  State<StreamEg> createState() => _StreamEgState();
}

class _StreamEgState extends State<StreamEg> {
  final firestoreAuth = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stream Eg."),
      ),
      body: Center(
        child: StreamBuilder(
            stream: firestoreAuth
                .collection("/users")
                .doc("eYLgtFqEIhTUKLh2I977")
                .snapshots(),
            builder: (context, data) {
              if (data.hasData) {
                final userDetails =
                    UserDetails.fromJson(data.requireData.data()!);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("firstName: ${userDetails.firstName.toString()}"),
                    Text("lastName: ${userDetails.lastName.toString()}"),
                    Text("email: ${userDetails.email.toString()}"),
                    Text("password: ${userDetails.password.toString()}"),
                    Text("uid: ${userDetails.uid.toString()}"),
                  ],
                );
              }
              return Text("No data");
            }),
      ),
    );
  }
}
