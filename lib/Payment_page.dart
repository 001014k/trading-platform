import 'package:flutter/material.dart';
import 'AddressInput_page.dart';

class PaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems; // Add this line

  PaymentPage({required this.selectedItems, this.selectedAddress}); // Remove final from selectedAddress

  final String? selectedAddress; // Move this line up here

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? _userAddress; // 초기 주소

  @override
  void initState() {
    super.initState();
    _userAddress = widget.selectedAddress; // 선택된 주소 초기화
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = 0.0; // To calculate total price from selected items

    return Scaffold(
      appBar: AppBar(
        title: Text('결제하기'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 배송 정보 섹션
            Text(
              '배송 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text(_userAddress ?? '주소를 선택하세요'),
              subtitle: Text('010-1234-5678'),
              trailing: Icon(Icons.edit, color: Colors.blue),
              onTap: () async {
                // 주소 입력 페이지로 이동하고 입력된 주소 받아오기
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddressInputPage(),
                  ),
                );

                if (result != null) {
                  setState(() {
                    _userAddress = result; // 선택된 주소 업데이트
                  });
                }
              },
            ),
            Divider(),

            // 결제 수단 섹션
            Text(
              '결제 수단',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.credit_card),
              title: Text('신용카드'),
              trailing: DropdownButton<String>(
                items: [
                  DropdownMenuItem(
                    value: 'card',
                    child: Text('신용카드'),
                  ),
                  DropdownMenuItem(
                    value: 'naver_pay',
                    child: Text('네이버페이'),
                  ),
                ],
                onChanged: (String? value) {
                  // 결제 수단 변경 로직
                },
                hint: Text('결제 수단 선택'),
              ),
            ),
            Divider(),

            // 상품 정보 섹션
            Text(
              '상품 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Column(
              children: widget.selectedItems.map((item) {
                totalPrice += item['productPrice']; // Calculate total price
                return ListTile(
                  title: Text(item['productName']),
                  subtitle: Text('₩${item['productPrice'].toString()}'),
                  trailing: Text('수량: 1'),
                );
              }).toList(),
            ),
            Divider(),

            // 총 결제 금액 섹션
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '총 결제 금액',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '₩${totalPrice.toString()}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
            SizedBox(height: 16),

            // 결제 버튼
            SizedBox(
              width: double.infinity, // 버튼이 화면 전체 너비를 차지하도록
              child: ElevatedButton(
                onPressed: () {
                  // 결제 처리 로직
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green, // 네이버 스타일의 결제 버튼 색상
                ),
                child: Text(
                  '결제하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
