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
          elevation: 1, // 그림자 효과
          title: Text(
            'Trading Mall',
            style: TextStyle(
              color: Color(0xFF3669C9),
              fontSize: 18,
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true, // 타이틀을 중앙에 위치시킴
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
        body: Column( // Column으로 변경
          children: [
            // 앱바 바로 아래에 검색 상자 위치
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // 적절한 패딩 추가
              child: SearchBar(), // 검색 상자 추가
            ),
            Expanded(
              child: Center(
                child: Text('Main Content Area'), // 나머지 콘텐츠를 위한 영역
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
  bool _isSearchActive = false; // 검색 활성화 상태

  void _onSearchChanged(String value) {
    setState(() {
      _isSearchActive = value.isNotEmpty; // 입력이 있을 경우 활성화
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // 전체 너비 사용
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
                      onChanged: _onSearchChanged, // 입력 변화에 따라 상태 업데이트
                      decoration: InputDecoration(
                        hintText: '제품을 검색하시오',
                        hintStyle: TextStyle(
                          color: Color(0xFFC4C5C4),
                          fontSize: 14,
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none, // 기본 테두리 제거
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero, // 기본 패딩 제거
                      elevation: 0, // 그림자 효과 제거
                      backgroundColor: Colors.transparent, // 배경 투명
                    ),
                    onPressed: _isSearchActive ? () {
                      // 검색 버튼 클릭 시 동작 추가
                      print('Searching for: ${_controller.text}');
                    } : null, // 비활성화 상태에서는 클릭 이벤트 없음
                    child: const Icon(
                      Icons.search,
                      color: Color(0xFF3669C9), // 아이콘 색상
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
      type: BottomNavigationBarType.fixed, // 4개 이상의 버튼을 균일하게 표시
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
