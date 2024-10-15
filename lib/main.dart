import 'package:flutter/material.dart';
import 'all_products_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Scaffold(
        appBar: AppBar(
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
                // 장바구니 버튼 클릭 시 동작
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SearchBar(),
              ),
              const SizedBox(height: 16), // 검색 상자와 카테고리 섹션 사이의 간격
              CategorySection(), // 카테고리 섹션 추가
              ProductCategorySection(),
            ],
          ),
        ),
        bottomNavigationBar: BottomMenu(),
      ),
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
                          focusNode: _focusNode, // FocusNode 적용
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
        crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우로 공간을 두기
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
          const SizedBox(height: 16), // 카테고리와 제목 사이의 간격
          SizedBox(
            height: 120, // 카테고리 슬라이드의 높이
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // 가로로 스크롤
              child: Row(
                children: [
                  CategoryItem(title: '카테고리 1', icon: Icons.category),
                  SizedBox(width: 16), // 카테고리 사이의 간격
                  CategoryItem(title: '카테고리 2', icon: Icons.category),
                  SizedBox(width: 16),
                  CategoryItem(title: '카테고리 3', icon: Icons.category),
                  SizedBox(width: 16),
                  CategoryItem(title: '카테고리 4', icon: Icons.category),
                  SizedBox(width: 16),
                  CategoryItem(title: '카테고리 5', icon: Icons.category),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String title;
  final IconData icon;

  const CategoryItem({Key? key, required this.title, required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(16), // 동그란 모서리 설정
          ),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 8), // 카테고리 제목과 상자 사이의 간격
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal, // 가로로 스크롤
            child: Row(
              children: [
                SkeletonProduct(), // 첫 번째 제품 카드
                SkeletonProduct(), // 두 번째 제품 카드
                SkeletonProduct(), // 세 번째 제품 카드
                SkeletonProduct(), // 네 번째 제품 카드
                SkeletonProduct(), // 다섯 번째 제품 카드
                // 필요한 만큼 추가...
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonProduct extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              color: Color(0xFFFAFAFA),
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
                // 사진을 보여주는 컨테이너
                Container(
                  width: 156, // 전체 너비
                  height: 130, // 사진 높이
                  decoration: BoxDecoration(
                    color: Color(0xFFEDEDED), // 사진 배경색
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10)), // 위쪽 모서리 둥글게
                  ),
                  child: Center(
                    child: Text(
                      '사진', // 사진 대신 보여줄 텍스트
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(height: 8), // 사진과 제품 이름 사이의 간격

                // 제품 이름
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0), // 좌우 여백
                  child: Text(
                    '제품 이름', // 제품 이름
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 4), // 제품 이름과 설명 사이의 간격

                // 제품 설명
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0), // 좌우 여백
                  child: Text(
                    '제품 설명이 여기에 들어갑니다.', // 제품 설명
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
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
