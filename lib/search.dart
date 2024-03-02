import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:toyproject/searchResult.dart';
class WebViewDataParsingScreen extends StatefulWidget {
  @override
  _WebViewDataParsingScreenState createState() =>
      _WebViewDataParsingScreenState();
}

class _WebViewDataParsingScreenState extends State<WebViewDataParsingScreen> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('소 가져오기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: '이력번호를 입력하세요'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String cattleNo = _controller.text;
                _searchCattleHistory(cattleNo);
              },
              child: Text('검색'),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Future<void> _searchCattleHistory(String cattleNo) async {
    final response = await http.get(Uri.parse(
        'https://www.mtrace.go.kr/mtracesearch/cattleNoSearch.do?cattleNo=$cattleNo'));
    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final tdList = document.querySelectorAll('.infTb td');

      if (tdList.length >= 4) {
        String parsedCattleNo = tdList[0].text.trim();
        String parsedBirthdate = tdList[1].text.trim();
        String parsedType = tdList[2].text.trim();
        String parsedGender = tdList[3].text.trim();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResult(
              cattleNo: parsedCattleNo,
              birthdate: parsedBirthdate,
              type: parsedType,
              gender: parsedGender,
            ),
          ),
        );
      } else {
        _showErrorDialog('파싱된 데이터가 올바르지 않습니다.');
      }
    } else {
      _showErrorDialog('데이터를 불러오지 못했습니다.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('오류'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
