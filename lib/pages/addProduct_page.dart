import 'package:admin/values/app_assets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _ProductName = TextEditingController();
  final _ProductPrice = TextEditingController();
  final _ProductDescription = TextEditingController();

  Future Add() async {
    AddNewProduct(_ProductName.text.trim(),
        int.parse(_ProductPrice.text.trim()), _ProductDescription.text.trim());
  }

  Future AddNewProduct(String name, int price, String description) async {
    await FirebaseFirestore.instance.collection('Store').add({
      'name': name,
      'price': price,
      'description': description,
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            productAdd("Name", "Cơm chiên", _ProductName),
            productAdd("Price", "22000", _ProductPrice),
            productAdd(
                "Description", "Món ăn này ngon thật", _ProductDescription),
            SizedBox(height: 20),
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
                                      child: Text('OK'))
                                ],
                              ),
                            );
                          });
                      //Navigator.pop(context);
                    },
                    child: Text(
                      "Thêm",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}

Widget productAdd(
    String name, String values, TextEditingController textcontroller) {
  return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: textcontroller,
              obscureText: false,
              decoration:
                  InputDecoration(border: InputBorder.none, hintText: values),
            ),
          )
        ],
      ));
}
