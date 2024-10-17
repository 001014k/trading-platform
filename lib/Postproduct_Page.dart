import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PostProductPage extends StatefulWidget {
  @override
  _PostProductPageState createState() => _PostProductPageState();
}

class _PostProductPageState extends State<PostProductPage> {
  XFile? _image; // 선택된 이미지를 저장할 변수
  final ImagePicker _picker = ImagePicker(); // 이미지 피커 초기화
  final TextEditingController _priceController = TextEditingController(); // 가격 입력 컨트롤러

  // 이미지를 선택하는 메소드
  Future<void> _pickImage() async {
    // 갤러리 접근 권한 요청
    var status = await Permission.photos.request(); // iOS에서 사용할 권한 요청

    // 권한이 허용된 경우에만 이미지 선택
    if (status.isGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery); // 갤러리에서 이미지 선택
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile; // 선택된 이미지로 업데이트
        });
      }
    } else if (status.isDenied) {
      // 권한이 거부된 경우
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('갤러리에 접근할 수 있는 권한이 필요합니다.')),
      );
    } else if (status.isPermanentlyDenied) {
      // 권한이 영구적으로 거부된 경우
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('갤러리에 접근할 수 있는 권한이 필요합니다. 설정에서 권한을 변경해 주세요.'),
          action: SnackBarAction(
            label: '설정',
            onPressed: () {
              openAppSettings(); // 설정 열기
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('제품 올리기'),
        backgroundColor: Color(0xFF3669C9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage, // 컨테이너 클릭 시 이미지 선택
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _image == null
                    ? Center(child: Text('사진을 선택하세요')) // 이미지가 없을 때 텍스트 표시
                    : Image.file(
                  File(_image!.path),
                  fit: BoxFit.cover, // 이미지 비율에 맞게 채우기
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: '제품 이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: '제품 설명',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController, // 가격 입력을 위한 컨트롤러
              decoration: InputDecoration(
                labelText: '제품 가격',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number, // 숫자만 입력 가능하도록 설정
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 제품 올리기 로직 추가
              },
              child: Text('제품 올리기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3669C9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
