import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heunjeok/controller/book_api.dart';

class BookController extends GetxController {
  var books = <dynamic>[].obs; // observable 리스트
  var isLoading = false.obs; // 로딩 상태 관리 (선택)

  // 검색 결과 함수
  Future<void> search(String query) async {
    isLoading.value = true;
    try {
      final result = await BookApi.searchApi(query);
      books.value = result; // 결과 저장
    } finally {
      isLoading.value = false;
    }
  }

  // 검색 내용
  void searchInput(TextEditingController controller) {
    final query = controller.text;
    search(query);
  }
}
