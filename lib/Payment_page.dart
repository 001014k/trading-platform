import 'package:flutter/material.dart';
import 'package:trading_platform_app/Account_page.dart';
import 'AddressInput_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'WishList_page.dart';
import 'main.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems; // Add this line

  PaymentPage({required this.selectedItems, this.selectedAddress}); // Remove final from selectedAddress

  final String? selectedAddress; // Move this line up here

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? _userAddress; // 초기 주소
  String? _userPhone;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'ko_KR', // 한국 원화에 맞는 로케일
    symbol: '₩',     // 통화 기호
    decimalDigits: 0, // 소수점 자리 제거
  );

  @override
  void initState() {
    super.initState();
    _userAddress = widget.selectedAddress; // 선택된 주소 초기화
  }

  // 특정 결제 문서에서 특정 상품 삭제 메서드
  Future<void> _deleteProductFromPayment(String paymentId, Map<String, dynamic> productToDelete) async {
    try {
      // 결제 문서 가져오기
      DocumentSnapshot paymentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('payments')
          .doc(paymentId)
          .get();

      if (paymentSnapshot.exists) {
        // Firestore에서 해당 제품을 삭제하기
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('payments')
            .doc(paymentId)
            .update({
          'products': FieldValue.arrayRemove([productToDelete]) // 해당 제품을 삭제
        });

        // UI 업데이트
        setState(() {});
      }
    } catch (e) {
      print('Error deleting product: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    double totalPrice = 0.0; // To calculate total price from selected items

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
            'PAY',
          style: TextStyle(
            color: Color(0xFF3669C9),
            fontSize: 18,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 배송 정보 섹션
            Text(
              '배송 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text(_userAddress ?? '주소를 선택하세요'),
              subtitle: Text(_userPhone ?? '전화번호를 입력하세요'),
              trailing: Icon(Icons.edit, color: Colors.blue),
              onTap: () async {
                // 주소 입력 페이지로 이동하고 입력된 주소 받아오기
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddressInputPage(),
                  ),
                );

                if (result != null) {
                  setState(() {
                    _userAddress = result['address'];  // result에서 'address' 키로 주소 가져오기
                    _userPhone = result['phone'];      // result에서 'phone' 키로 전화번호 가져오기
                  });
                }
              },
            ),
            Divider(),

            // 결제 수단 섹션
            Text(
              '결제 수단',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.credit_card),
              title: Text('신용카드'),
              trailing: DropdownButton<String>(
                items: [
                  DropdownMenuItem(
                    value: 'card',
                    child: Text('신용카드'),
                  ),
                  DropdownMenuItem(
                    value: 'naver_pay',
                    child: Text('네이버페이'),
                  ),
                ],
                onChanged: (String? value) {
                  // 결제 수단 변경 로직
                },
                hint: Text('결제 수단 선택'),
              ),
            ),
            Divider(),

            // 상품 정보 섹션
            Text(
              '상품 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .collection('payments')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('오류가 발생했습니다.'));
                  }

                  final payments = snapshot.data?.docs ?? [];
                  if (payments.isEmpty) {
                    return Center(child: Text('결제 기록이 없습니다.'));
                  }

                  return ListView(
                    children: payments.map((paymentDoc) {
                      final data = paymentDoc.data() as Map<String, dynamic>;
                      List<dynamic> products = data['products'] ?? [];
                      double paymentTotalPrice = data['totalPrice'] ?? 0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '결제일: ${DateFormat('yyyy-MM-dd HH:mm:ss').format((data['timestamp'] as Timestamp).toDate())}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Column(
                            children: products.map((item) {
                              totalPrice += item['productPrice']; // Calculate total price
                              return ListTile(
                                title: Text(item['productName']),
                                subtitle: Text(_currencyFormat.format(item['productPrice'])),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('수량: ${item['quantity'] ?? 1}'),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        // 삭제 버튼 클릭 시
                                        _deleteProductFromPayment(paymentDoc.id, item);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          Text(
                            '총 결제 금액: ${_currencyFormat.format(paymentTotalPrice)}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          Divider(),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            // 결제 버튼
            SizedBox(
              width: double.infinity, // 버튼이 화면 전체 너비를 차지하도록
              child: ElevatedButton(
                onPressed: () {
                  // 결제 처리 로직
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue, // 네이버 스타일의 결제 버튼 색상
                ),
                child: Text(
                  '결제하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomMenu(),
    );
  }
}

class BottomMenu extends StatefulWidget {
  @override
  _BottomMenuState createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  int _selectedIndex = 2;
  List<Map<String, dynamic>> selectedItems = [];

  // Firebase Authentication에서 현재 사용자 ID 가져오기
  String userId = FirebaseAuth.instance.currentUser?.uid ?? 'defaultUserId'; // 기본값은 임의로 설정

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) { // Wishlist 버튼이 눌렸을 때
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WishlistPage(userId: userId)),
        );
      }else if (index == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AccountPage(userId: userId)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'HOME',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'WISHLIST',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.credit_card),
          label: 'Pay',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'ACCOUNT',
        ),
      ],
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
    );
  }
}

