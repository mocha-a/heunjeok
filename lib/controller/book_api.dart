import 'dart:convert';
import 'package:http/http.dart' as http;

class BookApi {
  // 추천 도서
  static Future<List<dynamic>> recommendApi() async {
    final response = await http.get(
      Uri.parse('http://localhost/heunjeok-server/recommend.php'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body); // Map<String, dynamic>
      final List<dynamic> items = data; // item 리스트 추출
      return items; // 리스트 반환
    } else {
      throw Exception('책 검색 실패: ${response.statusCode}');
    }
  }

  // 베스트셀러
  static Future<List<dynamic>> bestsellerApi() async {
    final response = await http.get(
      Uri.parse('http://localhost/heunjeok-server/bestseller.php'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body); // Map<String, dynamic>
      final List<dynamic> items = data; // item 리스트 추출
      return items; // 리스트 반환
    } else {
      throw Exception('책 검색 실패: ${response.statusCode}');
    }
  }

  //검색
  static Future<Map<String, dynamic>> searchApi(
    String query, {
    int page = 1,
  }) async {
    final response = await http.get(
      Uri.parse(
        'http://localhost/heunjeok-server/search_book.php?query=${Uri.encodeComponent(query)}&page=$page',
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final totalResults = json['totalResults'];
      final List<dynamic> items = json['items'];

      return {'totalResults': totalResults, 'items': items};
    } else {
      throw Exception('책 검색 실패: ${response.statusCode}');
    }
  }

  //기록 검색
  static Future<Map<String, dynamic>> searchWiteApi(
    String query, {
    int page = 1,
  }) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse(
      'http://localhost/heunjeok-server/search_write.php?keyword=$encodedQuery',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('검색 실패: ${response.statusCode}');
    }
  }
}
