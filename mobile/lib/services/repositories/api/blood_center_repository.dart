import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vitalink/services/helpers/http_client.dart';
import 'package:vitalink/services/models/blood_center_model.dart';
import 'package:vitalink/services/models/page_model.dart';

abstract class IBloodRepository {
  Future<List<BloodCenterModel>> index(
      bool hasPagination,
      ValueNotifier<int> page,
      String search,
      ValueNotifier<List<PageModel>> pages);
}

class BloodRepository implements IBloodRepository {
  @override
  Future<List<BloodCenterModel>> index(
      bool hasPagination,
      ValueNotifier<int> page,
      String search,
      ValueNotifier<List<PageModel>> pages) async {
    try {
      final response = await MyHttpClient.get(
        url:
            '/blood-center?has_pagination=$hasPagination&page=${page.value}&search=$search',
        headers: MyHttpClient.getHeaders(),
      );
      if (response.statusCode == 200) {
        List<BloodCenterModel> bloodCenters = [];
        List<PageModel> localPages = [];
        final body = await jsonDecode(response.body);

        //Tratamento para quando há paginação, pois o escopo do JSON é alterado
        if (hasPagination) {
          //Construção dos models de paginação
          body['data']['links'].map((page) {
            if (page['label'] is int) {
              localPages.add(PageModel.fromMap(page as Map<String, dynamic>));
            }
          }).toList();

          //Atualiza a lista de páginas - semelhante a notifyListeners() do ChangeNotifier
          //Segue endereço de memória do parâmetro "pages" da função
          pages.value = localPages;

          //Contrução da listagem para quando há paginação
          final data = body['data']['data'];
          _parseList(data, bloodCenters);

          if (body['data'].containsKey('next_page_url')) {
            if (body['data']['next_page_url'] != null) {
              Uri uri = Uri.parse(body['data']['next_page_url']);
              String? pageString = uri.queryParameters['page'];
              int nextPage = int.parse(pageString!);
              page.value = nextPage;
            }
          }
        } else {
          //Contrução da listagem para quando NÃO há paginação
          final data = body['data'];
          _parseList(data, bloodCenters);
        }

        return bloodCenters;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw response.reasonPhrase!;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<BloodCenterModel> show(int id) async {
    try {
      final response = await MyHttpClient.get(
        url: '/blood-center/$id',
        headers: MyHttpClient.getHeaders(),
      );
      if (response.statusCode == 200) {
        final body = await jsonDecode(response.body);
        return BloodCenterModel.fromMap(body['data']);
      } else {
        throw response.reasonPhrase!;
      }
    } catch (e) {
      rethrow;
    }
  }

  void _parseList(dynamic data, List<BloodCenterModel> bloodCenters) {
    if (data is List) {
      for (var item in data) {
        try {
          bloodCenters.add(BloodCenterModel.fromMap(item));
        } catch (e) {
          // Ignore malformed items
        }
      }
    }
  }
}
