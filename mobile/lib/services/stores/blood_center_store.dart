import 'package:flutter/material.dart';
import 'package:vitalink/services/helpers/exceptions.dart';
import 'package:vitalink/services/models/blood_center_model.dart';
import 'package:vitalink/services/models/page_model.dart';
import 'package:vitalink/services/repositories/api/blood_center_repository.dart';

class BloodCenterStore with ChangeNotifier {
  final IBloodRepository repository;
  BloodCenterStore({required this.repository});

  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  ValueNotifier<int> page = ValueNotifier<int>(1);
  ValueNotifier<List<PageModel>> pages = ValueNotifier<List<PageModel>>([]);
  ValueNotifier<bool> isSearchMode = ValueNotifier<bool>(false);
  ValueNotifier<List<BloodCenterModel>> state = ValueNotifier<List<BloodCenterModel>>([]);
  ValueNotifier<List<BloodCenterModel>> stateWhenPaginate = ValueNotifier<List<BloodCenterModel>>([]);
  ValueNotifier<String> erro = ValueNotifier<String>('');

  // Atualizado: sempre atualiza stateWhenPaginate, para que a tela sempre use esse notifier
  Future<void> index(bool hasPagination, String search) async {
    isLoading.value = true;
    erro.value = '';
    try {
      final result = await repository.index(hasPagination, page, search, pages);
      if (hasPagination) {
        stateWhenPaginate.value = result;
      } else {
        state.value = result;
        stateWhenPaginate.value = result; // <- importante para exibir busca na tela
      }
    } on NotFoundException catch (e) {
      erro.value = e.message;
      state.value = [];
      stateWhenPaginate.value = [];
    } catch (e) {
      erro.value = e.toString();
      state.value = [];
      stateWhenPaginate.value = [];
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }
}