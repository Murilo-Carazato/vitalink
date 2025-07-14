import 'package:vitalink/services/helpers/database_helper.dart';
import 'package:vitalink/services/models/user_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class IUserRepository {
  IUserRepository() {
    initRepository();
  }
  initRepository();
  getUser();
  createUser(UserModel user);
  Future<int> updateUser(UserModel user);
}

class UserRepository implements IUserRepository {
  late Database db;

  UserRepository() {
    initRepository();
  }

  @override
  initRepository() async {
    await getUser();
  }

  @override
  getUser() async {
    db = await DatabaseHelper.instance.database;
    List users = await db.rawQuery('SELECT * FROM User');
    List<UserModel> convertedList = List<UserModel>.generate(
        users.length, (index) => UserModel.fromMap(users[index]),
        growable: true);
    return convertedList;
  }

  @override
  createUser(UserModel user) async {
    db = await DatabaseHelper.instance.database;
    await db.insert('User', user.toMap());
    getUser();
  }

  @override
  Future<int> updateUser(UserModel user) async {
    db = await DatabaseHelper.instance.database;
    return await db
        .update('User', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  // Improved clearTable method to handle SQLite constraints
  Future<void> clearTable() async {
    db = await DatabaseHelper.instance.database;
    try {
      // Use transaction for better atomicity
      await db.transaction((txn) async {
        // Delete all records from User table
        await txn.delete('User');
        print('User table cleared successfully');
      });
    } catch (e) {
      print('Error clearing User table: $e');
      
      // If direct delete fails, try with a more controlled approach
      try {
        // Get current users to preserve IDs if needed
        final users = await getUser();
        
        // Delete users one by one
        for (var user in users) {
          await db.delete('User', where: 'id = ?', whereArgs: [user.id]);
        }
        print('User table cleared using alternative method');
      } catch (e2) {
        print('All attempts to clear User table failed: $e2');
        throw Exception('Failed to clear user data: $e2');
      }
    }
  }
}
