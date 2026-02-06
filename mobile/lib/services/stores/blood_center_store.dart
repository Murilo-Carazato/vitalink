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
  ValueNotifier<BloodCenterModel?> selectedBloodCenter = ValueNotifier<BloodCenterModel?>(null);
  ValueNotifier<List<BloodCenterModel>> dropdownBloodCenters = ValueNotifier<List<BloodCenterModel>>([]);

  Future<void> fetchForDropdown() async {
    // Evita chamadas repetidas se a lista já estiver carregada
    if (dropdownBloodCenters.value.isNotEmpty) return;

    isLoading.value = true;
    erro.value = '';
    try {
      // A paginação não é relevante aqui, mas o repositório espera os notifiers
      final tempPage = ValueNotifier<int>(1);
      final tempPages = ValueNotifier<List<PageModel>>([]);
      
      // hasPagination: false para buscar todos, search: '' para não filtrar
      final result = await repository.index(false, tempPage, '', tempPages);
      dropdownBloodCenters.value = result;
    } catch (e) {
      erro.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }


  // Atualizado: sempre atualiza stateWhenPaginate, para que a tela sempre use esse notifier
  Future<void> index(bool hasPagination, String search, {bool forceRefresh = false}) async {
    // Se já temos dados, não estamos em modo de busca e não foi forçado o refresh, retorna os dados atuais
    if (!forceRefresh &&
        !hasPagination &&
        search.isEmpty &&
        state.value.isNotEmpty) {
      stateWhenPaginate.value = state.value;
      return;
    }

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
    } catch (e, stackTrace) {
      print('error: $e , stackTrace: $stackTrace');
      erro.value = e.toString();
      state.value = [];
      stateWhenPaginate.value = [];
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }
  
  Future<void> show(int id) async {
    isLoading.value = true;
    erro.value = '';
    try {
      final result = await (repository as BloodRepository).show(id);
      selectedBloodCenter.value = result;
    } on NotFoundException catch (e) {
      erro.value = e.message;
      selectedBloodCenter.value = null;
    } catch (e) {
      erro.value = e.toString();
      selectedBloodCenter.value = null;
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }
}