class AuthResult<T> {
  AuthResult(this.success, this.message, [this.additionalData]);

  final bool success;
  final String message;
  final T? additionalData;
}

class DataResult<T> {
  DataResult(this.success, this.message, [this.additionalData]);

  final bool success;
  final String message;
  final T? additionalData;
}

class Travel {
  Travel(
    this.name,
    this.activities,
    this.fromDate,
    this.toDate,
    this.budget,
    this.livePlace,
    this.expenses,
    this.meta,
    this.peopleCount,
    this.town, [
    this.id = -1,
  ]);

  Travel.parse(Map<String, dynamic> map) {
    id = map["id"];
    name = map["name"];
    activities = map["activities"].split(",");
    fromDate = map["from_date"];
    toDate = map["to_date"];
    budget = int.parse(map["budget"]);
    livePlace = map["live_place"];
    expenses = map["expenses"].split(",");
    meta = map["meta"];
    peopleCount = int.parse(map["people_count"]);
    town = map["town"];
  }

  Travel.empty() {
    id = -1;
    name = "";
    activities = [];
    fromDate = "";
    toDate = "";
    budget = 0;
    livePlace = "";
    expenses = [];
    meta = "";
    peopleCount = 0;
    town = "";
  }

  late int id;
  late String name;
  late List<Activity> activities;
  late String fromDate;
  late String toDate;
  late int budget;
  late String livePlace;
  late List<String> expenses;
  late String meta;
  late int peopleCount;
  late String town;

  Map<String, String> toMap() {
    return {
      "name": name,
      "activities":
          List.generate(activities.length, (index) => activities[index].sid)
              .join(","),
      "from_date": fromDate,
      "to_date": toDate,
      "budget": budget.toString(),
      "live_place": livePlace,
      "expenses": expenses.join(","),
      "meta": meta,
      "people_count": peopleCount.toString(),
      "town": town
    };
  }
}

class Activity {
  Activity(
    this.name,
    this.town,
    this.lan,
    this.lot,
    this.address,
    this.images,
    this.schedule,
    this.description,
    this.type, [
    this.id = -1,
  ]);

  Activity.parse(Map<String, dynamic> map) {
    id = map["id"];
    name = map["name"];
    town = map["town"];
    lan = double.parse(map["lan"]);
    lot = double.parse(map["lot"]);
    address = map["address"];
    images = map["images"].split(",");
    schedule = Schedule.empty();
    description = map["description"];
    type = ActivityType.values
        .firstWhere((e) => e.toString() == "ActivityType.${map["type"]}");
  }

  Activity.empty() {
    id = -1;
    name = "";
    town = "";
    lan = 0.0;
    lot = 0.0;
    address = "";
    images = [];
    schedule = Schedule.empty();
    description = "";
    type = ActivityType.none;
  }

  late int id;
  late String name;
  late String town;
  late double lan;
  late double lot;
  late String address;
  late List<String> images;
  late Schedule schedule;
  late String description;
  late ActivityType type;

  Map get map => {
        "name": name,
        "town": town,
        "lan": lan.toString(),
        "lot": lot.toString(),
        "address": address,
        "images": images.join(","),
        "schedule": schedule.toMap,
        "description": description,
        "type": type.name
      };

  String get sid => id.toString();
}

class Schedule {
  Schedule(
    this.mon,
    this.tue,
    this.wed,
    this.thu,
    this.fri,
    this.sat,
    this.sun,
  );

  Schedule.parse(Map<String, dynamic> map) {
    mon = FromToPair.parse(map["Mon"]);
    tue = FromToPair.parse(map["Tue"]);
    wed = FromToPair.parse(map["Wed"]);
    thu = FromToPair.parse(map["Thu"]);
    fri = FromToPair.parse(map["Fri"]);
    sat = FromToPair.parse(map["Sat"]);
    sun = FromToPair.parse(map["Sun"]);
  }

  Schedule.empty() {
    mon = FromToPair.empty();
    tue = FromToPair.empty();
    wed = FromToPair.empty();
    thu = FromToPair.empty();
    fri = FromToPair.empty();
    sat = FromToPair.empty();
    sun = FromToPair.empty();
  }

  Map get toMap => {
        "Mon": mon.map,
        "Tue": tue.map,
        "Wed": wed.map,
        "Thu": thu.map,
        "Fri": fri.map,
        "Sat": sat.map,
        "Sun": sun.map,
      };

  late FromToPair mon;
  late FromToPair tue;
  late FromToPair wed;
  late FromToPair thu;
  late FromToPair fri;
  late FromToPair sat;
  late FromToPair sun;
}

class FromToPair {
  FromToPair(this.from, this.to);

  FromToPair.parse(Map<String, dynamic> map) {
    from = HourAndMinute.parse(map["from"]);
    to = HourAndMinute.parse(map["to"]);
  }

  FromToPair.empty() {
    from = HourAndMinute.empty();
    to = HourAndMinute.empty();
  }

  late HourAndMinute from;
  late HourAndMinute to;

  Map get map => {
        "from": from.string,
        "to": to.string,
      };
}

class HourAndMinute {
  HourAndMinute(this.hour, this.minute);

  HourAndMinute.parse(String string) {
    List<String> parts = string.split(":");
    hour = int.parse(parts[0]);
    minute = int.parse(parts[1]);
  }

  HourAndMinute.empty() {
    hour = -1;
    minute = -1;
  }

  late int hour;
  late int minute;

  String get string => "$hour:$minute";
}

enum ActivityType {
  attraction,
  housing,
  food,
  entertainment,
  shop,
  event,
  new_,
  none
}

class Review {
  Review(this.id, this.stars, this.text);

  Review.parse(Map<String, dynamic> map) {
    id = map["id"];
    stars = double.parse(map["stars"]);
    text = map["text"];
  }

  Review.empty() {
    id = -1;
    stars = -1.0;
    text = "";
  }

  late int id;
  late double stars;
  late String text;

  Map<String, dynamic> get map => {
        "id": id,
        "stars": stars.toString(),
        "text": text,
      };
}
