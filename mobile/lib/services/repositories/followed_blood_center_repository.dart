import 'package:vitalink/services/helpers/database_helper.dart';
import 'package:vitalink/services/models/blood_center_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

abstract class IFollowedBloodCenterRepository {
  IFollowedBloodCenterRepository() {
    initRepository();
  }
  initRepository();
  Future<List<BloodCenterModel>> getLikedBloodCenters();
  createBc(BloodCenterModel bloodCenter);
  deleteBc(BloodCenterModel bloodCenter);
  deleteAllBcs();
}

class FollowedBloodCenterRepository implements IFollowedBloodCenterRepository {
  late Database db;

  FollowedBloodCenterRepository() {
    initRepository();
  }

  @override
  initRepository() async {
    if (kIsWeb) return; // Evita tocar no DB no Web
    await getLikedBloodCenters();
  }

  @override
  Future<List<BloodCenterModel>> getLikedBloodCenters() async {
    if (kIsWeb) return <BloodCenterModel>[]; // Web não usa sqflite
    db = await DatabaseHelper.instance.database;
    List bloodCenters = await db.rawQuery('SELECT * FROM BloodCenter');

    //Captura dados salvos no banco de dados local (row), e converte para lista (estrutura de dados List<>)
    List<BloodCenterModel> convertedList = List<BloodCenterModel>.generate(bloodCenters.length, (index) => BloodCenterModel.fromMap(bloodCenters[index], isFromApi: false), growable: true);
    return convertedList;
  }

  @override
  createBc(BloodCenterModel bloodCenter) async {
    if (kIsWeb) return; // No-op no Web
    db = await DatabaseHelper.instance.database;
    return await db.insert('BloodCenter', bloodCenter.toMap());
  }

  @override
  deleteBc(BloodCenterModel bloodCenter) async {
    if (kIsWeb) return; // No-op no Web
    db = await DatabaseHelper.instance.database;
    return await db.delete('BloodCenter', where: 'id = ${bloodCenter.id}');
  }

  @override
  deleteAllBcs() async {
    if (kIsWeb) return; // No-op no Web
    db = await DatabaseHelper.instance.database;
    return await db.delete('BloodCenter');
  }
}
