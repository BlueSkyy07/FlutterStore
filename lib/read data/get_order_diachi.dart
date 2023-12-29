import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class getOrderDiachi extends StatelessWidget {
  final String documentId;
  getOrderDiachi({
    required this.documentId,
  });

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('order');
    return FutureBuilder(
      future: users.doc(documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Text(
            '${data['diachi']}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          );
        }
        return Text('loading...');
      },
    );
  }
}
