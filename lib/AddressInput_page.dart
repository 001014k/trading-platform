import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
    _loadSelectedAddress(); // 선택된 주소 로드
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

  // Firestore에서 선택된 주소를 불러오는 메서드
  Future<void> _loadSelectedAddress() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        _selectedAddress = snapshot['selectedAddress']; // 선택된 주소 로드
      });
    }
  }

  // 선택된 주소를 Firestore에 저장하는 메서드
  Future<void> _saveSelectedAddress(String? address) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'selectedAddress': address}); // 선택된 주소 저장
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
            Text(
                '배송지 목록',
              style: TextStyle(
                color: Color(0xFF3669C9),
                fontSize: 18,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '${address['recipient']}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected ? Colors.green : Colors.black,
                                              ),
                                            ),
                                            if (isSelected)
                                              Icon(Icons.check_circle, color: Colors.green),
                                          ],
                                        ),
                                        Text('${address['phone']}',style: TextStyle(color: Colors.black),),
                                        Text('${address['address']} ${address['detail']}',style: TextStyle(color: Colors.black),),
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
                                      _selectedAddress = isSelected ? null : address['address'];
                                      _saveSelectedAddress(_selectedAddress); // 선택된 주소 상태를 Firestore에 저장
                                    });
                                    Navigator.pop(context, _selectedAddress);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSelected ? Colors.green : Colors.grey,
                                  ),
                                  child: Text(isSelected ? '선택됨' : '선택',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
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
                                icon: Icon(Icons.edit,color: Colors.black,),
                                label: Text(
                                    '수정',
                                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _deleteAddress(index); // 삭제 로직 추가
                                },
                                icon: Icon(Icons.delete,color: Colors.black,),
                                label: Text(
                                    '삭제',
                                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
                                ),
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
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  '새 배송지 추가',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.black),
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

  Future<void> _searchPostalCode() async {
    // 페이지 이동 시 검색 결과를 받기
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostalCodeSearchPage(),
      ),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        _addressController.text = result['address'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          '새 배송지 추가',
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: '도로명 주소',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton( //_searchPostalCode, // 버튼을 누르면 주소 검색 기능 실행
                  onPressed: () async {
                    //주소 검색 페이지로 이동하고 선택한 주소를 받아옴
                    final result = await Navigator.push(
                        context,
                      MaterialPageRoute(builder: (context) => PostalCodeSearchPage()),
                    );
                    if (result != null && result.containsKey('address')) {
                      setState(() {
                        _addressController.text = result['address'];  // 도로명 주소 필드에 값 설정
                      });
                    }
                  },
                  child: Text('우편번호 검색'),
                ),
              ],
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
                  backgroundColor: Colors.blue,
                ),
                child: Text(
                  '주소 저장',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 우편번호 검색 페이지
class PostalCodeSearchPage extends StatefulWidget {
  @override
  _PostalCodeSearchPageState createState() => _PostalCodeSearchPageState();
}

class _PostalCodeSearchPageState extends State<PostalCodeSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _results = [];

  Future<void> searchPostalCode(String query) async {
    final apiKey = 'f072c9394405df675d8e7980d2936d87';  // 발급받은 Kakao REST API 키 사용
    final url = 'https://dapi.kakao.com/v2/local/search/address.json?query=$query';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'KakaoAK $apiKey'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _results = data['documents'];
      });
    } else {
      throw Exception('Failed to load postal codes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('우편번호 검색'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '주소 검색',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                searchPostalCode(_searchController.text);
              },
              child: Text('검색'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final result = _results[index];
                  final roadAddress = result['road_address'];
                  final zoneNo = roadAddress != null ? roadAddress['zone_no'] : '우편번호 없음';
                  return ListTile(
                    title: Text(result['address_name']),
                    subtitle: Text(zoneNo),
                    onTap: () {
                      Navigator.pop(context, {
                        'address': result['address_name'],  // 선택한 주소를 반환
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
