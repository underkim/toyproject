import 'package:flutter/material.dart';
import 'package:toyproject/DataSearch.dart';
import 'package:toyproject/search.dart';
import 'package:toyproject/database_helper.dart';

import 'detail.dart';

void main() {

  runApp(MyApp());
} // MyApp() 실행

class MyApp extends StatelessWidget {
  // 상태가 변하지 않는 MyApp 생성
  final DatabaseHelper _db = DatabaseHelper(); // DBHelper 클래스 생성

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '소오는 누가키워',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(databaseHelper: _db), //
    );
  }
}

class MyHomePage extends StatefulWidget {
  final DatabaseHelper databaseHelper;

  MyHomePage({required this.databaseHelper});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Map<String, dynamic>> _basicInfoList;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _basicInfoList = [];
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      await widget.databaseHelper.open(); // 데이터헬퍼 클래스 오픈 함수 호출
      List<Map<String, dynamic>> tempList =
          await widget.databaseHelper.getBasicInfo(); // 데이터헬퍼 클래스의 기본정보함수 호출
      setState(() {
        _basicInfoList = tempList; // 데이터리스트 삽입
        _isLoading = false; // 데이터 로딩이 완료되었음을 표시
      });
    } catch (e) {
      print('Error initializing database: $e');
      // 데이터베이스 초기화에 실패한 경우 사용자에게 메시지 표시 또는 예외 처리 로직 추가
    }
  }

  // 데이터 로딩 함수
  void loadData() async {
    try {
      List<Map<String, dynamic>> tempList =
          await widget.databaseHelper.getBasicInfo();
      setState(() {
        _basicInfoList = tempList;
      });
    } catch (e) {
      print('Error loading data: $e');
      // 데이터 로딩 중 에러 발생 시 처리할 내용 추가
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 최상단 부분
        title: Row(
          children: [
            Expanded(
              child: Text('소 리스트'),
            ),
          ],
        ),
        actions: [
            /*IconButton(
            icon: Icon(Icons.settings), // 설정 버튼 아이콘
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(),
                  ),
              );
            },
          ), */
          IconButton(   // 상단 검색 버튼
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: DataSearch(databaseHelper: widget.databaseHelper),
              );
            },
          ),
        ],
      ),
      body: _isLoading // 로딩을 했으면
          ? Center(
              // 센터
              child: CircularProgressIndicator(), // 데이터 로딩 중일 때 표시될 위젯
            )
          : _basicInfoList.isNotEmpty
              ? ListView.builder(
                  itemCount: (_basicInfoList.length / 2).ceil(),
                  // 아이템 개수를 2로 나눈 후 올림하여 반올림
                  itemBuilder: (context, index) {
                    final firstIndex = index * 2;
                    final secondIndex = firstIndex + 1;
                    return Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width /
                              2, // 화면의 절반 크기
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2, // 테두리 두께
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            
                            child: ListTile(
                              title: Text(
                                _basicInfoList[firstIndex]['cattleNo'],
                                style: TextStyle(fontSize: 12),
                              ),
                              subtitle: Text("별명: " +
                                  _basicInfoList[firstIndex]['nickName'] +
                                  "\n" +
                                  _basicInfoList[firstIndex]['birthdate']),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailInfoPage(
                                      cattleNo: _basicInfoList[firstIndex]
                                          ['cattleNo'],
                                    ),
                                  ),
                                );
                                _refreshData(); // 돌아올때 데이터 갱신
                              },
                            ),
                          ),
                        ),
                        if (secondIndex < _basicInfoList.length)
                          SizedBox(
                            width: MediaQuery.of(context).size.width /
                                2, // 화면의 절반 크기
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2, // 테두리 두께
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListTile(
                                title: Text(
                                  _basicInfoList[secondIndex]['cattleNo'],
                                  style: TextStyle(fontSize: 12),
                                ),
                                subtitle: Text("별명: " +
                                    _basicInfoList[secondIndex]['nickName'] +
                                    "\n" +
                                    _basicInfoList[secondIndex]['birthdate']),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailInfoPage(
                                        cattleNo: _basicInfoList[secondIndex]
                                            ['cattleNo'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                )
              : Center(
                  child: Text('데이터가 없습니다.'),
                ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              // 검색 화면으로 이동
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WebViewDataParsingScreen()),
              );
              _refreshData();
            },
            child: Icon(Icons.search),
          ),
          SizedBox(height: 16), // 버튼 간 간격 조절
          FloatingActionButton(
            onPressed: () {
              _refreshData();
            },
            child: Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

// 데이터 새로고침 함수
  void _refreshData() async {
    setState(() {
      _isLoading = true; // 데이터 로딩 상태로 변경
    });
    try {
      List<Map<String, dynamic>> tempList =
          await widget.databaseHelper.getBasicInfo();
      setState(() {
        _basicInfoList = tempList;
        _isLoading = false; // 데이터 로딩이 완료되었음을 표시
      });
    } catch (e) {
      print('Error refreshing data: $e');
      // 데이터 새로고침 중 에러 발생 시 처리할 내용 추가
      setState(() {
        _isLoading = false; // 데이터 로딩 실패 상태로 변경
      });
    }
  }
}
