import '../../data/database/database_helper.dart';
import '../../data/models/location.dart';
import '../../data/models/adhan_time.dart';
import '../../data/models/current_location.dart';
import '../../data/models/current_adhan.dart';
import '../../data/database/adhan_times_dao.dart';
import '../../data/database/database_helper.dart';
import '../../data/database/database.dart';
import '../../data/database/database_manager.dart';

class Handler {
  AdhanTimesDao adhanTimesDao = AdhanTimesDao();

  DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<void> checkError() async {
    final bool rCheckEmpty = await checkEmpty();
    if (rCheckEmpty) {
      await DatabaseManager.instance.populateInitialData();
    } else {
      print("Error Not Found");
    }
  }

  Future<bool> checkEmpty() async {
    final locations = await _databaseHelper.query(AppDatabase.tableLocation);
    final currentLocation =
        await _databaseHelper.query(AppDatabase.tableCurrentLocation);
    final currentAdhan =
        await _databaseHelper.query(AppDatabase.tableCurrentAdhan);
    final adhanTimes = await _databaseHelper.query(AppDatabase.tableAdhanTimes);

    if (adhanTimes.isEmpty &&
        currentAdhan.isEmpty &&
        currentLocation.isEmpty &&
        locations.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkAdhanTimeHandler() async {
    await checkLocationHandler();

    final adhanTimes = await _databaseHelper.query(AppDatabase.tableAdhanTimes);
    if (adhanTimes.isEmpty) {
      print("problem : adhanTimes is empty");
      return true;
    } else {
      print("adhanTimes is not found");
      return false;
    }
  }

  Future<bool> checkLocationHandler() async {
    final locations = await _databaseHelper.query(AppDatabase.tableLocation);
    if (locations.isEmpty) {
      print("problem : locations is empty");
      return true;
    } else {
      print("locations is not found");
      return false;
    }
  }

  Future<bool> checkCurrentLocationHandler() async {
    final currentLocation =
        await _databaseHelper.query(AppDatabase.tableCurrentLocation);
    if (currentLocation.isEmpty) {
      print("problem : currentLocation is empty");
      return true;
    } else {
      print("currentLocation is not found");
      return false;
    }
  }

  Future<bool> checkCurrentAdhanHandler() async {
    /// الشروط  2- اوقات الصلاة حسب الموقع موجودة 1- الموقع الحالي موجود
    await checkAdhanTimeHandler();
    await checkCurrentLocationHandler();
    final currentAdhan =await _databaseHelper.query(AppDatabase.tableCurrentAdhan);
    if (currentAdhan.isEmpty) {
      print("problem : currentAdhan is empty");
      return true;
    } else {
      print("currentAdhan is not found");
      return false;
    }
  }

  Future<bool> adhanTimeHandler() async {
    print("adhanTimeHandler");
    final bool RcheckLocation = await checkLocationHandler();
    if (RcheckLocation == false) {
      ///...
      ///
      checkError();

      ///
      ///...
      print("adhanTimeHandler");
      final bool RcheckAdhanTime = await checkAdhanTimeHandler();
      if (RcheckAdhanTime == true) {
        print("adhanTimeHandler : Problem in adhanTime table");
        return false;
      } else {
        print("adhanTimeHandler : Problem Not Found");
        return true;
      }
    } else {
      await locationHandler();
      final bool RcheckLocation2 = await checkLocationHandler();
      if (RcheckLocation2 == false) {
        return adhanTimeHandler();
      } else {
        print("AdhanTimeHandler : Problem in location table");
        return false;
      }
    }
  }

  Future<bool> currentLocationHandler() async {
    if (await checkLocationHandler()) locationHandler();
    final bool RcheckLocation = await checkLocationHandler();

    if (RcheckLocation == true) {
      print("u need solve location problem firstly");
      return false;
    } else {
      ///...
      ///
      if ((await _databaseHelper.query(AppDatabase.tableCurrentLocation))
          .isEmpty) checkError();
      final bool RcheckCurrentLocation = await checkCurrentLocationHandler();
      final resultCurrentLocation =await _databaseHelper.query(AppDatabase.tableCurrentLocation);

      if (resultCurrentLocation.isNotEmpty || RcheckCurrentLocation == true) {
        final currentLocation =await _databaseHelper.query(AppDatabase.tableCurrentLocation);
        final currentLocationId = currentLocation[0]['id'];
        final location = await _databaseHelper.query(AppDatabase.tableLocation);
        if (location.any((element) => element['id'] == currentLocationId)) {
          //checkError();
          print("Not found problem in locationHandler");
          print("1- checked currentLocationId in location table");
          print("2- checked currentLocation is not empty");
          print("3- checked locationHandler is correct");
          return true;
        } else {
          print("currentLocationHandler : currentLocationId is not found in location table");
          //checkError();
          return false;
        }
      } else {
        if (resultCurrentLocation.isNotEmpty) {
          print("currentLocation is empty and i cant solve it");
          return false;
        } else {
          print(" unknown problem");
          return false;
        }
      }
    }
  }

  Future<bool> locationHandler() async {
    checkError();
    if (await checkEmpty()) {
      print("problem / locationHandler : database has problem  we have empty");
      return false;
    } else {
      if (await checkLocationHandler()) {
        print(" locationHandler  is correct");
        return true;
      } else {
        print("problem / locationHandler : unknown error");
        return false;
      }
    }
  }

  Future<bool> handleAdhanTime() async {

    if (await checkLocationHandler()) locationHandler();
    final bool RcheckLocation = await checkLocationHandler();
    if (RcheckLocation == false) {
      final bool RcheckAdhanTime = await checkAdhanTimeHandler();
      if (RcheckAdhanTime) {
        print("problem / handleAdhanTime : Problem in adhanTime table");
        print("No problem in location table");
        return false;
      } else {
        print("handleAdhanTime : Problem Not Found");
        return true;
      }
    } else {
      print("problem / handleAdhanTime : Problem in location table");
      return false;
    }

    

  }
}
