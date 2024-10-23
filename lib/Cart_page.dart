import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatelessWidget {
  final String userId; // 사용자의 ID를 전달받기 위한 변수

  CartPage({required this.userId}); // 생성자에서 사용자 ID를 받도록 설정

  Future<void> deleteItem(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
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
            .doc(userId)
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

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item['productName']),
                subtitle: Text('가격: ₩${item['productPrice'].toString()}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // 삭제 버튼 클릭 시
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('삭제 확인',style: TextStyle(fontWeight: FontWeight.bold),),
                          content: Text('이 항목을 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                // 배경색 설정
                                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                // 패딩 설정
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8), // 둥근 모서리 설정
                                ),
                              ),
                              onPressed: () {
                                deleteItem(item.id); // 항목 삭제
                                Navigator.of(context).pop(); // 대화 상자 닫기
                              },
                              child: Text('삭제',style: TextStyle(color: Colors.black),),
                            ),
                            TextButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                // 배경색 설정
                                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                // 패딩 설정
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8), // 둥근 모서리 설정
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop(); // 대화 상자 닫기
                              },
                              child: Text('취소',style: TextStyle(color: Colors.black),),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
