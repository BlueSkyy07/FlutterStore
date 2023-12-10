import 'package:admin/pages/addProduct_page.dart';
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

  void updateProducts() {
    setState(() {
      // Gọi lại hàm lấy danh sách ID để cập nhật danh sách sản phẩm
      getDocId();
    });
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddProduct()),
          );
        },
        child: Icon(Icons.add),
      ),
      // body: Container(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.start,
      //     children: [
      //       Container(
      //         child: Padding(
      //           padding: const EdgeInsets.only(top: 15, left: 30),
      //           child: Container(
      //             width: size.width * 7 / 10,
      //             height: 35,
      //             decoration: BoxDecoration(
      //               color: Colors.white,
      //               borderRadius: BorderRadius.circular(9),
      //               boxShadow: [
      //                 BoxShadow(
      //                   blurRadius: 6,
      //                   offset: Offset(3, 6),
      //                   color: Colors.black26,
      //                 )
      //               ],
      //             ),
      //             child: Stack(
      //               children: [
      //                 Positioned(
      //                   top: 0,
      //                   bottom: 0,
      //                   child: Image.asset(AppAssets.search),
      //                 ),
      //                 Positioned(
      //                   left: 40,
      //                   top: 10,
      //                   child: Text(
      //                     "Search",
      //                     style: TextStyle(
      //                       fontStyle: FontStyle.italic,
      //                       color: Colors.black26,
      //                     ),
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ),
      //       ),
      //       // Padding(
      //       //   padding: const EdgeInsets.symmetric(vertical: 24),
      //       //   child: Container(
      //       //     height: 200, // Điều chỉnh độ cao theo ý muốn
      //       //     child: PageView.builder(
      //       //       controller: _pageController,
      //       //       itemCount: 3, // Số lượng hình ảnh trong danh sách
      //       //       itemBuilder: (context, index) {
      //       //         List<String> images = [
      //       //           AppAssets.qc1,
      //       //           AppAssets.qc2,
      //       //           AppAssets.qc3,
      //       //           AppAssets.qc4
      //       //         ];
      //       //         return Image.asset(
      //       //           images[index],
      //       //           fit: BoxFit.cover,
      //       //         ); // Đường link hình ảnh thay thế
      //       //       },
      //       //     ),
      //       //   ),
      //       // ),

      //       SizedBox(height: 30),
      //       Expanded(
      //         child: FutureBuilder(
      //           future: getDocId(),
      //           builder: (context, snapshot) {
      //             return ListView.builder(
      //               itemCount: docIDs.length,
      //               itemBuilder: (context, index) {
      //                 return ListTile(
      //                   title: Text(docIDs[index]),
      //                 );
      //               },
      //             );
      //           },
      //         ),
      //       ),
      //     ],
      //   ),
      // ));

      body: Container(
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
                  return Container(
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
                        Positioned(
                          // Điều chỉnh vị trí theo ý muốn
                          child: GetProductImage(documentId: docIDs[index]),
                        ),
                      ],
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
