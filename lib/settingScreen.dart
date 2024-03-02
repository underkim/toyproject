import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:toyproject/GoogleAuth.dart';
import 'package:toyproject/backup_restore_screen.dart'; // Google 로그인 및 Drive API 관련 함수들이 있는 파일

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  void _checkCurrentUser() async {
    GoogleSignInAccount? user = await signIn();
    setState(() {
      _currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_currentUser == null)
              ElevatedButton(
                onPressed: () async {
                  GoogleSignInAccount? user = await signIn();
                  setState(() {
                    _currentUser = user;
                  });
                },
                child: Text('Sign In'),
              ),
            if (_currentUser != null)
              ElevatedButton(
                onPressed: () async {
                  await signOut();
                  setState(() {
                    _currentUser = null;
                  });
                },
                child: Text('Sign Out'),
              ),
            ElevatedButton(
              onPressed: () {
                // 파일 업로드 기능 호출
              },
              child: Text('Upload File'),
            ),
            ElevatedButton(
              onPressed: () {
                // 파일 다운로드 기능 호출
              },
              child: Text('Download File'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SettingsPage(),
  ));
}
