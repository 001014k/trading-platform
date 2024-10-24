import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'Payment_page.dart';

class CartPage extends StatefulWidget {
  final String userId;

  CartPage({required this.userId});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<String> selectedItems = [];
  double totalPrice = 0.0;

  Future<void> deleteItem(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('cart')
          .doc(docId)
          .delete();
    } catch (e) {
      print('삭제 오류: $e');
    }
  }

  // 가격을 포맷팅하는 함수
  String formattedPrice(double price) {
    final formatter =
        NumberFormat.currency(locale: 'ko_KR', symbol: '₩', decimalDigits: 0);
    return formatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '장바구니',
          style: TextStyle(
            color: Color(0xFF3669C9),
            fontSize: 18,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('cart')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다.'));
          }

          final items = snapshot.data?.docs ?? [];

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: selectedItems.contains(item.id),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedItems.add(item.id);
                                  totalPrice += item['productPrice'];
                                } else {
                                  selectedItems.remove(item.id);
                                  totalPrice -= item['productPrice'];
                                }
                              });
                            },
                          ),
                          Expanded(
                            child: ListTile(
                              title: Text(
                                item['productName'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              subtitle: Text(
                                '가격: ${formattedPrice(item['productPrice'])}',
                                // 포맷된 가격 표시
                                style: TextStyle(color: Colors.black),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          '삭제 확인',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        content: Text('이 항목을 삭제하시겠습니까?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              deleteItem(item.id);
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              '삭제',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              '취소',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '총 가격',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          formattedPrice(totalPrice), // 포맷된 총 가격 표시
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        // 배경색 설정
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        // 패딩 설정
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // 둥근 모서리 설정
                        ),
                      ),
                      onPressed: () {
                        if (selectedItems.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(
                                  '결제하기',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                content: Text('선택한 제품으로 결제하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      // 배경색 설정
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 24),
                                      // 패딩 설정
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            8), // 둥근 모서리 설정
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => PaymentPage()),
                                      );
                                    },
                                    child: Text(
                                      '결제하기',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  TextButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      // 배경색 설정
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 24),
                                      // 패딩 설정
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            8), // 둥근 모서리 설정
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      '취소',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: Text(
                        '결제하기',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
