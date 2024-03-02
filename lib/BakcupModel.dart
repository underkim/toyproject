
import 'package:google_sign_in/google_sign_in.dart';

abstract class BaseBackUpModel {
  final String? message;
 
  BaseBackUpModel({this.message});
}
 
class BackUpLoading extends BaseBackUpModel {
  BackUpLoading({super.message});
}
 
class LogoutModel extends BaseBackUpModel {
  LogoutModel({super.message});
}
 
class LoginModel extends BaseBackUpModel {
  GoogleSignInAccount googleUser;
 
  LoginModel({super.message, required this.googleUser});
}
 
class BackUpFileExist extends LoginModel {
  BackUpFileExist({super.message, required super.googleUser});
}
 
class BackUpFileNotExist extends LoginModel {
  BackUpFileNotExist({super.message, required super.googleUser});
}
 
class BackUpping extends LoginModel {
  BackUpping({super.message, required super.googleUser});
}
 
class BackUpEnd extends LoginModel {
  BackUpEnd({super.message, required super.googleUser});
}
 
class Restoring extends LoginModel {
  Restoring({super.message, required super.googleUser});
}
 
class RestoreEnd extends LoginModel {
  RestoreEnd({super.message, required super.googleUser});
}
 
class ErrorModel extends BaseBackUpModel {
  ErrorModel({super.message});
}

