import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:objectbox/objectbox.dart';
import 'package:full_app_code/src/database/batting_stats.dart';
import 'package:full_app_code/src/database/bowling_stats.dart';
import 'package:full_app_code/objectbox.g.dart';

class ObjectBoxDB {
  late final Store store;
  late final Box<BattingStats> battingBox;
  late final Box<BowlingStats> bowlingBox;

  ObjectBoxDB._create(this.store) {
    battingBox = Box<BattingStats>(store);
    bowlingBox = Box<BowlingStats>(store);
  }

  static Future<ObjectBoxDB> create() async {
    final dir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: '${dir.path}/objectbox');
    return ObjectBoxDB._create(store);
  }
}
