import "package:http/http.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "dart:convert";

const _storage = FlutterSecureStorage();

class AuthService {
  AuthService({required this.serveraddr, required this.storage});

  final String serveraddr;
  final StorageService storage;

  Future<bool> register(String username, String password, String name) async {
    var result = false;

    var r = await get(
      Uri.http(
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

        await storage.write("session", value["session"]);
        await storage.write("name", value["name"]);
        await storage.write("subscribe", value["subscribe"]);
      } else {
        result = false;
      }
    }

    return result;
  }

  Future<bool> login(String username, String password) async {
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

      storage.write("session", value["session"]);
      storage.write("name", value["name"]);
      storage.write("subscribe", value["subscribe"]);
    } else {
      result = false;
    }

    print(value);

    print(result);

    return result;
  }

  Future<Map> verifySession() async {
    var s = await getSession();
    var t = false;

    var jsn = {};

    var r =
        await get(Uri.http(serveraddr, "api/v1/check_session", {"session": s}));

    if (r.statusCode == 200 && jsonDecode(r.body)["status"] == "success") {
      t = true;
      jsn = jsonDecode(r.body);
    }

    return t
        ? {"valid": true, "name": jsn["name"], "subscribe": jsn["subscribe"]}
        : {"valid": false, "code": jsn["code"]};
  }

  Future<String> getSession() async {
    return await storage.read("session");
  }

  Future<bool> logout() async {
    var result = false;

    var r = await get(Uri.http(serveraddr, "api/v1/logout", {
      "session": await storage.read("session"),
    }));

    if (r.statusCode == 200) {
      result = jsonDecode(r.body)["status"] == "success";
      await storage.clear();
    }

    return result;
  }
}

class DataService {
  DataService(
      {required this.serveraddr,
      required this.authservice,
      required this.storage});

  final String serveraddr;
  final AuthService authservice;
  final StorageService storage;

  Future<Response> _get(String path, Map<String, dynamic> args) async {
    Response r = await get(Uri.http(serveraddr, path, args));
    return r;
  }

  Future<bool> createTravel(
    String planName,
    String activities,
    String fromDate,
    String toDate,
    String budget,
    String livePlace,
    String expenses,
    String meta,
    String peopleCount,
    String town,
  ) async {
    var result = false;

    var r = await _get("/api/v1/create_travel", {
      "session": await authservice.getSession(),
      "plan_name": planName,
      "activities": activities,
      "from_date": fromDate,
      "to_date": toDate,
      "budget": budget,
      "live_place": livePlace,
      "expenses": expenses,
      "meta": meta,
      "people_count": peopleCount,
      "town": town
    });

    if (r.statusCode == 200) {
      var value = jsonDecode(r.body);
      result = value["status"] == "success";
    } else {
      result = false;
    }

    return result;
  }

  Future<List<dynamic>> getAllTravels() async {
    var result = [];

    var r = await _get("/api/v1/get_all_travels", {
      "session": await authservice.getSession(),
    });

    if (r.statusCode == 200) {
      var value = jsonDecode(r.body);

      if (value["status"] == "success") {
        result = value["content"];
      } else {
        result = [];
      }
    } else {
      result = [];
    }

    return result;
  }

  Future<Map> getTravel(String id) async {
    var result = {};

    var r = await _get("/api/v1/get_travel", {
      "session": await authservice.getSession(),
      "id": id,
    });

    if (r.statusCode == 200) {
      var value = jsonDecode(r.body);

      if (value["status"] == "success") {
        result = value["content"];
      } else {
        result = {};
      }
    } else {
      result = {};
    }

    return result;
  }

  Future<bool> updateTravel(
    String id,
    String planName,
    String activities,
    String fromDate,
    String toDate,
    String budget,
    String livePlace,
    String expenses,
    String meta,
    String peopleCount,
    String town,
  ) async {
    var result = false;

    var resp = await _get("/api/v1/edit_travel", {
      "session": await authservice.getSession(),
      "id": id,
      "plan_name": planName,
      "activities": activities,
      "from_date": fromDate,
      "to_date": toDate,
      "budget": budget,
      "live_place": livePlace,
      "expenses": expenses,
      "meta": meta,
      "people_count": peopleCount,
      "town": town
    });

    if (resp.statusCode == 200) {
      var value = jsonDecode(resp.body);
      result = value["status"] == "success";
    } else {
      result = false;
    }

    return result;
  }

  Future<bool> deleteTravel(String id) async {
    var result = false;

    var resp = await _get("/api/v1/delete_travel", {
      "session": await authservice.getSession(),
      "id": id,
    });

    if (resp.statusCode == 200) {
      var value = jsonDecode(resp.body);

      if (value["status"] == "success") {
        result = true;
      }
    } else {
      result = false;
    }

    return result;
  }

  Future<List<dynamic>> searchActivities(String town, String query) async {
    var result = [];

    var r = await _get("/api/v1/search_activities", {
      "session": await authservice.getSession(),
      "town": town,
      "q": query,
    });

    if (r.statusCode == 200) {
      if (jsonDecode(r.body)["status"] == "success") {
        result = jsonDecode(r.body)["content"];
      }
    }

    return result;
  }

  Future<bool> addReview(String id, String stars, String text) async {
    var result = false;

    var resp = await _get("/api/v1/add_review", {
      "session": await authservice.getSession(),
      "id": id,
      "stars": stars,
      "text": text,
    });

    if (resp.statusCode == 200) {
      var value = jsonDecode(resp.body);

      if (value["status"] == "success") {
        result = true;
      }
    }

    return result;
  }

  Future<List<dynamic>> getReviews(String id) async {
    var result = [];

    var r = await _get("/api/v1/get_reviews", {
      "session": await authservice.getSession(),
      "placeid": id,
    });

    if (r.statusCode == 200) {
      if (jsonDecode(r.body)["status"] == "success") {
        result = jsonDecode(r.body)["content"];
      }
    }

    return result;
  }

  Future<Map> getReview(String id) async {
    var result = {};

    var r = await _get("/api/v1/get_review", {
      "session": await authservice.getSession(),
      "id": id,
    });

    if (r.statusCode == 200) {
      var value = jsonDecode(r.body);

      if (value["status"] == "success") {
        result = value["content"];
      }
    }

    return result;
  }

  Future<bool> deleteReview(String id) async {
    var result = false;

    var resp = await _get("/api/v1/delete_review", {
      "session": await authservice.getSession(),
      "id": id,
    });

    if (resp.statusCode == 200) {
      var value = jsonDecode(resp.body);

      result = value["status"] == "success";
    }

    return result;
  }

  Future<String> getUsername(String otherUser) async {
    var result = "";

    var r = await _get("/api/v1/get_username", {
      "session": await authservice.getSession(),
      "other_user": otherUser,
    });

    if (r.statusCode == 200) {
      var value = jsonDecode(r.body);

      result = value["name"];
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
}

class Service {
  Service({required this.serveraddr});
  final String serveraddr;

  late final AuthService auth;
  late final StorageService storage;
  late final DataService data;

  void init() {
    storage = StorageService();
    auth = AuthService(serveraddr: serveraddr, storage: storage);
    data = DataService(
        serveraddr: serveraddr, authservice: auth, storage: storage);
  }
}
