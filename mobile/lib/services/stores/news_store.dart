import 'package:flutter/material.dart';
import 'package:vitalink/services/helpers/exceptions.dart';
import 'package:vitalink/services/models/news_model.dart';
import 'package:vitalink/services/repositories/api/news_repository.dart';

class NewsStore {
  final INewsRepository repository;
  NewsStore({required this.repository});

  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  ValueNotifier<List<NewsModel>> state = ValueNotifier<List<NewsModel>>([]);
  ValueNotifier<String> erro = ValueNotifier<String>('');

  Future index(bool hasPagination, int page) async {
    isLoading.value = true;
    try {
      final result = await repository.index(hasPagination, page);
      state.value = result;
    } on NotFoundException catch (e) {
      erro.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }
}
