import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Cart_page.dart';
import 'dart:ui';

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
  bool isBidConfirmed = false; // 입찰 확정 여부 상태 추가
  bool isInWishlist = false;
  int viewCount = 0;
  String? userEmail;
  String? productOwnerId; // 제품을 올린 사용자 ID 저장
  String? currentUserId; // 현재 로그인한 사용자의 ID

  // 입찰 확정이 되었을 때 호출하는 함수
  void confirmBid() {
    setState(() {
      isBidConfirmed = true;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCurrentUser(); // 로그인한 사용자 ID 가져오기
    checkWishlistStatus();
    fetchAndIncrementViewCount(); // 조회수 증가 및 가져오기
    fetchUserEmail(); // 판매자의 이메일 가져오기
    fetchProductOwnerId(); // 제품을 올린 사용자 ID 가져오기
    fetchBidConfirmedStatus(); // Firestore에서 입찰 확정 상태 가져오기
  }

  // Firestore에서 입찰 확정 상태를 불러오는 함수
  Future<void> fetchBidConfirmedStatus() async {
    final productSnapshot =
        await _firestore.collection('products').doc(widget.id).get();
    if (productSnapshot.exists) {
      setState(() {
        isBidConfirmed = productSnapshot.data()?['isBidConfirmed'] ?? false;
      });
    }
  }

  // 입찰 확정 상태를 Firestore에 저장하는 함수
  Future<void> confirmBidInFirestore() async {
    await _firestore.collection('products').doc(widget.id).update({
      'isBidConfirmed': true, // 입찰 확정 상태 저장
    });
    setState(() {
      isBidConfirmed = true;
    });
  }

  Future<void> fetchProductOwnerId() async {
    final productSnapshot =
        await _firestore.collection('products').doc(widget.id).get();

    if (productSnapshot.exists) {
      setState(() {
        productOwnerId = productSnapshot.data()?['userId']; // 제품을 올린 사용자 ID 저장
      });
    }
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
    final productSnapshot =
        await _firestore.collection('products').doc(widget.id).get();

    if (productSnapshot.exists) {
      // 2. 해당 제품 문서에서 userId 필드를 가져옴
      String userId = productSnapshot.data()?['userId'];

      // 3. 가져온 userId를 사용하여 users 컬렉션에서 판매자의 이메일을 조회
      final userSnapshot =
          await _firestore.collection('users').doc(userId).get();
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

  // 사용자가 입력한 금액을 Firestore에 저장하는 함수
  Future<void> submitUserPrice(String userPriceInput) async {
    if (userPriceInput.isNotEmpty && currentUserId != null) {
      String? email =
          FirebaseAuth.instance.currentUser?.email; // 현재 사용자의 이메일 가져오기
      if (email != null) {
        // 이메일이 null이 아닐 때만 저장
        await _firestore
            .collection('products')
            .doc(widget.id)
            .collection('offers')
            .add({
          'userId': currentUserId,
          'userEmail': email, // 사용자의 이메일 추가
          'price': double.tryParse(userPriceInput) ?? 0.0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        print("사용자 이메일을 가져오는 데 실패했습니다.");
      }
    } else {
      print("입찰 금액이나 사용자 ID가 null입니다.");
    }
  }

  void _showBidDialog() {
    String userPriceInput = ""; // 대화 상자에서 사용할 입력값

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '입찰 금액',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '입찰 금액',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              userPriceInput = value; // 입력한 금액 저장
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                submitUserPrice(userPriceInput); // 입력된 금액 제출
                Navigator.of(context).pop(); // 대화 상자 닫기
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                // 배경색 설정
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                // 패딩 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // 둥근 모서리 설정
                ),
              ),
              child: Text(
                '제출',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // 대화 상자 닫기
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                // 배경색 설정
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                // 패딩 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // 둥근 모서리 설정
                ),
              ),
              child: Text(
                '취소',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmBidDialog(String offerPrice, String bidderUserId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('입찰 확정',style: TextStyle(fontWeight: FontWeight.bold),),
          content: Text('입찰 금액: $offerPrice\n\n이 입찰을 확정하시겠습니까?'),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                // 배경색 설정
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                // 패딩 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // 둥근 모서리 설정
                ),
              ),
              onPressed: () async {
                await confirmBidInFirestore(); // 입찰 확정 상태를 Firestore에 저장
                addToCart(offerPrice, bidderUserId); // 장바구니에 추가
                Navigator.of(context).pop(); // 대화 상자 닫기
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartPage(userId: bidderUserId),
                  ), // 장바구니 페이지로 이동
                );
              },
              child: Text('확정', style: TextStyle(color: Colors.black),),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                // 배경색 설정
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                // 패딩 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // 둥근 모서리 설정
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // 대화 상자 닫기
              },
              child: Text('취소', style: TextStyle(color: Colors.black),),
            ),
          ],
        );
      },
    );
  }

  Future<void> addToCart(String offerPrice, String bidderUserId) async {
    if (bidderUserId != null) {
      // 입찰한 사용자 ID가 null이 아닐 경우
      await _firestore
          .collection('users')
          .doc(bidderUserId) // 입찰한 사용자의 ID로 장바구니에 추가
          .collection('cart')
          .add({
        'productId': widget.id,
        'productName': widget.name,
        'productPrice':
            double.tryParse(offerPrice.replaceAll(RegExp(r'[^\d]'), '')) ??
                0.0, // 가격에서 ₩ 제거
        'createdAt': FieldValue.serverTimestamp(),
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
      body: Stack(
        children: [
          SingleChildScrollView(
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
                Text(widget.name,
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Divider(thickness: 1, color: Colors.grey[300]),
                SizedBox(height: 8),
                Text(widget.description, style: TextStyle(fontSize: 16)),
                Divider(thickness: 1, color: Colors.grey[300]),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('키워드:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Text(widget.keyword,
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey[700])),
                  ],
                ),
                Divider(thickness: 1, color: Colors.grey[300]),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('₩$formattedPrice',
                        style:
                            TextStyle(fontSize: 20, color: Colors.blueAccent)),
                  ],
                ),
                SizedBox(height: 16),
                if (userEmail != null) ...[
                  Text('판매자 이메일: $userEmail',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                  SizedBox(height: 8),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                            isInWishlist
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isInWishlist ? Colors.red : Colors.grey),
                        SizedBox(width: 8),
                        Text(isInWishlist ? '위시리스트에 추가됨' : '위시리스트에 추가',
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    Text('조회수: $viewCount', style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(height: 16),

                // 입찰하기 섹션
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          '입찰하기',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _showBidDialog,
                            child: Text(
                              '입찰 금액 입력',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // 입찰 내역 섹션
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          '입찰 내역',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('products')
                            .doc(widget.id)
                            .collection('offers')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return CircularProgressIndicator();
                          }

                          return Column(
                            children: snapshot.data!.docs.map((offer) {
                              final offerData =
                                  offer.data() as Map<String, dynamic>?;
                              final offerUserEmail =
                                  offerData?['userEmail'] ?? '알 수 없는 사용자';
                              final offerPrice = offerData?['price'] != null
                                  ? '₩${NumberFormat('#,##0').format(offerData!['price'])}'
                                  : '금액 없음';
                              final bidderUserId = offerData?['userId'];

                              return GestureDetector(
                                onTap: () {
                                  if (currentUserId == productOwnerId) {
                                    _showConfirmBidDialog(
                                        offerPrice, bidderUserId);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text('입찰 확정 권한이 없습니다.')),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(offerUserEmail,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black)),
                                      Text(offerPrice,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black)),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isBidConfirmed)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // 흐림 효과
              child: Container(
                color: Colors.black.withOpacity(0.5), // 어두운 배경
                alignment: Alignment.center,
                child: Text(
                  '입찰 확정',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
