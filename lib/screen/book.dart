import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:heunjeok/utils/scroll_listener.dart';
import 'package:heunjeok/widgets/dialog.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:heunjeok/widgets/book_item.dart';

class Book extends StatefulWidget {
  void Function(double) changePadding;
  Book({super.key, required this.changePadding});

  @override
  State<Book> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Book> {
  var bookapiUrl = dotenv.env['BOOK_API_URL'];
  List<Map<String, dynamic>> book = []; // 책 정보
  List<Map<String, dynamic>> reviews = []; // 리뷰 목록
  late final ScrollController _scrollController;

  int totalResults = 0;
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    widget.changePadding(18);

    // 스크롤 리스너 연결
    _scrollController = scroll(
      onReachBottom: () async {
        if (!isLoading && hasMore) {
          setState(() => isLoading = true);

          final nextPage = currentPage + 1;
          final newReviews = await fetchAllReviews(nextPage);

          if (newReviews.isNotEmpty) {
            setState(() {
              reviews.addAll(newReviews);
              currentPage = nextPage;
            });
          } else {
            setState(() => hasMore = false);
          }

          setState(() => isLoading = false);
        }
      },
    );

    // 최초 데이터 로드
    fetchAllReviews(1).then((newReviews) {
      setState(() {
        reviews = newReviews;
        currentPage = 1;
        hasMore = true;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchAllReviews(int page) async {
    final response = await http.get(
      Uri.parse('${bookapiUrl}/all_get.php?page=$page'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);

      //총 개수
      // 총 개수는 최초 한 번만 설정해도 됨
      if (page == 1) {
        totalResults = json['total'];
      }

      final List<dynamic> data = json['reviews'];

      // 책별로 묶거나 전체 리뷰 표시 등 원하는대로 처리
      return data
          .map<Map<String, dynamic>>(
            (item) => {
              "book_id": item["book_id"] ?? 0,
              "book_title": item["book_title"] ?? '',
              "book_author": item["book_author"] ?? '',
              "book_publisher": item["book_publisher"] ?? '',
              "book_cover": item["book_cover"] ?? '',
              "nickname": item["nickname"] ?? '',
              "content": item["content"] ?? '',
              "rating": item["rating"] ?? 0,
              "date": item["date"] ?? '',
              "password": item["password"] ?? '',
            },
          )
          .toList();
    } else {
      print("서버 응답 오류: ${response.statusCode}");
      return [];
    }
  }

  bool isLatestSort = true;

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> sortedReviews = List.from(reviews);
    if (isLatestSort) {
      sortedReviews.sort((a, b) => b["date"].compareTo(a["date"]));
    } else {
      sortedReviews.sort((a, b) => b["rating"].compareTo(a["rating"]));
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(height: 25),
          if (reviews.isNotEmpty) ...[
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "$totalResults",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 242, 151, 160),
                        ),
                      ),
                      TextSpan(
                        text: "개의 독서기록이 있습니다!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 67, 103, 65),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                TextButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.resolveWith<Color?>((
                      Set<MaterialState> states,
                    ) {
                      if (states.contains(MaterialState.hovered)) {
                        return Color.fromARGB(50, 182, 187, 121);
                      }
                      if (states.contains(MaterialState.pressed)) {
                        return Color.fromARGB(100, 182, 187, 121);
                      }
                      return null; // 기본값
                    }),
                  ),
                  onPressed: () {
                    setState(() {
                      isLatestSort = !isLatestSort;
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        isLatestSort ? "최신순" : "별점순",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 51, 51, 51),
                        ),
                      ),
                      SizedBox(width: 6),
                      SvgPicture.asset("assets/recycle.svg"),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: sortedReviews.length,
                itemBuilder: (context, idx) {
                  final review = sortedReviews[idx];
                  // // 해당 리뷰의 책 이미지 가져오기
                  // final matchedBook = book.firstWhere(
                  //   (b) => b["id"] == review["book_id"],
                  //   orElse: () => {},
                  // );
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: BookItem(
                      image: review["book_cover"] ?? '이미지 없음',
                      nickname: review["nickname"] ?? '닉네임 없음',
                      date: review["date"] ?? '날짜 없음',
                      content: review["content"] ?? '내용 없음',
                      onTap: () {
                        alertDialog(context, review, () async {
                          final newReviews = await fetchAllReviews(1);
                          setState(() {
                            sortedReviews = newReviews;
                          });
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 150),
                  Image.asset('assets/nolist.png', width: 176),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  //클릭 시 기록 확인 팝업
  void alertDialog(
    BuildContext context,
    Map<String, dynamic> bookItem,
    Future<void> Function() refreshCallback,
  ) async {
    final result = await showDialog(
      context: context,
      builder: (context) =>
          ReviewDialog(bookItem: bookItem, onReturn: refreshCallback),
    );

    if (result == true) {
      await refreshCallback();
    }
  }
}
