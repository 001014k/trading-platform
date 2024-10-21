import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      routes: {
        '/home': (context) => HomePage(),
        '/order': (context) => OrderPage(),
        '/account': (context) => AccountPage(),
      },
    );
  }
}


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
            '위시리스트',
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      // 각 아이템을 눌렀을 때의 동작 설정
      if (index == 0) {
        // 홈 페이지로 이동
        Navigator.pushNamed(context, '/home');
      } else if (index == 1) {
        // 현재 페이지는 Wishlist이므로 아무 동작도 하지 않음
      } else if (index == 2) {
        // 주문 페이지로 이동
        Navigator.pushNamed(context, '/order');
      } else if (index == 3) {
        // 계정 페이지로 이동
        Navigator.pushNamed(context, '/account');
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

// 홈 페이지
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('홈 페이지'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // 샘플 제품 데이터
            final item = {
              'name': '제품 1',
              'description': '이것은 제품 1입니다.',
              'imageUrl': 'https://via.placeholder.com/150',
              'price': 20000,
            };

            // 위시리스트에 추가
            final prefs = await SharedPreferences.getInstance();
            List<String>? wishlistJson = prefs.getStringList('wishlist') ?? [];
            wishlistJson.add(jsonEncode(item)); // Map을 JSON 문자열로 변환하여 추가
            await prefs.setStringList('wishlist', wishlistJson);

            // 위시리스트 페이지로 이동
            Navigator.pushNamed(context, '/wishlist', arguments: item);
          },
          child: Text('위시리스트에 제품 추가'),
        ),
      ),
    );
  }
}

// 주문 페이지
class OrderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주문 페이지'),
      ),
      body: Center(
        child: Text('여기는 주문 페이지입니다.'),
      ),
    );
  }
}

// 계정 페이지
class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('계정 페이지'),
      ),
      body: Center(
        child: Text('여기는 계정 페이지입니다.'),
      ),
    );
  }
}
