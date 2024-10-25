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
      // 먼저, 사용자 장바구니에서 제품 정보를 가져옵니다.
      final cartDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('cart')
          .doc(docId)
          .get();

      // 장바구니에 있는 제품 정보가 존재하는지 확인
      if (cartDoc.exists) {
        // 제품 ID를 가져옵니다.
        final productId = cartDoc['productId']; // 제품 ID 필드 이름이 'productId'라고 가정합니다.

        // 제품 상태를 false로 업데이트합니다.
        await FirebaseFirestore.instance
            .collection('products') // 제품 컬렉션
            .doc(productId) // 제품 ID
            .update({
          'isBidConfirmed': false, // 상태를 false로 설정
        });

        // 이후에 사용자 장바구니에서 해당 제품 삭제
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('cart')
            .doc(docId)
            .delete();
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }



  Future<void> _addPaymentInfo(List<Map<String, dynamic>> selectedProducts) async {
    try {
      // 현재 로그인한 사용자 문서에 결제 정보 추가
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('payments') // 'payments'라는 서브 컬렉션에 결제 정보 저장
          .add({
        'products': selectedProducts,
        'totalPrice': totalPrice,
        'timestamp': FieldValue.serverTimestamp(), // 결제 시간 추가
      });
    } catch (e) {
      print('결제 정보 추가 오류: $e');
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
                          List<Map<String, dynamic>> selectedProducts = [];

                          for (String itemId in selectedItems) {
                            final item = items.firstWhere((item) => item.id == itemId); // Find the item in the list
                            selectedProducts.add({
                              'productId': item.id, // 제품 ID 추가
                              'productName': item['productName'] ?? '이름 없음',
                              'productPrice': item['productPrice'] ?? 0,
                            });
                          }
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
                                    onPressed: () async {
                                      await _addPaymentInfo(selectedProducts); // 결제 정보 추가
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => PaymentPage(selectedItems: selectedProducts)),
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
