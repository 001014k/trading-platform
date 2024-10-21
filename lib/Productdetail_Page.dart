import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 패키지 추가

class ProductDetailPage extends StatefulWidget {
  final String userId; // 로그인한 사용자 ID
  final String id; // 고유 ID
  final String name;
  final String description;
  final String imageUrl;
  final int price;
  final String keyword;

  ProductDetailPage({
    required this.userId,
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.keyword,
  });

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore 인스턴스
  bool isInWishlist = false; // 위시리스트 상태 변수
  int viewCount = 0; // 조회수 변수

  @override
  void initState() {
    super.initState();
    checkWishlistStatus(); // 위시리스트 상태 체크
    incrementViewCount(); // 페이지가 로드될 때 조회수 증가
  }

  // 위시리스트 상태 체크 함수
  Future<void> checkWishlistStatus() async {
    final wishlistSnapshot = await _firestore
        .collection('users')
        .doc(widget.userId) // 사용자 ID로 문서 참조
        .collection('wishlists')
        .doc(widget.id)
        .get();

    setState(() {
      isInWishlist = wishlistSnapshot.exists; // 문서가 존재하면 위시리스트에 추가된 상태
    });
  }

  // 조회수 증가 함수
  void incrementViewCount() {
    setState(() {
      viewCount++; // 조회수를 1 증가
    });
  }

  // 위시리스트 추가/삭제 함수
  Future<void> toggleWishlist() async {
    final userWishlistRef = _firestore.collection('users').doc(widget.userId).collection('wishlists').doc(widget.id);

    if (isInWishlist) {
      // 위시리스트에서 제거
      await userWishlistRef.delete();
      isInWishlist = false;
    } else {
      // 위시리스트에 추가
      await userWishlistRef.set({
        'productId': widget.id,
        'name': widget.name,
        'description': widget.description,
        'imageUrl': widget.imageUrl,
        'price': widget.price,
        'keyword': widget.keyword,
        'createdAt': FieldValue.serverTimestamp(),
      });
      isInWishlist = true;
    }

    setState(() {}); // 상태 업데이트
  }

  @override
  Widget build(BuildContext context) {
    // 가격 포맷팅
    String formattedPrice = NumberFormat('#,##0').format(widget.price);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Center(
          child: Text(
            '제품 정보',
            style: TextStyle(
              color: Color(0xFF3669C9),
              fontSize: 18,
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? Colors.red : Colors.grey,
            ),
            onPressed: toggleWishlist,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제품 이미지
            widget.imageUrl.isNotEmpty
                ? Image.network(widget.imageUrl, fit: BoxFit.cover)
                : Container(
              height: 200,
              color: Colors.grey[200],
              child: Icon(Icons.image_not_supported, size: 100),
            ),
            SizedBox(height: 16),

            // 제품 이름
            Text(
              widget.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Divider(thickness: 1, color: Colors.grey[300]),
            SizedBox(height: 8),

            // 제품 설명
            Text(
              widget.description,
              style: TextStyle(fontSize: 16),
            ),
            Divider(thickness: 1, color: Colors.grey[300]),
            SizedBox(height: 8),

            // 키워드
            Row(
              children: [
                Text(
                  '키워드:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Text(
                  widget.keyword,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
            Divider(thickness: 1, color: Colors.grey[300]),
            SizedBox(height: 8),

            // 가격
            Row(
              children: [
                Text(
                  '₩$formattedPrice',
                  style: TextStyle(fontSize: 20, color: Colors.blueAccent),
                ),
              ],
            ),
            SizedBox(height: 16),

            // 위시리스트 및 조회 카운트 섹션
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isInWishlist ? Icons.favorite : Icons.favorite_border,
                      color: isInWishlist ? Colors.red : Colors.grey,
                    ),
                    SizedBox(width: 8),
                    Text(
                      isInWishlist ? '위시리스트에 추가됨' : '위시리스트에 추가',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Text(
                  '조회수: $viewCount',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
