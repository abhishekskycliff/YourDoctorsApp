import 'dart:convert';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/network/models/login/login_model.dart';
import 'package:YOURDRS_FlutterAPP/testing.dart';
import 'package:http/http.dart' as http;

class LoginApiServices {

  ErrorMessage exception = ErrorMessage();
  /// passing the controller valued in service
  Future<AuthenticateUser> LoginpostApiMethod(String name, String password) async {
    var client = http.Client();
    String apiUrl = ApiUrlConstants.getUser;
    // print('requestUrl $apiUrl');

    final json = {
      "userName": name,
      "password": password,
    };
    try {
      http.Response response = await client.post(
        apiUrl,
        body: jsonEncode(json),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      var jsonResponse = jsonDecode(response.body);
      return AuthenticateUser.fromJson(jsonResponse);
    } catch (e) {
      print("${e.toString()}");
      exception.showMyDialog();
    }
    finally {
      client.close();
    }
  }
}
