import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  late Database _db;

  Future<void> open() async {
    final databasePath = await getDatabasesPath();
    final String path = join(databasePath, 'test4.db');

    // 데이터베이스 열기
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 기본 정보 테이블 생성
    await db.execute(
      'CREATE TABLE IF NOT EXISTS basic_info(cattleNo TEXT PRIMARY KEY, birthdate TEXT, type TEXT, gender TEXT, nickName TEXT DEFAULT "없음")',
    );

    // 상세 정보 테이블 생성
    await db.execute(
      'CREATE TABLE IF NOT EXISTS detail_info(cattleNo TEXT, additionalInfo TEXT,PRIMARY KEY (cattleNo, additionalInfo), FOREIGN KEY(cattleNo) REFERENCES basic_info(cattleNo) ON DELETE CASCADE)',
    );
  }

  Future<void> addBasicInfo(
      String cattleNo, String birthdate, String type, String gender) async {
    await _db.insert(
      'basic_info',
      {
        'cattleNo': cattleNo,
        'birthdate': birthdate,
        'type': type,
        'gender': gender
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> addDetailInfo(String cattleNo, String additionalInfo) async {
    await _db.insert(
      'detail_info',
      {'cattleNo': cattleNo, 'additionalInfo': additionalInfo},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteBasicInfo(String cattleNo) async {
    await _db
        .delete('basic_info', where: 'cattleNo = ?', whereArgs: [cattleNo]);
  }

  Future<List<Map<String, dynamic>>> getBasicInfo() async {
    // 데이터베이스가 열려있는지 확인
    if (_db != null && _db.isOpen) {
      return await _db.query('basic_info');
    } else {
      // 데이터베이스가 열려있지 않으면 빈 리스트 반환
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getDetailInfo(String cattleNo) async {
    // 데이터베이스를 열도록 보장
    await open();

    // 데이터베이스에서 이력번호에 해당하는 상세 정보를 검색
    List<Map<String, dynamic>> result = await _db.query(
      'detail_info',
      where: 'cattleNo = ?',
      whereArgs: [cattleNo],
    );
    // 검색된 정보가 있으면 반환
    if (result.isNotEmpty) {
      return result;
    }

    // 검색된 정보가 없는 경우 빈 리스트 반환
    return [];
  }

  Future<Map<String, dynamic>> getInfo(String cattleNo) async {
    // 데이터베이스가 열려있는지 확인
    if (_db == null || !_db.isOpen) {
      await open();
    }

    // 데이터베이스에서 이력번호에 해당하는 상세 정보를 검색
    List<Map<String, dynamic>> result = await _db.query(
      'basic_info',
      where: 'cattleNo = ?',
      whereArgs: [cattleNo],
      orderBy: 'cattleNo ASC',
    );

    // 검색된 정보가 있으면 반환
    if (result.isNotEmpty) {
      print('Found data in the database: $result');
      return result.first;
    }

    // 검색된 정보가 없거나 데이터베이스가 열리지 않은 경우 빈 Map 반환
    print('No data found in the database.');
    return {};
  }

  // 다음 메서드를 사용하여 데이터베이스의 특정 테이블에서 모든 레코드를 가져옵니다.
  Future<List<Map<String, dynamic>>> getAllRecords(String tableName) async {
    // 데이터베이스가 열려있는지 확인
    if (_db != null && _db.isOpen) {
      // 테이블에서 모든 레코드를 조회
      return await _db.query(tableName);
    } else {
      // 데이터베이스가 열려있지 않으면 빈 리스트 반환
      return [];
    }
  }

  Future<void> recreateTables() async {
    // 데이터베이스가 열려있는지 확인
    if (_db != null && _db.isOpen) {
      // 데이터베이스 테이블 삭제
      await _db.execute('DROP TABLE IF EXISTS basic_info');
      await _db.execute('DROP TABLE IF EXISTS detail_info');

      // 데이터베이스 재생성
      await _onCreate(_db, 1);
    }
  }

  Future<void> deleteDetailInfo(String cattleNo, String additionalInfo) async {
    try {
      await open();

      await _db.delete(
        'detail_info',
        where: 'cattleNo = ? AND additionalInfo = ?',
        whereArgs: [cattleNo, additionalInfo],
      );
      print('Deleted detail info for cattleNo: $cattleNo'); // 삭제 성공 시 로그 출력
    } catch (e) {
      print('Error deleting detail info: $e'); // 삭제 도중 오류 발생 시 로그 출력
    }
  }

  Future<void> updateName(String newName, String cattleNo) async {
    try {
      await open();
      await _db.update(
        'basic_info',
        {'nickName': newName},
        where: 'cattleNo = ?',
        whereArgs: [cattleNo],
      );
      print('Updated name for cattleNo: $cattleNo'); // 업데이트 성공 시 로그 출력
    } catch (e) {
      print('Error updating name: $e'); // 업데이트 도중 오류 발생 시 로그 출력
    }
  }

  Future<void> updateAdditionalInfo(
      String cattleNo, String currentInfo, String newInfo) async {
    try {
      await open();
      await _db.update(
        'detail_info',
        {'additionalInfo': newInfo},
        where: 'cattleNo = ? AND additionalInfo = ?',
        whereArgs: [cattleNo, currentInfo],
      );
      print('Updated name for cattleNo: $cattleNo'); // 업데이트 성공 시 로그 출력
    } catch (e) {
      print('Error updating name: $e'); // 업데이트 도중 오류 발생 시 로그 출력
    }
  }

  Future<List<Map<String, dynamic>>> searchCattleInfo(String searchText) async {
    try {
      await open(); // 데이터베이스 열기

      List<Map<String, dynamic>> result = await _db.rawQuery(
        """
      SELECT basic_info.*, detail_info.additionalInfo
      FROM basic_info
      LEFT JOIN detail_info ON basic_info.cattleNo = detail_info.cattleNo
      WHERE basic_info.cattleNo LIKE '%$searchText%' OR basic_info.nickName LIKE '%$searchText%' OR basic_info.birthdate LIKE '%$searchText%' OR basic_info.type LIKE '%$searchText%' OR basic_info.gender LIKE '%$searchText%' OR detail_info.additionalInfo LIKE '%$searchText%'
      """,
      );

      return result;
    } catch (e) {
      print('Error searching cattle info: $e');
      return [];
    }
  }
}
