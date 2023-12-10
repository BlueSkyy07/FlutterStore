import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetProductImage extends StatelessWidget {
  final String documentId;
  GetProductImage({
    required this.documentId,
  });

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('Store');
    return FutureBuilder(
      future: users.doc(documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          // Thay thế 'imageLink' bằng tên trường chứa đường dẫn ảnh trong Firestore của bạn
          String imageUrl = data['imageLink'] ?? '';

          return imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  height: 130, // Điều chỉnh độ cao theo ý muốn
                  width: 150, // Điều chỉnh độ rộng theo ý muốn
                  fit: BoxFit.cover,
                )
              : Text('No image available');
        }
        return Text('loading...');
      },
    );
  }
}
