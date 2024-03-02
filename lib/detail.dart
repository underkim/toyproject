import 'package:flutter/material.dart';
import 'package:toyproject/database_helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DetailInfoPage extends StatefulWidget {
  final String cattleNo;

  DetailInfoPage({
    required this.cattleNo,
  });

  @override
  _DetailInfoPageState createState() => _DetailInfoPageState();
}

class _DetailInfoPageState extends State<DetailInfoPage> {
  late Future<Map<String, dynamic>> _futureData;

  DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _futureData = _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureData, // 데이터 가져오는 Future 실행
      builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 데이터 로딩 중이면 로딩 인디케이터 표시
          return Scaffold(
            appBar: AppBar(
              title: Text('상세 정보'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          // 에러가 발생하거나 데이터가 없는 경우 에러 메시지 표시
          return Scaffold(
            appBar: AppBar(
              title: Text('상세 정보'),
            ),
            body: Center(
              child: Text('상세 정보를 불러오지 못했습니다.'),
            ),
          );
        } else {
          // 데이터를 성공적으로 가져온 경우 화면에 표시
          Map<String, dynamic> basicInfo = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text('상세 정보'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: [
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: Icon(
                        FontAwesomeIcons.cow, // cow 아이콘
                        size: 50, // 아이콘 크기 조절
                      ), // 사진 영역
                    ),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${basicInfo['cattleNo']}',
                              style: TextStyle(fontSize: 18),
                            ),

                            Text('이름: ${basicInfo['nickName']}'),
                            SizedBox(
                              width: 10,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // 버튼이 눌렸을 때의 동작 구현
                                _nickNameDialog(context);
                              },
                              child: Text('짓기'),
                            ),

                            SizedBox(height: 20), // 간격 추가
                          ]),
                    ),
                  ],
                ),
                // 기본 정보 데이터
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "생년월일\n" + '${basicInfo['birthdate']}',
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "성별\n" + '${basicInfo['gender']}',
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "유형\n" + '${basicInfo['type']}',
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                            child: SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                        ))
                      ],
                    ),
                  ],
                ),
                Divider(), // 수평 선 추가
                Column(
                  children: [
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _fetchAdditionalInfo(), // 추가 정보 가져오는 Future 실행
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // 추가 정보를 가져오는 중이면 로딩 인디케이터 표시
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          // 추가 정보를 가져오는 도중 에러가 발생하면 에러 메시지 표시
                          return Text('추가 정보를 불러오는 중 에러가 발생했습니다.');
                        } else {
                          // 추가 정보를 성공적으로 가져오면 각각의 추가 정보를 위젯으로 변환하여 표시
                          List<Map<String, dynamic>>? additionalInfoList =
                              snapshot.data;
                          if (additionalInfoList != null &&
                              additionalInfoList.isNotEmpty) {
                            return Column(
                              children:
                                  additionalInfoList.map((additionalInfos) {
                                String cattleNo =
                                    additionalInfos['cattleNo']; // 소의 번호
                                String additionalInfo =
                                    additionalInfos['additionalInfo']; // 추가 정보
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Text('$additionalInfo'),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit), // 수정 버튼 아이콘
                                      onPressed: () {
                                        // 수정 버튼이 눌렸을 때의 동작
                                        _showEditAdditionalInfoDialog(
                                            context, cattleNo, additionalInfo);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete), // 삭제 버튼 아이콘
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('추가 정보 삭제'),
                                              content:
                                                  Text('정말로 이 정보를 삭제하시겠습니까?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context); // 다이얼로그 닫기
                                                  },
                                                  child: Text('취소'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    await _databaseHelper
                                                        .deleteDetailInfo(
                                                            cattleNo,
                                                            additionalInfo);
                                                    Navigator.pop(
                                                        context); // 다이얼로그 닫기
                                                    setState(() {
                                                      _futureData =
                                                          _fetchData();
                                                    });
                                                  },
                                                  child: Text('삭제'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                );
                              }).toList(),
                            );
                          } else {
                            // 추가 정보가 없으면 아무것도 표시하지 않음
                            return SizedBox.shrink();
                          }
                        }
                      },
                    ),
                  ],
                ),

                ElevatedButton(
                  onPressed: () {
                    _showAddInfoDialog(context);
                  },
                  child: Text('추가 정보 입력'),
                ),
              ]),
            ),
          );
        }
      },
    );
  }

  // 데이터베이스에서 데이터를 가져오는 메서드
  Future<Map<String, dynamic>> _fetchData() async {
    try {
      // DatabaseHelper 인스턴스 생성
      DatabaseHelper databaseHelper = DatabaseHelper();
      // 데이터베이스 열기
      await databaseHelper.open();
      // 데이터베이스에서 상세 정보 가져오기
      Map<String, dynamic> info = await databaseHelper.getInfo(widget.cattleNo);
      return info;
    } catch (e) {
      // 에러 발생 시 빈 Map 반환
      print('Error fetching data: $e');
      return {};
    }
  }

  // 데이터베이스에서 추가 정보를 가져오는 메서드
  Future<List<Map<String, dynamic>>> _fetchAdditionalInfo() async {
    try {
      // DatabaseHelper 인스턴스 생성
      DatabaseHelper databaseHelper = DatabaseHelper();
      // 데이터베이스 열기
      await databaseHelper.open();
      // 데이터베이스에서 cattleNo에 해당하는 모든 추가 정보 가져오기
      List<Map<String, dynamic>> detailInfo =
          await databaseHelper.getDetailInfo(widget.cattleNo);
      if (detailInfo.isNotEmpty) {
        return detailInfo;
      } else {
        // 추가 정보가 없는 경우 빈 문자열 반환
        return [];
      }
    } catch (e) {
      // 에러 발생 시 빈 문자열 반환
      print('Error fetching additional info: $e');
      return [];
    }
  }

  void _nickNameDialog(BuildContext context) async {
    TextEditingController _nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('별명 입력'),
          content: TextField(
            keyboardType: TextInputType.text,
            controller: _nameController,
            maxLength: 10, // 최대 10글자 제한
            decoration: InputDecoration(
              labelText: '별명',
              hintText: '최대 10글자',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                String nickname = _nameController.text;
                if (nickname.isNotEmpty && nickname.length <= 10) {
                  // 별명이 입력되고 최대 길이를 초과하지 않을 경우
                  // 여기서 별명을 사용하거나 필요한 작업을 수행합니다.
                  await _databaseHelper.open();
                  await _databaseHelper.updateName(nickname, widget.cattleNo);
                  print('Entered nickname: $nickname');
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  setState(() {
                    _futureData = _fetchData();
                  });
                } else {
                  // 입력된 별명이 없거나 최대 길이를 초과한 경우
                  // 사용자에게 알려줍니다.
                  print('너무 길어');
                  // 필요에 따라 경고 메시지 표시 또는 다른 처리를 수행할 수 있습니다.
                }
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 추가 정보 입력 다이얼로그를 표시하는 메서드
  void _showAddInfoDialog(BuildContext context) async {
    TextEditingController additionalInfoController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('추가 정보 입력'),
          content: Container(
            width: double.maxFinite, // 다이얼로그 너비를 최대로 설정
            child: Column(
              mainAxisSize: MainAxisSize.min, // 다이얼로그가 필요한 공간만큼만 차지하도록 설정
              children: [
                TextField(
                  keyboardType: TextInputType.text,
                  controller: additionalInfoController,
                  decoration: InputDecoration(
                    hintText: '추가 정보를 입력하세요',
                  ),
                  maxLines: null, // 여러 줄의 텍스트 입력 가능하도록 설정
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                String additionalInfo = additionalInfoController.text;
                print('추가 정보 입력: $additionalInfo');

                // 데이터베이스 열기
                await _databaseHelper.open();
                // 추가 정보 저장
                await _databaseHelper.addDetailInfo(
                    widget.cattleNo, additionalInfo);

                Navigator.pop(context); // 다이얼로그 닫기
                // 다시 데이터를 가져와서 상세 정보 페이지를 업데이트합니다.
                setState(() {
                  _futureData = _fetchData();
                });
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }

  void _showEditAdditionalInfoDialog(
      BuildContext context, String cattleNo, String currentInfo) async {
    TextEditingController infoController =
        TextEditingController(text: currentInfo);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('추가 정보 수정'),
          content: TextField(
            controller: infoController,
            decoration: InputDecoration(
              labelText: '수정할 정보',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                String newInfo = infoController.text;
                if (newInfo.isNotEmpty && newInfo != currentInfo) {
                  // 새로운 정보가 비어 있지 않고 기존 정보와 다를 때만 업데이트
                  await _databaseHelper.open();
                  await _databaseHelper.updateAdditionalInfo(
                      cattleNo, currentInfo, newInfo);
                  print('Updated additional info: $newInfo');
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  setState(() {
                    _futureData = _fetchData();
                  });
                }
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
