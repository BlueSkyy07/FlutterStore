import 'package:admin/pages/addProduct_page.dart';
import 'package:admin/pages/product_detail_page.dart';
import 'package:admin/read%20data/get_product_image.dart';
import 'package:admin/read%20data/get_product_name.dart';
import 'package:admin/read%20data/get_product_price.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:admin/values/app_assets.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final user = FirebaseAuth.instance.currentUser!;

  //documents IDs
  List<String> docIDs = [];

  //get docIDs
  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection('Store')
        .get()
        .then((snapshot) => snapshot.docs.forEach((element) {
              print(element.reference);
              docIDs.add(element.reference.id);
            }));
  }

  Future<void> updateProducts() async {
    docIDs.clear();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            // Mở Drawer khi bấm vào leading
            _scaffoldKey.currentState?.openDrawer();
          },
          child: Image.asset(AppAssets.admin),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Image.asset(AppAssets.notification),
          ),
          InkWell(
            onTap: () {},
            child: Image.asset(AppAssets.list),
          ),
        ],
      ),
      drawer: Drawer(
        // Widget Drawer chứa nội dung bạn muốn hiển thị
        child: ListView(
          children: [
            // Thêm các mục trong Drawer
            Center(
              child: Container(
                child: Text(
                  'Xin chào!' + user.email!,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: MaterialButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 145, 115, 202),
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Text(
                      "Sign out",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            )
            // Thêm các mục khác nếu cần
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        items: [
          BottomNavigationBarItem(icon: Image.asset(AppAssets.home), label: ''),
          BottomNavigationBarItem(
              icon: Image.asset(AppAssets.favorite), label: ''),
          BottomNavigationBarItem(icon: Image.asset(AppAssets.cart), label: ''),
          BottomNavigationBarItem(icon: Image.asset(AppAssets.chat), label: ''),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddProduct(updateCallback: updateProducts),
              // builder: (_) => AddProduct(),
            ),
          );
        },
        child: Icon(Icons.add),
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
              return GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: docIDs.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProductDetailPage(
                                    updateCallback1: updateProducts,
                                    productId: docIDs[index],
                                  )));
                    },
                    child: Container(
                      alignment: Alignment.topCenter,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black38,
                                offset: Offset(2, 3),
                                blurRadius: 3)
                          ]),
                      child: Column(
                        children: [
                          Container(
                            child: GetProductName(
                              documentId: docIDs[index],
                            ),
                          ),
                          Container(
                            child: GetProductPrice(documentId: docIDs[index]),
                          ),
                          Container(
                            // Điều chỉnh vị trí theo ý muốn
                            child: GetProductImage(documentId: docIDs[index]),
                          ),
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
