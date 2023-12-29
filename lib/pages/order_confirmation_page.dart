import 'package:admin/read%20data/get_oder_name.dart';
import 'package:admin/read%20data/get_order_diachi.dart';
import 'package:admin/read%20data/get_order_email.dart';
import 'package:admin/read%20data/get_order_gia.dart';
import 'package:admin/read%20data/get_order_sl.dart';
import 'package:admin/read%20data/get_order_tongtien.dart';
import 'package:admin/read%20data/get_order_trangthai.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderComfirmPage extends StatefulWidget {
  const OrderComfirmPage({super.key});

  @override
  State<OrderComfirmPage> createState() => _OrderComfirmPageState();
}

class _OrderComfirmPageState extends State<OrderComfirmPage> {
  final user = FirebaseAuth.instance.currentUser!;

  //documents IDs
  List<String> docIDs = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> updateOrderStatus(String documentId) async {
    // Cập nhật trạng thái của đơn hàng thành "Thành công"
    await _firestore.collection('order').doc(documentId).update({
      'trangthai': 'Thành công',
    });
  }

  Future<void> getDocId() async {
    final QuerySnapshot snapshot = await _firestore.collection('order').get();

    snapshot.docs.forEach((element) {
      print(element.reference);
      docIDs.add(element.reference.id);
    });
  }

  Future<void> updateProducts() async {
    docIDs.clear();
    setState(() {});
  }

  Future<void> deleteOrder(String documentId) async {
    // Xóa đơn hàng từ Firestore
    await _firestore.collection('order').doc(documentId).delete();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xác nhận đơn hàng'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          docIDs.clear();
          await Future.delayed(Duration(seconds: 2));
          setState(() {});
        },
        child: FutureBuilder(
          future: getDocId(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return ListView.builder(
                itemCount: docIDs.length,
                itemBuilder: (context, index) {
                  final documentId = docIDs[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38,
                          offset: Offset(2, 3),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Tên sp:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Container(
                                child: getOrderName(
                                  documentId: docIDs[index],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Giá:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Container(
                                child: getOrderGia(
                                  documentId: docIDs[index],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Số lượng:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Container(
                                child: getOrderSoluong(
                                  documentId: docIDs[index],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Tổng tiền:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Container(
                                child: getOrderTongtien(
                                  documentId: docIDs[index],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Email:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Container(
                                child: getOrderEmail(
                                  documentId: docIDs[index],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Địa chỉ: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Container(
                                child: getOrderDiachi(
                                  documentId: docIDs[index],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Trạng thái:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Container(
                                child: getOrderStatus(
                                  documentId: docIDs[index],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    updateOrderStatus(documentId);
                                  },
                                  child: Text('Xác nhận')),
                              ElevatedButton(
                                  onPressed: () {
                                    deleteOrder(documentId);
                                  },
                                  child: Text(
                                    'Hủy',
                                    style: TextStyle(color: Colors.red),
                                  )),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
