import 'dart:convert';

import 'package:vitalink/services/helpers/exceptions.dart';
import 'package:vitalink/services/helpers/http_client.dart';
import 'package:vitalink/services/models/news_model.dart';

abstract class INewsRepository {
  Future<List<NewsModel>> index(bool hasPagination, int page);
}

class NewsRepository implements INewsRepository {
  @override
  Future<List<NewsModel>> index(bool hasPagination, int page) async {
    try {
      final response = await MyHttpClient.get(
        url: '/news?has_pagination=$hasPagination&page=$page',
        headers: MyHttpClient.getHeaders(token: MyHttpClient.token),
      );

      if (response.statusCode == 200) {
        List<NewsModel> news = [];
        final data = jsonDecode(response.body)['data'];

        data.map((e) {
          news.add(NewsModel.fromMap(e as Map<String, dynamic>));
        }).toList();

        return news;
      } else if (response.statusCode == 404) {
        throw NotFoundException('Nâo foi possível buscar notícias');
      } else {
        throw 'Erro ao buscar notícias';
      }
    } catch (e) {
      rethrow;
    }
  }
}
