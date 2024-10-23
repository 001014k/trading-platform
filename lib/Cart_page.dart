import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatefulWidget {
  final String userId; // 사용자의 ID를 전달받기 위한 변수

  CartPage({required this.userId}); // 생성자에서 사용자 ID를 받도록 설정

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<String> selectedItems = []; // 선택된 항목 ID를 저장할 리스트
  double totalPrice = 0.0; // 총 가격 변수

  Future<void> deleteItem(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('cart')
          .doc(docId) // 삭제할 문서 ID
          .delete(); // 문서 삭제
    } catch (e) {
      print('삭제 오류: $e');
    }
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
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // 간격 조절
                      padding: EdgeInsets.all(16.0), // 내부 여백
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0), // 둥근 모서리
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2), // 그림자 색상
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 3), // 위치 조절
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
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              subtitle: Text(
                                '가격: ₩${item['productPrice'].toString()}',
                                style: TextStyle(color: Colors.black),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  // 삭제 버튼 클릭 시
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          '삭제 확인',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        content: Text('이 항목을 삭제하시겠습니까?'),
                                        actions: [
                                          TextButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8), // 둥근 모서리 설정
                                              ),
                                            ),
                                            onPressed: () {
                                              deleteItem(item.id); // 항목 삭제
                                              Navigator.of(context).pop(); // 대화 상자 닫기
                                            },
                                            child: Text(
                                              '삭제',
                                              style: TextStyle(color: Colors.black),
                                            ),
                                          ),
                                          TextButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8), // 둥근 모서리 설정
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop(); // 대화 상자 닫기
                                            },
                                            child: Text(
                                              '취소',
                                              style: TextStyle(color: Colors.black),
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
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // 총 가격 타이틀
                        ),
                        SizedBox(height: 8), // 타이틀과 총 가격 사이의 간격
                        Text(
                          '₩${totalPrice.toStringAsFixed(0)}', // 총 가격 표시
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // 결제하기 버튼 클릭 시의 로직
                        if (selectedItems.isNotEmpty) {
                          // 결제 로직 구현
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('결제하기'),
                                content: Text('선택한 제품으로 결제하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      // 결제 처리 로직 추가
                                      // 예: Firestore에 결제 정보 저장 등
                                      Navigator.of(context).pop(); // 대화 상자 닫기
                                    },
                                    child: Text('결제하기'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // 대화 상자 닫기
                                    },
                                    child: Text('취소'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: Text('결제하기'),
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
