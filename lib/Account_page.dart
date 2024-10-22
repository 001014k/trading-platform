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
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Account',
          style: TextStyle(
            color: Color(0xFF3669C9),
            fontSize: 18,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
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

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 게시물 수를 표시하는 카드
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '게시물 수',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3669C9),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '$itemCount개',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40),
                // 로그아웃 버튼
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3669C9), // 버튼 배경색
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24), // 패딩
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // 둥근 모서리
                    ),
                  ),
                  onPressed: () async {
                    // 로그아웃 기능 구현
                    await FirebaseAuth.instance.signOut();
                    // 로그아웃 후 홈 페이지로 이동
                    Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
                  },
                  child: Text(
                    '로그아웃',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white, // 텍스트 색상
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomMenu(),
    );
  }

  // Firestore에서 사용자가 올린 물품의 개수를 가져오는 함수
  Future<int> _getItemCount(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('products') // 'products' 컬렉션으로 변경
        .where('userId', isEqualTo: userId) // userId 필드로 필터링
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
