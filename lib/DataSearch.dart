import 'package:flutter/material.dart';
import 'package:toyproject/database_helper.dart'; // 데이터베이스 헬퍼 클래스의 import 추가
import 'package:toyproject/detail.dart';

class DataSearch extends SearchDelegate<String> {
  final DatabaseHelper databaseHelper; // 데이터베이스 헬퍼 클래스 인스턴스

  DataSearch({required this.databaseHelper});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear), // x 모양
        onPressed: () {
          query = ''; // 누르면 검색어 지우기
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back), // 뒤로가기
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // 검색 결과를 보여주는 위젯을 반환합니다.
    // 여기서는 검색 결과를 기반으로 데이터를 보여주는 페이지로 이동하는 등의 작업을 수행할 수 있습니다.
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // 검색 입력 중에 추천을 보여주는 위젯을 반환합니다.
    // 여기서는 데이터베이스에서 검색을 수행하여 관련된 검색어를 추천하는 등의 작업을 수행할 수 있습니다.

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getSearchResults(query), // 입력된 검색어에 따른 결과를 가져오는 비동기 함수 호출
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final List<Map<String, dynamic>> searchResults = snapshot.data ?? [];

        // cattleNo를 기준으로 중복된 결과를 제거합니다.
        final uniqueResults = <String, Map<String, dynamic>>{};
        searchResults.forEach((result) {
          final cattleNo = result['cattleNo'];
          if (!uniqueResults.containsKey(cattleNo)) {
            uniqueResults[cattleNo] = result;
          }
        });

        return ListView.builder(
          itemCount: uniqueResults.length,
          itemBuilder: (context, index) {
            final basicInfo = uniqueResults.values.elementAt(index);
            final cattleNo = basicInfo['cattleNo'];
            final nickName = basicInfo['nickName'];
            final birthdate = basicInfo['birthdate'];

            // 해당 기본 정보에 대한 모든 추가 정보를 가져옵니다.
            final additionalInfoList = searchResults
                .where((info) => info['cattleNo'] == cattleNo)
                .toList();

            return ExpansionTile(
              title: Text(cattleNo),
              subtitle: Text('별명: $nickName\n생일: $birthdate'),
              children: additionalInfoList.map<Widget>((additionalInfo) {
                final additionalInfoText =
                    '${additionalInfo['additionalInfo']}';
                return ListTile(
                  title: Text(additionalInfoText),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailInfoPage(cattleNo: cattleNo),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  // 검색 결과를 가져오는 비동기 함수
  Future<List<Map<String, dynamic>>> _getSearchResults(String query) async {
    try {
      await databaseHelper.open(); // 데이터베이스 열기
      // 검색 쿼리를 수행하여 관련된 가축 정보를 가져옵니다.
      return await databaseHelper.searchCattleInfo(query);
    } catch (e) {
      print('Error searching data: $e');
      return [];
    }
  }
}
