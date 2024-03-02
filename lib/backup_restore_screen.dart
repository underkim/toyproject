import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:toyproject/BakcupModel.dart';
import 'package:toyproject/GoogleAuth.dart';


//로그인
  Future<GoogleSignInAccount?> signIn() async {
    GoogleSignIn googleSignIn =
        GoogleSignIn(scopes: [drive.DriveApi.driveAppdataScope]);

    return await googleSignIn.signInSilently() ?? await googleSignIn.signIn();
  }

//로그아웃
  Future<void> signOut() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }

// get api
  Future<drive.DriveApi?> getDriveApi(
      GoogleSignInAccount googleSignInAccount) async {
    final header = await googleSignInAccount.authHeaders;
    GoogleAuthClient googleAuthClient = GoogleAuthClient(header: header);
    return drive.DriveApi(googleAuthClient);
  }

  //upLoad
  Future<drive.File?> upLoad(
      {required drive.DriveApi driveApi,
      required File file,
      String? driveFileId}) async {
    // 드라이브 업로드용 파일 정보
    drive.File driveFile = drive.File();

    //앱에 저장된 파일 이름 추출
    driveFile.name = path.basename(file.absolute.path);

    late final response;
    if (driveFileId != null) {
      response = await driveApi.files.update(driveFile, driveFileId,
          uploadMedia: drive.Media(file.openRead(), file.lengthSync()));
    } else {
      driveFile.parents = ["appDataFolder"];
      response = await driveApi.files.create(driveFile,
          uploadMedia: drive.Media(file.openRead(), file.lengthSync()));
    }
    return response;
  }

  Future<File> downLoad(
      {required String driveFileId,
      required drive.DriveApi driveApi,
      required String localPath}) async {
    drive.Media media = await driveApi.files.get(driveFileId,
        downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
 
    List<int> data = [];
 
    await media.stream.forEach((element) {
      data.addAll(element);
    });
 
    File file = File(localPath);
    file.writeAsBytesSync(data);
 
    return file;
  }

Future<drive.File?> getDriveFile(
      {required drive.DriveApi driveApi, required filename}) async {
    drive.FileList fileList = await driveApi.files
        .list(spaces: "appDataFolder", $fields: "files(id,name,modifiedTime)");
    List<drive.File>? files = fileList.files;
 
    //Bad state: No element 발생함
    try {
      drive.File? driveFile =
          files?.firstWhere((element) => element.name == filename);
      return driveFile;
    } catch (e) {
      return null;
    }
  }


