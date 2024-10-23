import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'all_products_page.dart';
import 'login_page.dart';
import 'SplashScreen_page.dart';
import 'signup_page.dart';
import 'ForgotPassword_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'WishList_page.dart';
import 'Account_page.dart';
import 'Cart_page.dart';

void main() async {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();

  runApp(const MyApp()); // 앱 실행
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/forgot_password': (context) => ForgotPasswordPage(),
        '/home': (context) => HomePage(),
      },
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
    );
  }
}

// HomePage 클래스 추가
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Trading Mall',
          style: TextStyle(
            color: Color(0xFF3669C9),
            fontSize: 18,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // 알림 버튼 클릭 시 동작
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: () {
              // 장바구니 버튼 클릭 시 카트 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage(userId: userId,)), // CartPage는 카트 페이지의 이름
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SearchBar(),
            ),
            const SizedBox(height: 16), // 검색 상자와 카테고리 섹션 사이의 간격
            CategorySection(), // 카테고리 섹션 추가
            ProductCategorySection(),
          ],
        ),
      ),
      bottomNavigationBar: BottomMenu(),
    );
  }
}

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode(); // FocusNode 추가
  bool _isSearchActive = false;
  bool _showRecentSearches = false; // 최근 검색어 표시 여부

  List<String> recentSearches = [
    'Smartphone',
    'Laptop',
    'Headphones',
    'Camera',
    'Sneakers',
  ]; // 예시로 넣은 최근 검색어

  void _onSearchChanged(String value) {
    setState(() {
      _isSearchActive = value.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();

    // 텍스트 필드에 포커스가 생기면 최근 검색어를 표시
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showRecentSearches = true;
        });
      } else {
        setState(() {
          _showRecentSearches = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose(); // FocusNode 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 50,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  height: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFAFAFA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          focusNode: _focusNode,
                          // FocusNode 적용
                          style: TextStyle(color: Colors.black),
                          controller: _controller,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: '제품을 검색하시오',
                            hintStyle: TextStyle(
                              color: Color(0xFFC4C5C4),
                              fontSize: 14,
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.w500,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                        ),
                        onPressed: _isSearchActive
                            ? () {
                                print('Searching for: ${_controller.text}');
                              }
                            : null,
                        child: const Icon(
                          Icons.search,
                          color: Color(0xFF3669C9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 최근 검색어 리스트 표시
        if (_showRecentSearches)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 10), // 검색창과 간격
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    '최근 검색어',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...recentSearches.map((search) => ListTile(
                      title: Text(search),
                      leading: Icon(Icons.history),
                      onTap: () {
                        // 검색어 클릭 시 동작
                        print('Search for: $search');
                        _controller.text = search;
                        setState(() {
                          _showRecentSearches = false; // 검색어를 클릭하면 리스트 닫기
                        });
                      },
                    )),
              ],
            ),
          ),
      ],
    );
  }
}

class BottomMenu extends StatefulWidget {
  @override
  _BottomMenuState createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  int _selectedIndex = 0;

  // Firebase Authentication에서 현재 사용자 ID 가져오기
  String userId =
      FirebaseAuth.instance.currentUser?.uid ?? 'defaultUserId'; // 기본값은 임의로 설정

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        // Wishlist 버튼이 눌렸을 때
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WishlistPage(
                    userId: userId,
                  )),
        );
      } else if (index == 3) {
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

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '카테고리',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // 모두 보기 클릭 시 하단 시트 표시
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // 최소 크기로 설정
                          children: [
                            Text(
                              '모든 카테고리',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // 카테고리 아이콘을 나열하는 Row
                            Wrap(
                              spacing: 16, // 아이콘 간의 간격
                              runSpacing: 16, // 행 간의 간격
                              children: [
                                CategoryItem(
                                  title: '인기매물',
                                  icon: Icons.favorite,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ProductListPage(keyword: '인기매물')),
                                    );
                                  },
                                ),
                                CategoryItem(
                                  title: '디지털기기',
                                  icon: Icons.computer,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ProductListPage(keyword: '디지털기기')),
                                    );
                                  },
                                ),
                                CategoryItem(
                                  title: '가구/인테리어',
                                  icon: Icons.window,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ProductListPage(keyword: '가구/인테리어')),
                                    );
                                  },
                                ),
                                CategoryItem(
                                  title: '생활가전',
                                  icon: Icons.category,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ProductListPage(keyword: '생활가전')),
                                    );
                                  },
                                ),
                                CategoryItem(
                                  title: '취미/게임/음반',
                                  icon: Icons.sports_esports,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ProductListPage(keyword: '취미/게임/음반')),
                                    );
                                  },
                                ),
                                CategoryItem(
                                  title: '도서',
                                  icon: Icons.book,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ProductListPage(keyword: '도서')),
                                    );
                                  },
                                ),
                                CategoryItem(
                                  title: '생활/주방',
                                  icon: Icons.category,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ProductListPage(keyword: '생활/주방')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Text(
                  '모두 보기',
                  style: TextStyle(
                    color: Color(0xFF3669C9),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CategoryItem(
                      title: '인기매물',
                      icon: Icons.favorite,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ProductListPage(keyword: '인기매물')),
                        );
                      }),
                  SizedBox(width: 16),
                  CategoryItem(
                      title: '디지털기기',
                      icon: Icons.computer,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ProductListPage(keyword: '디지털기기')),
                        );
                      }),
                  SizedBox(width: 16),
                  CategoryItem(
                      title: '가구/인테리어',
                      icon: Icons.window,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ProductListPage(keyword: '가구/인테리어')),
                        );
                      }),
                  SizedBox(width: 16),
                  CategoryItem(
                      title: '생활가전',
                      icon: Icons.category,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ProductListPage(keyword: '생활가전')),
                        );
                      }),
                  SizedBox(width: 16),
                  CategoryItem(
                      title: '취미/게임/음반',
                      icon: Icons.sports_esports,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ProductListPage(keyword: '취미/게임/음반')),
                        );
                      }),
                  SizedBox(width: 16),
                  CategoryItem(
                      title: '도서',
                      icon: Icons.book,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ProductListPage(keyword: '도서')),
                        );
                      }),
                  SizedBox(width: 16),
                  CategoryItem(
                      title: '생활/주방',
                      icon: Icons.category,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ProductListPage(keyword: '생활/주방')),
                        );
                      }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class ProductListPage extends StatelessWidget {
  final String keyword;

  const ProductListPage({Key? key, required this.keyword}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$keyword 제품 목록',
          style: TextStyle(
            color: Color(0xFF3669C9),
            fontSize: 18,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .where('keyword', isEqualTo: keyword)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('검색 결과가 없습니다.'));
            }

            final products = snapshot.data!.docs;

            return SingleChildScrollView( // SingleChildScrollView로 감싸기
              child: Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true, // 그리드 뷰 크기를 조절
                    physics: NeverScrollableScrollPhysics(), // 그리드 뷰 내 스크롤 비활성화
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 한 줄에 두 개의 카드
                      crossAxisSpacing: 16.0, // 카드 사이의 간격
                      mainAxisSpacing: 16.0, // 카드 간의 간격
                      childAspectRatio: 0.7, // 카드 비율 조정
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product =
                      products[index].data() as Map<String, dynamic>;
                      final name = product['name'] ?? '';
                      final description = product['description'] ?? '';
                      final imageUrl = product['imageUrl'] ?? '';
                      final price = product['price'] ?? 0.0;

                      return ProductCard(
                        name: name,
                        description: description,
                        imageUrl: imageUrl,
                        price: price,
                        keyword: keyword,
                      ); // 제품 정보를 카드 형태로 표시
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


class CategoryItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap; // 추가된 onTap 파라미터

  const CategoryItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap, // onTap 파라미터 받기
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // 클릭 이벤트 처리
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCategorySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // 전체 여백 추가
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 카테고리 제목
              Text(
                '제품 목록', // 카테고리 제목
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllProductsPage(), // 모든 제품 페이지로 이동
                    ),
                  );
                },
                child: Text(
                  '모두 보기',
                  style: TextStyle(
                    color: Color(0xFF3669C9),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10), // 제목과 카드 사이의 간격

          // 제품 카드 섹션
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .orderBy('createdAt', descending: true) // 제품 최신순으로 시각화
                .limit(6) // 최대 6개 제품 카드만 표시
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(), // 로딩 인디케이터
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('등록된 제품이 없습니다.')); // 데이터가 없을 때 메시지 표시
              }

              final products = snapshot.data!.docs;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal, // 가로로 스크롤
                child: Row(
                  children: products.map((productDoc) {
                    var productData = productDoc.data() as Map<String, dynamic>;

                    // Firestore에서 불러온 제품 정보
                    String name = productData['name'] ?? '이름 없음';
                    String description = productData['description'] ?? '설명 없음';
                    String imageUrl = productData['imageUrl'] ?? ''; // 이미지 URL
                    int price = productData['price'] ?? 0; // 제품 가격
                    String keyword = productData['keyword'] ?? '키워드 없음';

                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0), // 카드 간의 간격
                      child: ProductCard(
                        name: name,
                        description: description,
                        imageUrl: imageUrl,
                        price: price,
                        keyword: keyword,
                      ), // 각 제품 카드 생성
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final String description;
  final String imageUrl;
  final int price;
  final String keyword;

  const ProductCard({
    Key? key,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.keyword,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedPrice = NumberFormat('#,##0').format(price);

    return Padding(
      padding: const EdgeInsets.only(right: 10.0), // 카드 간의 간격
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
        children: [
          // 제품 카드
          Container(
            width: 156,
            height: 242,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
              children: [
                // 제품 이미지를 보여주는 컨테이너
                Container(
                  width: 156, // 전체 너비
                  height: 130, // 사진 높이
                  decoration: BoxDecoration(
                    color: Color(0xFFEDEDED), // 사진 배경색
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10)), // 위쪽 모서리 둥글게
                    image: DecorationImage(
                      image: NetworkImage(imageUrl), // 제품 이미지 URL로부터 이미지를 가져옴
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 8), // 사진과 제품 이름 사이의 간격

                // 제품 이름
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0), // 좌우 여백
                  child: Text(
                    name, // 제품 이름
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                SizedBox(height: 4), // 제품 이름과 설명 사이의 간격

                // 제품 설명
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0), // 좌우 여백
                  child: Text(
                    description, // 제품 설명
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                SizedBox(height: 4), // 가격 표시 간격

                // 제품 가격
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0), // 좌우 여백
                  child: Text(
                    '₩$formattedPrice', // 포맷팅된 가격 사용
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10), // 제품 카드와 다음 요소 사이의 간격
        ],
      ),
    );
  }
}
