import 'dart:typed_data';
import 'package:admin/values/app_assets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart'; // Import thư viện uuid

class AddProduct extends StatefulWidget {
  final Function? updateCallback;
  const AddProduct({Key? key, this.updateCallback}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _ProductName = TextEditingController();
  final _ProductPrice = TextEditingController();
  final _ProductDescription = TextEditingController();

  late firebase_storage.Reference ref;
  Uint8List? _image;

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
        widget.updateCallback?.call();
      } catch (error) {
        // Xử lý lỗi khi có vấn đề với quá trình tải lên
        print('Error adding product: $error');
      }
    } else {
      // Hiển thị thông báo hoặc thực hiện các công việc khác nếu không có ảnh được chọn
      print('No image selected!');
    }
  }

  Future AddNewProduct(String name, int price, String description) async {
    await FirebaseFirestore.instance.collection('Store').add({
      'name': name,
      'price': price,
      'description': description,
    });
  }

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

  // void uploadimage() async {
  //   if (_image != null) {
  //     try {
  //       // Tạo tham chiếu đến Firebase Storage
  //       ref = firebase_storage.FirebaseStorage.instance
  //           .ref()
  //           .child('ProductImages')
  //           .child(Uuid().v1() + '.jpg');

  //       // Tải ảnh lên Firebase Storage
  //       await ref.putData(_image!);

  //       // Lấy URL của ảnh đã tải lên
  //       final imageUrl = await ref.getDownloadURL();

  //       // Lưu URL vào Firestore
  //       await saveDataWithImageUrl(imageUrl);

  //       // Hiển thị thông báo hoặc thực hiện các công việc khác khi thành công
  //       print('Image uploaded successfully!');
  //     } catch (error) {
  //       // Xử lý lỗi khi có vấn đề với quá trình tải lên
  //       print('Error uploading image: $error');
  //     }
  //   } else {
  //     // Hiển thị thông báo hoặc thực hiện các công việc khác nếu không có ảnh được chọn
  //     print('No image selected!');
  //   }
  // }

  Future<void> saveDataWithImageUrl(String imageUrl) async {
    // Lưu thông tin sản phẩm cùng với URL vào Firestore
    await FirebaseFirestore.instance.collection('Store').add({
      'name': _ProductName.text.trim(),
      'price': int.parse(_ProductPrice.text.trim()),
      'description': _ProductDescription.text.trim(),
      'imageLink': imageUrl,
    });
  }

  @override
  void dispose() {
    _ProductName.dispose();
    _ProductPrice.dispose();
    _ProductDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Add Product"),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Image.asset(AppAssets.leftarrow),
        ),
      ),
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              productAdd("Name", "Cơm chiên", _ProductName),
              productAdd("Price", "22000", _ProductPrice),
              productAdd(
                "Description",
                "Món ăn này ngon thật",
                _ProductDescription,
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Image',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 220,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          _image != null
                              ? Container(
                                  height: 200,
                                  width: double.infinity,
                                  child: Image.memory(_image!),
                                )
                              : Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.black45,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Select Images',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                          Positioned(
                            bottom: 5,
                            right: 0,
                            child: InkWell(
                              onTap: SelectImage,
                              child: Icon(Icons.add_a_photo),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: uploadimage,
              //   child: Text('Save Profile'),
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  height: 50,
                  width: 100,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        Add();
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Center(
                              child: AlertDialog(
                                title: Text("Notification!!"),
                                content: Text("Mặt hàng đã thêm thành công !!"),
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
                        //Navigator.pop(context);
                      },
                      child: Text(
                        "Thêm",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

Widget productAdd(
  String name,
  String values,
  TextEditingController textcontroller,
) {
  return Container(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          padding: EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: textcontroller,
            obscureText: false,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: values,
            ),
          ),
        ),
      ],
    ),
  );
}
