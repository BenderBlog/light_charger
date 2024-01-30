/// Copyright 2024 BenderBlog Rodriguez and Contributors
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
///     http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

// General user setting preference.

import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;

/// "idsAccount" "idsPassword" "sportPassword"
Map<String, String?> user = {
  "name": null,
  "idsAccount": null,
  "idsPassword": null,
  "roleId": null,
  "decorated": "false",
  "decoration": "",
  "swift": "0",
  "currentSemester": "",
  "currentStartDay": ""
};

void initUser() {
  user["idsAccount"] = prefs.getString("idsAccount");
  user["idsPassword"] = prefs.getString("idsPassword");
  user["roleId"] = prefs.getString("roleId");
  user["name"] = prefs.getString("name");
  if (user["idsAccount"] == null ||
      user["idsPassword"] == null ||
      user["name"] == null ||
      user["roleId"] == null) {
    throw NotLoginException();
  }
  user["swift"] = prefs.getString("swift");
  user["decorated"] = prefs.getString("decorated");
  user["decoration"] = prefs.getString("decoration");
  user["currentSemester"] = prefs.getString("currentSemester");
  user["currentStartDay"] = prefs.getString("currentStartDay");
}

void addUser(String key, String value) {
  assert(user.keys.contains(key), "user map does not contains key $key");
  user[key] = value;
  prefs.setString(key, value);
}

class NotLoginException implements Exception {}
