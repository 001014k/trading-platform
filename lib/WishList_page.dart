import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_platform_app/Account_page.dart';
import 'package:trading_platform_app/all_products_page.dart';
import 'package:trading_platform_app/main.dart';
import 'package:trading_platform_app/payment_page.dart';

// Wishlist 페이지
class WishlistPage extends StatelessWidget {
  final String userId; // 현재 사용자 ID

  WishlistPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Center(
          child: Text(
            'WishList',
            style: TextStyle(
              color: Color(0xFF3669C9),
              fontSize: 18,
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getWishlistItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('위시리스트에 제품이 없습니다.'));
          }

          final wishlistItems = snapshot.data!;

          return ListView.builder(
            itemCount: wishlistItems.length,
            itemBuilder: (context, index) {
              final item = wishlistItems[index];
              return ListTile(
                leading: Image.network(item['imageUrl']),
                title: Text(item['name']),
                subtitle: Text('₩${NumberFormat('#,##0').format(item['price'])}'),
              );
            },
          );
        },
      ),
      // 하단에 BottomMenu 추가
      bottomNavigationBar: BottomMenu(),
    );
  }

  // Firestore에서 위시리스트 아이템을 가져오는 함수
  Future<List<Map<String, dynamic>>> _getWishlistItems() async {
    final wishlistItems = <Map<String, dynamic>>[];

    // Firestore에서 사용자 ID를 기준으로 위시리스트 아이템 조회
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users') // 사용자 컬렉션
        .doc(userId) // 현재 사용자 문서
        .collection('wishlists') // 위시리스트 서브컬렉션
        .get();

    for (var doc in querySnapshot.docs) {
      wishlistItems.add(doc.data() as Map<String, dynamic>);
    }

    return wishlistItems;
  }
}

// 하단 네비게이션 바
class BottomMenu extends StatefulWidget {
  @override
  _BottomMenuState createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  int _selectedIndex = 1; // Wishlist가 현재 페이지이므로 index를 1로 설정
  List<Map<String, dynamic>> selectedItems = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) { // Wishlist 버튼이 눌렸을 때
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PaymentPage(selectedItems: selectedItems)),
        );
      } else if (index == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AccountPage(userId: currentUserId,)),
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
          icon: Icon(Icons.shopping_bag),
          label: 'PAY',
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
