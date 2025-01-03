import "package:http/http.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "dart:convert";
import "package:flutter/foundation.dart";

import "package:travel_manager_final/model/datatypes.dart";

const _storage = FlutterSecureStorage();

class AuthService {
  // TODO: check for secure/not secure
  AuthService(
      {required this.serveraddr, required this.storage, this.secure = false});

  final String serveraddr;
  final StorageService storage;
  final bool secure;

  String lastResult = "";

  Future<AuthResult> register(
      String username, String password, String name) async {
    var result = false;

    var r = await get(
      (secure ? Uri.https : Uri.http)(
        serveraddr,
        "api/v1/register",
        {
          "username": username,
          "password": password,
          "name": name,
        },
      ),
    );

    if (r.statusCode == 200) {
      var value = jsonDecode(r.body);

      if (value["status"] == "success") {
        result = true;

        await storage.write("session", value["data"]["session"]);
        await storage.write("name", value["data"]["name"]);
        await storage.write("subscribe", value["data"]["subscribe"]);
      } else {
        result = false;
      }
    }

    return AuthResult(result, "");
  }

  Future<AuthResult> login(String username, String password) async {
    var result = false;

    var r = await get(
      Uri.http(
        serveraddr,
        "api/v1/login",
        {
          "username": username,
          "password": password,
        },
      ),
    );

    var value = jsonDecode(r.body);

    if (value["status"] == "success") {
      result = true;

      await storage.write("session", value["data"]["session"]);
      await storage.write("name", value["data"]["name"]);
      await storage.write("subscribe", value["data"]["subscribe"]);
    } else {
      result = false;
    }

    lastResult = r.body;

    return AuthResult(result, "");
  }

  Future<AuthResult<Map>> verifySession() async {
    var s = await getSession();
    var t = false;

    var jsn = {};

    Response r;
    try {
      r = await get(Uri.http(
          serveraddr, "api/v1/check_session", {"session": s.additionalData}));
    } catch (e) {
      if (kDebugMode) print(e);

      return AuthResult(false, "");
    }

    if (r.statusCode == 200) {
      jsn = jsonDecode(r.body);

      if (jsn["status"] == "success") {
        t = true;
      }
    }

    lastResult = r.body;

    return t
        ? AuthResult(
            true,
            "",
            {
              "name": jsn["data"]["name"],
              "subscribe": jsn["data"]["subscribe"]
            },
          )
        : AuthResult(false, jsn["code"] ?? "");
  }

  Future<AuthResult<String>> getSession() async {
    return AuthResult(true, "", await storage.read("session"));
  }

  Future<AuthResult> logout() async {
    var result = false;

    var r = await get(
      Uri.http(
        serveraddr,
        "api/v1/logout",
        {
          "session": await storage.read("session"),
        },
      ),
    );

    if (r.statusCode == 200) {
      result = jsonDecode(r.body)["status"] == "success";
      await storage.clear();
    }

    lastResult = r.body;

    return AuthResult(result, "");
  }
}

class DataService {
  DataService({
    required this.serveraddr,
    required this.authservice,
    required this.storage,
  });

  final String serveraddr;
  final AuthService authservice;
  final StorageService storage;

  Future<Response> _get(String path, Map<String, dynamic> args) async {
    Response r = await get(Uri.http(serveraddr, path, args));
    return r;
  }

  Future<DataResult> createTravel(Travel travel) async {
    var result = false;
    var mdata = travel.toMap()
      ..["session"] = (await authservice.getSession()).additionalData!;

    print("Travel:");
    print(mdata);
    // session=895765db-edfb-48a0-9868-47e6aca900ce&plan_name=TEST&expenses=-&activities=[]&from_date=1212&to_date=12312&live_place=none&budget=10000&people_count=0&meta=0&town=odi

    var r = await _get("/api/v1/create_travel", mdata);

    if (r.statusCode == 200) {
      var value = jsonDecode(r.body);
      result = value["status"] == "success";
    } else {
      result = false;
    }

    return DataResult(result, "");
  }

  Future<DataResult<List<Travel>>> getAllTravels() async {
    List<Travel> result = [];

    var r = await _get("/api/v1/get_all_travels", {
      "session": (await authservice.getSession()).additionalData,
    });

    if (r.statusCode == 200) {
      var value = jsonDecode(r.body);

      if (value["status"] == "success") {
        result = List<Travel>.from(
          value["data"].map(
            (x) => Travel.parse(x),
          ),
        );
      } else {
        return DataResult(false, value["code"] ?? "", []);
      }
    } else {
      return DataResult(false, r.statusCode.toString(), []);
    }

    return DataResult(true, "", result);
  }

  Future<DataResult<Travel>> getTravel(String id) async {
    var r = await _get("/api/v1/get_travel", {
      "session": (await authservice.getSession()).additionalData!,
      "id": id,
    });

    if (r.statusCode == 200) {
      var value = jsonDecode(r.body);

      if (value["status"] == "success") {
        return DataResult(true, "", Travel.parse(value["data"]));
      } else {
        return DataResult(false, value["code"] ?? "", Travel.empty());
      }
    } else {
      return DataResult(false, r.statusCode.toString(), Travel.empty());
    }
  }

  Future<DataResult> updateTravel(Travel travel) async {
    var result = false;

    var resp = await _get(
      "/api/v1/edit_travel",
      travel.toMap()
        ..["session"] = (await authservice.getSession()).additionalData!,
    );

    if (resp.statusCode == 200) {
      var value = jsonDecode(resp.body);
      result = value["status"] == "success";
      return DataResult(result, result ? "" : value["code"] ?? "");
    } else {
      return DataResult(false, resp.statusCode.toString());
    }
  }

  Future<DataResult> deleteTravel(String id) async {
    var resp = await _get("/api/v1/delete_travel", {
      "session": (await authservice.getSession()).additionalData,
      "id": id,
    });

    if (resp.statusCode == 200) {
      var value = jsonDecode(resp.body);

      if (value["status"] == "success") {
        return DataResult(true, "");
      }
      return DataResult(false, value["code"]);
    } else {
      return DataResult(false, resp.statusCode.toString());
    }
  }

  Future<DataResult<List<Activity>>> searchActivities(
      String town, String query) async {
    var r = await _get("/api/activities/search", {
      "session": (await authservice.getSession()).additionalData!,
      "town": town,
      "q": query,
    });

    if (r.statusCode == 200) {
      var value = jsonDecode(r.body);
      if (value["status"] == "success") {
        return DataResult(
          true,
          "",
          List.generate(
            value["data"].length,
            (i) {
              return Activity.parse(value["data"][i]);
            },
          ),
        );
      }
    }

    return DataResult(false, r.statusCode.toString());
  }

  Future<DataResult> addReview(Review review) async {
    var resp = await _get(
        "/api/v1/add_review",
        review.map
          ..["session"] = (await authservice.getSession()).additionalData!);

    if (resp.statusCode == 200) {
      var value = jsonDecode(resp.body);

      if (value["status"] == "success") {
        return DataResult(true, "");
      }
    }

    return DataResult(false, resp.statusCode.toString());
  }

  Future<DataResult<List<Review>>> getReviews(String id) async {
    var r = await _get("/api/v1/get_reviews", {
      "session": (await authservice.getSession()).additionalData!,
      "placeid": id,
    });

    if (r.statusCode == 200) {
      var value = jsonDecode(r.body);
      if (value["status"] == "success") {
        var result = value["data"];
        return DataResult(
          true,
          "",
          List.generate(
            result.length,
            (i) => Review.parse(
              result[i],
            ),
          ),
        );
      }
    }

    return DataResult(false, r.statusCode.toString(), []);
  }

  Future<DataResult<Review>> getReview(String id) async {
    var r = await _get("/api/v1/get_review", {
      "session": (await authservice.getSession()).additionalData!,
      "id": id,
    });

    if (r.statusCode == 200) {
      var value = jsonDecode(r.body);

      if (value["status"] == "success") {
        return DataResult(true, "", Review.parse(value["data"]));
      }
    }

    return DataResult(false, r.statusCode.toString(), Review.empty());
  }

  Future<DataResult> deleteReview(String id) async {
    var resp = await _get("/api/v1/delete_review", {
      "session": (await authservice.getSession()).additionalData!,
      "id": id,
    });

    if (resp.statusCode == 200) {
      var value = jsonDecode(resp.body);

      return DataResult(value["status"] == "success", value["code"] ?? "");
    }

    return DataResult(false, resp.statusCode.toString());
  }

  Future<DataResult<String>> getUsername(String otherUser) async {
    var r = await _get("/api/v1/get_username", {
      "session": (await authservice.getSession()).additionalData!,
      "other_user": otherUser,
    });

    if (r.statusCode == 200) {
      var value = jsonDecode(r.body);

      DataResult(true, "", value["name"]);
    }

    return DataResult(false, r.statusCode.toString(), "");
  }

  // TODO: add Town to datatypes and replace
  Future<List<Map<String, dynamic>>> searchTowns(String query) async {
    List<Map<String, dynamic>> result = [];

    var r = await _get("/api/v1/search_town", {
      "session": (await authservice.getSession()).additionalData!,
      "q": query,
    });

    if (r.statusCode == 200) {
      // decode bytes to utf-8
      var value = jsonDecode(const Utf8Decoder().convert(r.bodyBytes));

      try {
        result = List<Map<String, dynamic>>.from(value["data"]);
      } catch (e) {
        if (kDebugMode) print(e);
      }
    }

    return result;
  }
}

class StorageService {
  StorageService();

  Future<String> read(String key) async {
    var value = await _storage.read(key: key);

    return value ?? "";
  }

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }

  Future<bool> containsKey(String key) async {
    var value = await _storage.containsKey(key: key);

    return value;
  }

  // Надстройки
  Future<Map<String, dynamic>?> restoreLastActivity() async {
    if (!await containsKey("not_finished_activity")) return null;
    return jsonDecode(await read("not_finished_activity"));
  }

  Future<void> saveLastActivity(Map<String, dynamic> activity) async {
    activity["start_date"] = activity["start_date"].toString();
    activity["end_date"] = activity["end_date"].toString();

    await write("not_finished_activity", jsonEncode(activity));
  }

  Future<void> clearLastActivity() async {
    await delete("not_finished_activity");
  }
}

class Service {
  Service({required this.serveraddr});
  final String serveraddr;

  late final AuthService auth;
  late final StorageService storage;
  late final DataService data;

  void init() {
    storage = StorageService();
    auth = AuthService(
      serveraddr: serveraddr,
      storage: storage,
    );
    data = DataService(
      serveraddr: serveraddr,
      authservice: auth,
      storage: storage,
    );
  }
}
