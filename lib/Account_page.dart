import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trading_platform_app/WishList_page.dart';
import 'package:trading_platform_app/main.dart';

class AccountPage extends StatelessWidget {
  final String userId; // 현재 사용자 ID

  AccountPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('계정 페이지'),
      ),
      body: FutureBuilder<int>(
        future: _getItemCount(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다.'));
          }

          final itemCount = snapshot.data ?? 0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '게시물 수: $itemCount개',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // 로그아웃 기능 구현
                  await FirebaseAuth.instance.signOut();
                  // 로그아웃 후 홈 페이지로 이동
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                },
                child: Text('로그아웃'),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomMenu(),
    );
  }

  // Firestore에서 사용자가 올린 물품의 개수를 가져오는 함수
  Future<int> _getItemCount(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users') // 사용자 컬렉션
        .doc(userId) // 현재 사용자 문서
        .collection('items') // 물품 서브컬렉션
        .get();

    return querySnapshot.docs.length; // 물품 개수 반환
  }
}

class BottomMenu extends StatefulWidget {
  @override
  _BottomMenuState createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  int _selectedIndex = 3;

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
          label: 'ORDER',
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

