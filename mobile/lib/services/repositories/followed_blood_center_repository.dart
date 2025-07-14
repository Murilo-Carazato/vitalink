import 'package:vitalink/services/helpers/database_helper.dart';
import 'package:vitalink/services/models/blood_center_model.dart';
import 'package:sqflite/sqflite.dart';

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
    await getLikedBloodCenters();
  }

  @override
  Future<List<BloodCenterModel>> getLikedBloodCenters() async {
    db = await DatabaseHelper.instance.database;
    List bloodCenters = await db.rawQuery('SELECT * FROM BloodCenter');

    //Captura dados salvos no banco de dados local (row), e converte para lista (estrutura de dados List<>)
    List<BloodCenterModel> convertedList = List<BloodCenterModel>.generate(bloodCenters.length, (index) => BloodCenterModel.fromMap(bloodCenters[index], isFromApi: false), growable: true);
    return convertedList;
  }

  @override
  createBc(BloodCenterModel bloodCenter) async {
    db = await DatabaseHelper.instance.database;
    return await db.insert('BloodCenter', bloodCenter.toMap());
  }

  @override
  deleteBc(BloodCenterModel bloodCenter) async {
    db = await DatabaseHelper.instance.database;
    return await db.delete('BloodCenter', where: 'id = ${bloodCenter.id}');
  }

  @override
  deleteAllBcs() async {
    db = await DatabaseHelper.instance.database;
    return await db.delete('BloodCenter');
  }
}
