import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage 패키지 추가
import 'package:image/image.dart' as img;
import 'dart:typed_data';


class PostProductPage extends StatefulWidget {
  @override
  _PostProductPageState createState() => _PostProductPageState();
}

class _PostProductPageState extends State<PostProductPage> {
  XFile? _image; // 선택된 이미지를 저장할 변수
  final ImagePicker _picker = ImagePicker(); // 이미지 피커 초기화
  final TextEditingController _priceController = TextEditingController(); // 가격 입력 컨트롤러
  final TextEditingController _nameController = TextEditingController(); // 제품 이름 입력 컨트롤러
  final TextEditingController _descriptionController = TextEditingController(); // 제품 설명 입력 컨트롤러
  List<String> _imageUrls = []; // 이미지 URL을 저장할 리스트

  String? _selectedKeyword; // 선택된 키워드를 저장할 변수
  bool _isLoading = false; // 로딩 상태 표시를 위한 변수

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; // Firebase Storage 초기화

  // 키워드 리스트
  final List<String> _keywords = [
    '디지털기기',
    '가구/인테리어',
    '생활가전',
    '취미/게임/음반',
    '도서',
    '생활/주방'
  ];

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('product_images')
            .child(user.uid)
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        try {
          // 이미지 읽기
          final bytes = await file.readAsBytes();
          img.Image? image = img.decodeImage(Uint8List.fromList(bytes));

          // 이미지 회전
          if (image != null) {
            image = img.copyRotate(image, 90); // 회전 각도 조절 가능

            // 이미지 비율 유지
            final width = 800; // 원하는 너비
            final height = (width * image.height) ~/ image.width;
            image = img.copyResize(image, width: width, height: height);
          }

          // 회전된 이미지를 임시 파일로 저장
          final rotatedFile = File('${file.path}_rotated.jpg')
            ..writeAsBytesSync(img.encodeJpg(image!));

          // Firebase Storage에 업로드
          await storageRef.putFile(rotatedFile);
          final downloadUrl = await storageRef.getDownloadURL();

          setState(() {
            _imageUrls.add(downloadUrl);
          });

          if (pickedFile != null) {
            setState(() {
              _image = pickedFile; // 선택된 이미지를 상태에 저장
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('사진이 추가되었습니다.')),
          );
        } catch (e) {
          print('Error uploading image: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('사진 업로드 중 오류가 발생했습니다.')),
          );
        }
      }
    }
  }



  // Firebase에 제품 정보 업로드
  Future<void> _uploadProduct() async {
    if (_image == null || _priceController.text.isEmpty || _nameController.text.isEmpty || _descriptionController.text.isEmpty || _selectedKeyword == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필드를 입력하고 이미지를 선택하세요.')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // 로딩 시작
    });

    try {
      // Firebase Storage에 이미지 업로드
      String userId = _auth.currentUser!.uid;
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${_image!.name}';
      Reference ref = _storage.ref().child('product_images/$userId/$fileName');
      UploadTask uploadTask = ref.putFile(File(_image!.path));
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});

      // 이미지 URL 가져오기
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Firestore에 제품 정보 저장
      await _firestore.collection('products').add({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': int.parse(_priceController.text),
        'keyword': _selectedKeyword,
        'imageUrl': imageUrl,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 성공 메시지 출력
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제품이 성공적으로 등록되었습니다.')),
      );

      // 폼 초기화
      setState(() {
        _image = null;
        _priceController.clear();
        _nameController.clear();
        _descriptionController.clear();
        _selectedKeyword = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제품 등록에 실패했습니다: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // 로딩 종료
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('제품 올리기', style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontFamily: 'DM Sans',
          fontWeight: FontWeight.w700,
        )),
        backgroundColor: Color(0xFF3669C9),
        elevation: 2,
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white, // 배경색 흰색 유지
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                GestureDetector(
                  onTap: _pickImage, // 컨테이너 클릭 시 이미지 선택
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // 이미지 선택 전 배경을 약간의 회색으로
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _image == null
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 40, color: Colors.grey[600]),
                          SizedBox(height: 8),
                          Text('사진을 선택하세요', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                        ],
                      ),
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_image!.path),
                        fit: BoxFit.cover, // 이미지 비율에 맞게 채우기
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '제품 이름',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: '제품 설명',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  maxLines: 4,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _priceController, // 가격 입력을 위한 컨트롤러
                  decoration: InputDecoration(
                    labelText: '제품 가격',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  keyboardType: TextInputType.number, // 숫자만 입력 가능하도록 설정
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: '키워드를 선택하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  value: _selectedKeyword, // 현재 선택된 키워드
                  dropdownColor: Colors.white,
                  style: TextStyle(color: Colors.black),
                  items: _keywords.map((String keyword) {
                    return DropdownMenuItem<String>(
                      value: keyword,
                      child: Text(
                          keyword,
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedKeyword = newValue; // 선택된 키워드 업데이트
                    });
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _uploadProduct,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('제품 등록', style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w700,
                  )),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Color(0xFF3669C9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
