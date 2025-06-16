import 'dart:convert';
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
  List<Map<String, dynamic>> book = []; // 책 정보
  List<Map<String, dynamic>> reviews = []; // 리뷰 목록

  @override
  void initState() {
    super.initState();
    widget.changePadding(18);
    // 서버 호출
    fetchAllReviews();
  }

  Future<void> fetchAllReviews() async {
    final response = await http.get(
      Uri.parse('http://localhost/heunjeok-server/bookreviews/all_get.php'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      print(response.body);

      // 책별로 묶거나 전체 리뷰 표시 등 원하는대로 처리
      setState(() {
        reviews = data
            .map(
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
      });
    } else {
      print("서버 응답 오류: ${response.statusCode}");
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

    return Column(
      children: [
        SizedBox(height: 25),
        if (reviews.isNotEmpty) ...[
          Row(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "${reviews.length}",
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
                    SvgPicture.asset("recycle.svg"),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
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
                      alertDialog(context, review, fetchAllReviews);
                      print('책 클릭 ID값 : ${review["id"]}');
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
                Image.asset('nolist.png', width: 176),
              ],
            ),
          ),
        ],
      ],
    );
  }

  //클릭 시 기록 확인 팝업
  void alertDialog(
    BuildContext context,
    Map<String, dynamic> bookItem,
    VoidCallback refreshCallback,
  ) async {
    final result = await showDialog(
      context: context,
      builder: (context) =>
          ReviewDialog(bookItem: bookItem, onReturn: refreshCallback),
    );
    if (result == true) {
      refreshCallback();
    }
  }
}
