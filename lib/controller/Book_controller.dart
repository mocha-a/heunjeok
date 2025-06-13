import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heunjeok/controller/book_api.dart';

class BookController extends GetxController {
  var books = <dynamic>[].obs; //검색 결과 리스트
  var total = 0.obs; //검색 결과 개수

  var isLoading = false.obs; //로딩 상태 관리
  var isLoadMore = false.obs; //여기에 추가

  final RxString currentQuery = ''.obs;
  var page = 1.obs; // 현재 페이지
  var currentPage = 1.obs; //페이지

  var isEnd = false.obs; // 더 불러올 데이터가 없으면 true

  Future<void> search(String query, {bool isLoadMore = false}) async {
    //Load More가 아니면 (즉, 새로 검색이면)
    if (!isLoadMore) {
      currentPage.value = 1;
      books.clear();
    } else {
      currentPage.value++; // Load More면 페이지 번호 1 증가
    }

    //현재 검색어와 로딩 상태 갱신
    currentQuery.value = query; // 검색어 저장
    this.isLoadMore.value = isLoadMore; // Load More 여부 저장
    isLoading.value = true; // 로딩 시작 표시

    try {
      final result = await BookApi.searchApi(query, page: currentPage.value);
      final totalResults = result['totalResults'];
      final List<dynamic> newItems = result['items'];

      //결과 개수
      total.value = totalResults;

      //결과를 기존 데이터에 추가할지, 새로 덮어쓸지 결정
      if (isLoadMore) {
        books.addAll(newItems);
      } else {
        books.value = newItems; // 새 검색 시 리스트 교체
      }
    } finally {
      //API 호출 끝나면 로딩 상태 해제
      isLoading.value = false;
      this.isLoadMore.value = false;
    }
  }
}
