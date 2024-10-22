import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailPage extends StatefulWidget {
  final String userId;
  final String id;
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isInWishlist = false;
  int viewCount = 0;
  String? userEmail;
  String? currentUserId; //현재 로그인한 사용자의 id

  @override
  void initState() {
    super.initState();
    fetchCurrentUser(); // 로그인한 사용자 ID 가져오기
    checkWishlistStatus();
    fetchAndIncrementViewCount(); // 조회수 증가 및 가져오기
    fetchUserEmail();
  }

  // Firebase Authentication에서 현재 로그인한 사용자 ID 가져오기
  Future<void> fetchCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid; // 로그인한 사용자 ID 저장
      });
    }
  }

  Future<void> fetchUserEmail() async {
    // 1. products 컬렉션에서 제품 고유 번호로 해당 제품 문서를 가져옴
    final productSnapshot = await _firestore.collection('products').doc(widget.id).get();

    if (productSnapshot.exists) {
      // 2. 해당 제품 문서에서 userId 필드를 가져옴
      String userId = productSnapshot.data()?['userId'];

      // 3. 가져온 userId를 사용하여 users 컬렉션에서 판매자의 이메일을 조회
      final userSnapshot = await _firestore.collection('users').doc(userId).get();
      if (userSnapshot.exists) {
        setState(() {
          userEmail = userSnapshot.data()?['email']; // 판매자의 이메일을 저장
        });
      }
    }
  }

  Future<void> checkWishlistStatus() async {
    final wishlistSnapshot = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('wishlists')
        .doc(widget.id)
        .get();

    setState(() {
      isInWishlist = wishlistSnapshot.exists;
    });
  }

  // Firestore에서 조회수 가져오기 및 업데이트하는 함수
  Future<void> fetchAndIncrementViewCount() async {
    final productRef = _firestore.collection('products').doc(widget.id);
    final productSnapshot = await productRef.get();

    if (productSnapshot.exists) {
      viewCount = productSnapshot.data()?['viewCount'] ?? 0;
      viewCount++;
      await productRef.update({'viewCount': viewCount});
      setState(() {}); // UI 업데이트
    }
  }

  Future<void> toggleWishlist() async {
    // 로그인한 사용자의 userId를 가져옴 (currentUserId 사용)
    final userWishlistRef = _firestore
        .collection('users')
        .doc(currentUserId) // widget.userId 대신 currentUserId 사용
        .collection('wishlists')
        .doc(widget.id);

    if (isInWishlist) {
      // 위시리스트에서 삭제
      await userWishlistRef.delete();
      setState(() {
        isInWishlist = false;
      });
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
      setState(() {
        isInWishlist = true;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
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
            widget.imageUrl.isNotEmpty
                ? Image.network(widget.imageUrl, fit: BoxFit.cover)
                : Container(
              height: 200,
              color: Colors.grey[200],
              child: Icon(Icons.image_not_supported, size: 100),
            ),
            SizedBox(height: 16),
            Text(widget.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Divider(thickness: 1, color: Colors.grey[300]),
            SizedBox(height: 8),
            Text(widget.description, style: TextStyle(fontSize: 16)),
            Divider(thickness: 1, color: Colors.grey[300]),
            SizedBox(height: 8),
            Row(
              children: [
                Text('키워드:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Text(widget.keyword, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
              ],
            ),
            Divider(thickness: 1, color: Colors.grey[300]),
            SizedBox(height: 8),
            Row(
              children: [
                Text('₩$formattedPrice', style: TextStyle(fontSize: 20, color: Colors.blueAccent)),
              ],
            ),
            SizedBox(height: 16),
            if (userEmail != null) ...[
              Text('판매자 이메일: $userEmail', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
              SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(isInWishlist ? Icons.favorite : Icons.favorite_border, color: isInWishlist ? Colors.red : Colors.grey),
                    SizedBox(width: 8),
                    Text(isInWishlist ? '위시리스트에 추가됨' : '위시리스트에 추가', style: TextStyle(fontSize: 16)),
                  ],
                ),
                Text('조회수: $viewCount', style: TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
