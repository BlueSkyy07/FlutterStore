import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  final Function? updateCallback1;
  ProductDetailPage({required this.productId, required this.updateCallback1});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  TextEditingController _editController = TextEditingController();

  // Hàm cập nhật giá trị price
  Future<void> _updatePrice(String newValue) async {
    // Chuyển đổi giá trị từ String sang int
    int newPrice = int.tryParse(newValue) ?? 0;

    // Cập nhật giá trị mới vào Firestore
    await FirebaseFirestore.instance
        .collection('Store')
        .doc(widget.productId)
        .update({'price': newPrice});

    Navigator.pop(context);
    // Cập nhật lại trang
    await _refreshPage();
  }

  late firebase_storage.Reference ref;
  Uint8List? _image;
  Future<void> SelectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _image = imageBytes;
      });
    }
  }

  Future<void> saveDataWithImageUrl(String imageUrl) async {
    await FirebaseFirestore.instance
        .collection('Store')
        .doc(widget.productId)
        .update({'imageLink': imageUrl});
  }

  Future<void> Add() async {
    if (_image != null) {
      try {
        // Tạo tham chiếu đến Firebase Storage
        ref = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('ProductImages')
            .child(Uuid().v1() + '.jpg');

        // Tải ảnh lên Firebase Storage
        await ref.putData(_image!);

        // Lấy URL của ảnh đã tải lên
        final imageUrl = await ref.getDownloadURL();

        // Lưu thông tin sản phẩm cùng với URL vào Firestore
        await saveDataWithImageUrl(imageUrl);

        // Hiển thị thông báo hoặc thực hiện các công việc khác khi thành công
        print('Product added successfully!');

        // Call the update callback only once after the product is added
        await _refreshPage();
        widget.updateCallback1?.call();
      } catch (error) {
        // Xử lý lỗi khi có vấn đề với quá trình tải lên
        print('Error adding product: $error');
      }
    } else {
      // Hiển thị thông báo hoặc thực hiện các công việc khác nếu không có ảnh được chọn
      print('No image selected!');
    }
  }

  // Function to delete the product
  Future<void> _deleteProduct() async {
    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Are you sure you want to delete this product?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Delete the product from Firestore
                await FirebaseFirestore.instance
                    .collection('Store')
                    .doc(widget.productId)
                    .delete();

                // Navigate back to the home page
                Navigator.popUntil(context, (route) => route.isFirst);

                // Call the update callback after deletion
                widget.updateCallback1?.call();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _openEditBox(String field, String initialValue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $field'),
        content: TextField(
          controller: _editController..text = initialValue,
          decoration: InputDecoration(labelText: 'Enter new $field'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              String newValue = _editController.text.trim();
              // Kiểm tra xem có giá trị mới được nhập hay không
              if (newValue.isNotEmpty) {
                // Gọi hàm cập nhật tương ứng
                if (field == 'price') {
                  await _updatePrice(newValue);
                } else {
                  // Cập nhật giá trị mới vào Firestore
                  await FirebaseFirestore.instance
                      .collection('Store')
                      .doc(widget.productId)
                      .update({field: newValue});
                  // Đóng hộp thoại chỉnh sửa
                  Navigator.pop(context);
                  await _refreshPage();
                }
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshPage() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference products =
        FirebaseFirestore.instance.collection('Store');

    return Scaffold(
      appBar: AppBar(
        title: Text('Product Detail'),
      ),
      body: FutureBuilder(
        future: products.doc(widget.productId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;

            String name = data['name'] ?? '';
            int price = data['price'] ?? '';
            String description = data['description'] ?? '';
            String imageUrl = data['imageLink'] ?? '';

            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _image != null
                      ? Container(
                          height: 200,
                          width: double.infinity,
                          child: Image.memory(_image!),
                        )
                      : Image.network(
                          imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                          onPressed: SelectImage,
                          icon: Icon(Icons.add_a_photo_sharp)),
                      ElevatedButton(
                          onPressed: () {
                            Add();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Center(
                                  child: AlertDialog(
                                    title: Text("Notification!!"),
                                    content: Text("Update complete !!"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('OK'),
                                      )
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Text('Update image'))
                    ],
                  ),
                  SizedBox(height: 16),

                  // Hiển thị tên sản phẩm

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            text: 'Name: ',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: '$name',
                            style: TextStyle(fontSize: 18, color: Colors.black))
                      ])),
                      IconButton(
                        onPressed: () {
                          _openEditBox('name', name);
                        },
                        icon: Icon(Icons.edit),
                      )
                    ],
                  ),
                  SizedBox(height: 8),
                  // Hiển thị giá sản phẩm
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            text: 'Price: ',
                            style: TextStyle(fontSize: 18, color: Colors.red)),
                        TextSpan(
                            text: '$price VND',
                            style: TextStyle(fontSize: 18, color: Colors.black))
                      ])),
                      IconButton(
                        onPressed: () {
                          _openEditBox('price', price.toString());
                        },
                        icon: Icon(Icons.edit),
                      )
                    ],
                  ),
                  SizedBox(height: 8),
                  // Hiển thị mô tả sản phẩm
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: RichText(
                            softWrap: true,
                            text: TextSpan(children: [
                              TextSpan(
                                  text: 'Description: ',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.red)),
                              TextSpan(
                                  text: '$description',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black))
                            ])),
                      ),
                      IconButton(
                        onPressed: () {
                          _openEditBox('description', description);
                        },
                        icon: Icon(Icons.edit),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: MaterialButton(
                      onPressed: _deleteProduct,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12)),
                        child: Center(
                          child: Text(
                            "Delete",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ))
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
