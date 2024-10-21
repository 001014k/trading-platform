import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final String name;
  final String description;
  final String imageUrl;
  final int price;
  final String keyword;

  ProductDetailPage({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.keyword,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          '제품 정보',
          style: TextStyle(
            color: Color(0xFF3669C9),
            fontSize: 18,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제품 이미지
            imageUrl.isNotEmpty
                ? Image.network(imageUrl, fit: BoxFit.cover)
                : Container(
              height: 200,
              color: Colors.grey[200],
              child: Icon(Icons.image_not_supported, size: 100),
            ),
            SizedBox(height: 16),

            // 제품 이름
            Text(
              name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Divider(thickness: 1, color: Colors.grey[300]), // 구분선
            SizedBox(height: 8),

            // 제품 설명
            Text(
              description,
              style: TextStyle(fontSize: 16),
            ),
            Divider(thickness: 1, color: Colors.grey[300]), // 구분선
            SizedBox(height: 8),

            // 키워드
            Text(
              '키워드:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              keyword,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            Divider(thickness: 1, color: Colors.grey[300]), // 구분선
            SizedBox(height: 8),

            // 가격
            Text(
              '가격:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '₩$price',
              style: TextStyle(fontSize: 20, color: Colors.blueAccent),
            ),
          ],
        ),
      ),
    );
  }
}
