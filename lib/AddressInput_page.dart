import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddressInputPage extends StatefulWidget {
  @override
  _AddressInputPageState createState() => _AddressInputPageState();
}

class _AddressInputPageState extends State<AddressInputPage> {
  List<Map<String, String>> _addresses = []; // 배송지 목록 초기화
  String? _selectedAddress; // 선택된 주소

  @override
  void initState() {
    super.initState();
    _loadAddresses(); // 초기 주소 로드
  }

  // Firestore에서 주소를 로드하는 메서드
  Future<void> _loadAddresses() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .get();

      setState(() {
        _addresses = snapshot.docs.map((doc) => {
          'address': doc['address'] as String, // String으로 변환
          'detail': doc['detail'] as String,   // String으로 변환
          'recipient': doc['recipient'] as String, // String으로 변환
          'phone': doc['phone'] as String,     // String으로 변환
        }).toList();
      });
    }
  }

  // 주소 삭제 및 수정 함수
  void _deleteAddress(int index) { /* ... */ }
  void _editAddress(int index) { /* ... */ }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('배송지 목록'),
            if (_selectedAddress != null)
              Text(
                '선택된 주소: $_selectedAddress',
                style: TextStyle(fontSize: 12),
              ),
          ],
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _addresses.length,
                itemBuilder: (context, index) {
                  final address = _addresses[index];
                  final isSelected = _selectedAddress == address['address'];

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '${address['recipient']}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? Colors.green
                                                    : Colors.black,
                                              ),
                                            ),
                                            if (isSelected)
                                              Icon(Icons.check_circle,
                                                  color: Colors.green),
                                          ],
                                        ),
                                        Text('${address['phone']}'),
                                        Text(
                                            '${address['address']} ${address['detail']}'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedAddress = isSelected
                                          ? null
                                          : address['address'];
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSelected
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  child: Text(isSelected ? '선택됨' : '선택'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  _editAddress(index); // 수정 로직 추가
                                },
                                icon: Icon(Icons.edit),
                                label: Text('수정'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _deleteAddress(index); // 삭제 로직 추가
                                },
                                icon: Icon(Icons.delete),
                                label: Text('삭제'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // 새 주소 추가 페이지로 이동
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewAddressPage()),
                  );

                  // 새 주소가 반환되면 목록 업데이트
                  if (result != null) {
                    _loadAddresses(); // 주소 목록 새로 고침
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  '새 배송지 추가',
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

// 새 배송지 추가 페이지 (주소 입력 화면)
class NewAddressPage extends StatefulWidget {
  @override
  _NewAddressPageState createState() => _NewAddressPageState();
}

class _NewAddressPageState extends State<NewAddressPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새 배송지 추가'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _recipientController,
              decoration: InputDecoration(
                labelText: '수령인 이름',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: '전화번호',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: '도로명 주소',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _detailController,
              decoration: InputDecoration(
                labelText: '상세 주소 (예: 101호)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_recipientController.text.isNotEmpty &&
                      _phoneController.text.isNotEmpty &&
                      _addressController.text.isNotEmpty &&
                      _detailController.text.isNotEmpty) {
                    User? user = FirebaseAuth.instance.currentUser;

                    if (user != null) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('addresses')
                          .add({
                        'address': _addressController.text,
                        'detail': _detailController.text,
                        'recipient': _recipientController.text,
                        'phone': _phoneController.text,
                      });

                      // 새 주소 정보를 반환하여 주소 목록에 추가하게 함
                      Navigator.pop(context, {
                        'address': _addressController.text,
                        'detail': _detailController.text,
                        'recipient': _recipientController.text,
                        'phone': _phoneController.text,
                      });
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('모든 필드를 입력하세요.'),
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                child: Text(
                  '주소 저장',
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

