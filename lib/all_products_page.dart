import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'postproduct_page.dart';
import 'Productdetail_Page.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

final user = FirebaseAuth.instance.currentUser;
final String currentUserId = user?.uid ?? ''; // 현재 사용자 ID를 가져옴
class AllProductsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '모든 제품',
          style: TextStyle(
            color: Color(0xFF3669C9),
            fontSize: 18,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Color(0xFF3669C9)), // 플러스 아이콘 추가
            onPressed: () {
              // 제품을 올리는 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostProductPage(), // 게시물 페이지로 이동
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          // Firestore의 'products' 컬렉션에서 데이터 가져옴
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child:
                      CircularProgressIndicator()); // 데이터를 로드하는 동안 로딩 인디케이터 표시
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('등록된 제품이 없습니다.')); // 데이터가 없을 때 메시지 표시
            }

            final products = snapshot.data!.docs;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 한 줄에 두 개의 카드
                crossAxisSpacing: 16.0, // 카드 사이의 간격
                mainAxisSpacing: 16.0, // 카드 간의 간격
                childAspectRatio: 0.7, // 카드 비율 조정
              ),
              itemCount: products.length, // Firestore에서 가져온 제품 수
              itemBuilder: (context, index) {
                var productData =
                    products[index].data() as Map<String, dynamic>;

                // Firestore에서 불러온 제품 정보
                String id = products[index].id; // Firestore의 문서 ID 가져오기
                String name = productData['name'] ?? '이름 없음';
                String description = productData['description'] ?? '설명 없음';
                String imageUrl = productData['imageUrl'] ?? ''; // 이미지 URL
                int price = productData['price'] ?? 0; // 제품 가격
                String keyword = productData['keyword'] ?? '키워드 없음';

                return ProductCard(
                  id: id,
                  name: name,
                  description: description,
                  imageUrl: imageUrl,
                  price: price,
                  keyword: keyword,
                ); // 제품 정보를 카드 형태로 표시
              },
            );
          },
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int price;
  final String keyword;

  ProductCard({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.keyword,
  });

  @override
  Widget build(BuildContext context) {
    // 가격 포맷팅
    String formattedPrice = NumberFormat('#,##0').format(price);

    return InkWell(
      onTap: () {
        // 제품 카드 클릭 시 상세 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              userId: currentUserId, // 로그인한 사용자 ID를 전달
              id: id,
              name: name,
              description: description,
              imageUrl: imageUrl,
              price: price,
              keyword: keyword,
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: 100,
                      color: Colors.grey[200],
                      child: Icon(Icons.image_not_supported,
                          color: Colors.grey, size: 50),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '₩$formattedPrice', // 포맷팅된 가격 사용
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
