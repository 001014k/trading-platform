import 'package:flutter/material.dart';
import 'main.dart';

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 한 줄에 두 개의 카드
                      crossAxisSpacing: 16.0, // 카드 사이의 간격
                      mainAxisSpacing: 16.0, // 카드 간의 간격
                      childAspectRatio: 0.7, // 카드 비율 조정
                    ),
                    itemCount: 20, // 예시로 20개의 제품
                    itemBuilder: (context, index) {
                      return SkeletonProduct(); // 각 제품 카드
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}