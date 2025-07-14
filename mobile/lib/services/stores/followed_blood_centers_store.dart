import 'package:flutter/material.dart';
import 'package:vitalink/services/helpers/exceptions.dart';
import 'package:vitalink/services/models/blood_center_model.dart';
import 'package:vitalink/services/repositories/followed_blood_center_repository.dart';

class FollowedBloodCentersStore with ChangeNotifier{
  final IFollowedBloodCenterRepository repository;
  FollowedBloodCentersStore({required this.repository});

  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  ValueNotifier<List<BloodCenterModel>> state = ValueNotifier<List<BloodCenterModel>>([]);
  ValueNotifier<String> erro = ValueNotifier<String>('');

  Future index() async {
    isLoading.value = true;
    try {
      final result = await repository.getLikedBloodCenters();
      state.value = result;
    } on NotFoundException catch (e) {
      erro.value = e.message;
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  Future followBloodCenter(BloodCenterModel bloodCenter) async {
    isLoading.value = true;
    try {
      await repository.createBc(bloodCenter);
    } on NotFoundException catch (e) {
      erro.value = e.message;
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  Future unfollowBloodCenter(BloodCenterModel bloodCenter) async {
    isLoading.value = true;
    try {
      await repository.deleteBc(bloodCenter);
    } on NotFoundException catch (e) {
      erro.value = e.message;
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  Future unfollowAllBloodCenter() async {
    isLoading.value = true;
    try {
      await repository.deleteAllBcs();
    } on NotFoundException catch (e) {
      erro.value = e.message;
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }
}
