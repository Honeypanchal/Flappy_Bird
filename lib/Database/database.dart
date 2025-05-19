import 'package:hive_flutter/hive_flutter.dart';

late Box myBox;

Future<void> initHiveBox() async {
  if (!Hive.isBoxOpen('user')) {
    myBox = await Hive.openBox('user');
  } else {
    myBox = Hive.box('user');
  }
}

Future<void> write(String id, dynamic value) async {
  await initHiveBox(); // ✅ Ensure box is open before write

  switch (id) {
    case "score":
      await myBox.put("score", value);
      break;
    case "background":
      await myBox.put("background", value);
      break;
    case "bird":
      await myBox.put("bird", value);
      print("bird is Activated");
      break;
    case "level":
      await myBox.put("level", value);
      break;
    case "audio":
      await myBox.put("audio", value);
      break;
  }
}

Future<dynamic> read(String id) async {
  await initHiveBox(); // ✅ Ensure box is open before read

  dynamic value;
  switch (id) {
    case "score":
      value = myBox.get("score");
      break;
    case "background":
      value = myBox.get("background");
      break;
    case "bird":
      value = myBox.get("bird");
      break;
    case "level":
      value = myBox.get("level");
      break;
    case "audio":
      value = myBox.get("audio");
      break;
  }
  return value;
}
