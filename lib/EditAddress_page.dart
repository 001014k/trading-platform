import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditAddressPage extends StatefulWidget {
  final Map<String, String> addressData;
  final int index;

  EditAddressPage({required this.addressData, required this.index});

  @override
  _EditAddressPageState createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  late String _recipient;
  late String _phone;
  late String _address;
  late String _detail;

  @override
  void initState() {
    super.initState();
    _recipient = widget.addressData['recipient']!;
    _phone = widget.addressData['phone']!;
    _address = widget.addressData['address']!;
    _detail = widget.addressData['detail']!;
  }

  // 주소 수정 메서드
  Future<void> _updateAddress() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Firestore에 있는 해당 주소 문서 업데이트
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .where('address', isEqualTo: widget.addressData['address'])
          .get();

      for (var doc in snapshot.docs) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('addresses')
            .doc(doc.id)
            .update({
          'recipient': _recipient,
          'phone': _phone,
          'address': _address,
          'detail': _detail,
        });
      }

      // UI에서도 업데이트된 주소 반영
      Navigator.pop(context, {
        'recipient': _recipient,
        'phone': _phone,
        'address': _address,
        'detail': _detail,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
            '주소 수정',
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _recipient,
                decoration: InputDecoration(labelText: '수령인'),
                onSaved: (value) => _recipient = value!,
              ),
              TextFormField(
                initialValue: _phone,
                decoration: InputDecoration(labelText: '전화번호'),
                onSaved: (value) => _phone = value!,
              ),
              TextFormField(
                initialValue: _address,
                decoration: InputDecoration(labelText: '주소'),
                onSaved: (value) => _address = value!,
              ),
              TextFormField(
                initialValue: _detail,
                decoration: InputDecoration(labelText: '상세 주소'),
                onSaved: (value) => _detail = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _updateAddress(); // 주소 업데이트 함수 호출
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: Text(
                    '수정 완료',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
