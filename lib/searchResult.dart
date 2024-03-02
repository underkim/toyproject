import 'package:flutter/material.dart';
import 'package:toyproject/database_helper.dart';


class SearchResult extends StatelessWidget {
  final String? cattleNo;
  final String? birthdate;
  final String? type;
  final String? gender;

  const SearchResult({
    Key? key,
    this.cattleNo,
    this.birthdate,
    this.type,
    this.gender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('파싱된 데이터'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _saveData(context); // 데이터 저장 함수 호출
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('이력번호: ${cattleNo ?? '없음'}'),
            Text('출생년월일: ${birthdate ?? '없음'}'),
            Text('소의 종류: ${type ?? '없음'}'),
            Text('성별: ${gender ?? '없음'}'),
          ],
        ),
      ),
    );
  }

  // 데이터 저장 함수
  void _saveData(BuildContext context) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.open();

    // 파싱된 데이터 저장
    await dbHelper.addBasicInfo(cattleNo!, birthdate!, type!, gender!);

    // 저장 완료 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('데이터 저장 완료'),
      ),
    );
    Navigator.pop(context);
  }
}
