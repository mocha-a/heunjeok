import 'dart:convert';
import 'package:http/http.dart' as http;

class BookApi {
  // 베스트셀러
  static Future<List<dynamic>> bestsellerApi() async {
    final response = await http.get(
      Uri.parse('http://localhost/bestseller.php'),
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
  static Future<List<dynamic>> searchApi(String query) async {
    final response = await http.get(
      Uri.parse(
        'http://localhost/search.php?query=${Uri.encodeComponent(query)}',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body); // Map<String, dynamic>
      final List<dynamic> items = data; // item 리스트 추출
      return items; // 리스트 반환
    } else {
      throw Exception('책 검색 실패: ${response.statusCode}');
    }
  }
}
