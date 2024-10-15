import 'package:flutter/material.dart';

void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

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
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SearchBar(),
            ),
            const SizedBox(height: 16), // 검색 상자와 카테고리 섹션 사이의 간격
            CategorySection(), // 카테고리 섹션 추가
            Expanded(
              child: Center(
                child: Text('Main Content Area'),
              ),
            ),
          ],
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
  bool _isSearchActive = false;

  void _onSearchChanged(String value) {
    setState(() {
      _isSearchActive = value.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    onPressed: _isSearchActive ? () {
                      print('Searching for: ${_controller.text}');
                    } : null,
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
                  // 모두 보기 클릭 시 동작
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
                  CategoryItem(title: '카테고리 1'),
                  SizedBox(width: 16), // 카테고리 사이의 간격
                  CategoryItem(title: '카테고리 2'),
                  SizedBox(width: 16),
                  CategoryItem(title: '카테고리 3'),
                  SizedBox(width: 16),
                  CategoryItem(title: '카테고리 4'),
                  SizedBox(width: 16),
                  CategoryItem(title: '카테고리 5'),
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

  const CategoryItem({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          color: Colors.blue,
          child: Center(
            child: Text(
              title,
              style: TextStyle(color: Colors.white),
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
