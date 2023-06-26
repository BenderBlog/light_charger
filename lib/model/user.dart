import 'package:shared_preferences/shared_preferences.dart';

/// "idsAccount" "idsPassword" "sportPassword"
Map<String, String?> user = {
  "name": null,
  "idsAccount": null,
  "idsPassword": null,
  "roleId": null,
  "decorated": "false",
  "decoration": "",
  "swift": "0",
};

Future<void> initUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  user["idsAccount"] = prefs.getString("idsAccount");
  user["idsPassword"] = prefs.getString("idsPassword");
  user["roleId"] = prefs.getString("roleId");
  user["name"] = prefs.getString("name");
  if (user["idsAccount"] == null ||
      user["idsPassword"] == null ||
      user["name"] == null ||
      user["roleId"] == null) {
    throw "有未注册用户，跳转至登录界面";
  }
  user["swift"] = prefs.getString("swift");
  user["decorated"] = prefs.getString("decorated");
  user["decoration"] = prefs.getString("decoration");
}

Future<void> addUser(String key, String value) async {
  user[key] = value;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}
