import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:heunjeok/widgets/cover_image.dart';

class Detail extends StatefulWidget {
  final int id;
  const Detail({super.key, required this.id});

  @override
  State<Detail> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Detail> {
  List<dynamic> selectedBook = [];
  List<Map<String, dynamic>> reviews = []; // 리뷰 목록

  final formkey = GlobalKey<FormState>();
  TextEditingController reviewController = TextEditingController();
  String? editingName;

  String? nickname;
  String? password;
  String? content;

  @override
  void initState() {
    super.initState();
    print("불러올 id: ${widget.id}");
    itemIDApi(widget.id);
    loadReviews();
  }

  //itmeId 값으로 책 정보 가져오기
  Future<void> itemIDApi(int itemId) async {
    final response = await http.get(
      Uri.parse('http://localhost/heunjeok-server/item_id.php?itemId=$itemId'),
    );

    setState(() {
      selectedBook = json.decode(response.body);
    });
  }

  Future<void> loadReviews() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost/heunjeok-server/bookreviews/review_get.php?bookId=${widget.id}',
        ),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print("받아온 리뷰 데이터: $data");
        setState(() {
          reviews = data.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      }
    } catch (e) {
      print('Error fetching reviews: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Color.fromRGBO(51, 51, 51, 1)),
        ),
        fontFamily: 'SUITE',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.transparent),
        appBarTheme: AppBarTheme(backgroundColor: Colors.transparent),
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: SvgPicture.asset('back.svg', width: 18),
          ),
        ),
        body: selectedBook.isEmpty
            ? Center(
                child: Image.asset(
                  'loading_green.gif',
                  width: 316,
                  height: 316,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none, // 음수 위치도 허용
                      children: [
                        CoverImage(
                          imagePath: selectedBook[0]['cover'],
                          height: 470,
                        ),
                      ],
                    ),
                    Transform.translate(
                      offset: Offset(0, -20),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${selectedBook[0]['title']}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "${selectedBook[0]['description']}",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "${selectedBook[0]['author']} / ${selectedBook[0]['publisher']}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "${selectedBook[0]['pubDate']}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 85, 85, 85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 25),
                            Divider(
                              color: Color.fromARGB(255, 153, 153, 153),
                              thickness: 2.5,
                            ),
                            SizedBox(height: 25),
                            Container(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "독서기록 ${reviews.length}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  ...reviews.map((review) {
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              review['nickname'],
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            Spacer(),
                                            TextButton(
                                              onPressed: () {
                                                if (!review.containsKey(
                                                  'review_id',
                                                )) {
                                                  return;
                                                }
                                                final rawReviewId =
                                                    review["review_id"];
                                                final int reviewId =
                                                    (rawReviewId is int)
                                                    ? rawReviewId
                                                    : int.tryParse(
                                                            rawReviewId
                                                                .toString(),
                                                          ) ??
                                                          0;

                                                passwordAlertDialog(
                                                  reviewId: reviewId,
                                                  onConfirmed: (String password) async {
                                                    // 비번 확인되면 수정폼 열기
                                                    final result = await addForm(
                                                      context,
                                                      initialNickname:
                                                          review["nickname"],
                                                      initialContent:
                                                          review["content"],
                                                      initialRating:
                                                          double.tryParse(
                                                            review["rating"]
                                                                .toString(),
                                                          ) ??
                                                          0.0,
                                                      initialPassword: '',
                                                      isEdit: true,
                                                      reviewId: reviewId,
                                                    );
                                                    if (result == 'success') {
                                                      // 수정 성공 시 리뷰 목록 다시 받아오기 or 상태 업데이트
                                                      await loadReviews(); // 서버에서 최신 리뷰 목록 재로딩 함수
                                                      setState(() {}); // 화면 갱신
                                                    }
                                                  },
                                                );
                                              },
                                              style: ButtonStyle(
                                                padding:
                                                    MaterialStateProperty.all(
                                                      EdgeInsets.zero,
                                                    ),
                                                minimumSize:
                                                    MaterialStateProperty.all(
                                                      Size(0, 0),
                                                    ),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                overlayColor:
                                                    MaterialStateProperty.all(
                                                      Colors.transparent,
                                                    ),
                                              ),

                                              child: Text(
                                                "수정",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w300,
                                                  color: Color.fromARGB(
                                                    255,
                                                    153,
                                                    153,
                                                    153,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 7),
                                            TextButton(
                                              onPressed: () {
                                                if (!review.containsKey(
                                                  'review_id',
                                                )) {
                                                  return;
                                                }
                                                final rawReviewId =
                                                    review["review_id"];
                                                final int reviewId =
                                                    (rawReviewId is int)
                                                    ? rawReviewId
                                                    : int.tryParse(
                                                            rawReviewId
                                                                .toString(),
                                                          ) ??
                                                          0;

                                                passwordAlertDialog(
                                                  reviewId: reviewId,
                                                  onConfirmed:
                                                      (String password) {
                                                        deleteAlertDialog(
                                                          context,
                                                          () {
                                                            deleteReview(
                                                              reviewId,
                                                              password,
                                                            );
                                                          },
                                                        );
                                                      },
                                                );
                                              },
                                              style: ButtonStyle(
                                                padding:
                                                    MaterialStateProperty.all(
                                                      EdgeInsets.zero,
                                                    ),
                                                minimumSize:
                                                    MaterialStateProperty.all(
                                                      Size(0, 0),
                                                    ),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                overlayColor:
                                                    MaterialStateProperty.all(
                                                      Colors.transparent,
                                                    ),
                                              ),
                                              child: Text(
                                                "삭제",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w300,
                                                  color: Color.fromARGB(
                                                    255,
                                                    153,
                                                    153,
                                                    153,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 3),
                                        Row(
                                          children: [
                                            RatingBar(
                                              initialRating: review["rating"]
                                                  .toDouble(),
                                              minRating: 0,
                                              direction: Axis.horizontal,
                                              allowHalfRating: true,
                                              ignoreGestures: true, //읽기 전용
                                              itemCount: 5,
                                              itemSize: 20,
                                              ratingWidget: RatingWidget(
                                                full: Icon(
                                                  Icons.star_rate_rounded,
                                                  color: Color.fromRGBO(
                                                    242,
                                                    151,
                                                    160,
                                                    1,
                                                  ), //꽉 찬 별
                                                ),
                                                half: Icon(
                                                  Icons.star_half_rounded,
                                                  color: Color.fromRGBO(
                                                    242,
                                                    151,
                                                    160,
                                                    1,
                                                  ), //반 별
                                                ),
                                                empty: Icon(
                                                  Icons.star_outline_rounded,
                                                  color: Color.fromRGBO(
                                                    242,
                                                    151,
                                                    160,
                                                    1,
                                                  ), //빈 별
                                                ),
                                              ),
                                              onRatingUpdate:
                                                  (_) {}, //필수 옵션이라 비어 둠
                                            ),
                                            Container(
                                              margin: EdgeInsets.symmetric(
                                                horizontal: 10,
                                              ),
                                              width: 0.5,
                                              height: 12,
                                              color: Color.fromARGB(
                                                255,
                                                85,
                                                85,
                                                85,
                                              ),
                                            ),
                                            Text(
                                              "${review['date']}",
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w300,
                                                color: Color.fromARGB(
                                                  255,
                                                  85,
                                                  85,
                                                  85,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 3),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "${review['content']}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Divider(
                                          color: Color.fromARGB(
                                            255,
                                            153,
                                            153,
                                            153,
                                          ),
                                          thickness: 1,
                                        ),
                                        SizedBox(height: 10),
                                      ],
                                    );
                                  }).toList(),
                                  SizedBox(height: 30),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final scaffoldContext = context;
                                      final result = await addForm(
                                        context,
                                      ); // 팝업 위젯

                                      if (result == 'success') {
                                        // // 팝업 닫힌 뒤 실행돼야 SnackBar가 잘 보임
                                        // ScaffoldMessenger.of(
                                        //   context,
                                        // ).showSnackBar(
                                        //   SnackBar(
                                        //     content: Text('기록 내용이 저장되었습니다.'),
                                        //     backgroundColor: Color.fromARGB(
                                        //       255,
                                        //       242,
                                        //       151,
                                        //       160,
                                        //     ),
                                        //     delaye: Duration(seconds: 2),
                                        //   ),
                                        // );

                                        await loadReviews(); // 리뷰 다시 불러오기
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color.fromARGB(
                                        255,
                                        182,
                                        187,
                                        121,
                                      ),
                                      minimumSize: Size(double.infinity, 44),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 0,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 20,
                                      ),
                                    ),
                                    child: Text(
                                      "흔적 남기기",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  //기록내용 추가 팝업
  Future<String?> addForm(
    context, {
    String? initialNickname,
    String? initialContent,
    String? initialPassword,
    double initialRating = 0.0,
    bool isEdit = false,
    int? reviewId,
  }) {
    final TextEditingController nicknameController = TextEditingController(
      text: initialNickname ?? '',
    );
    final TextEditingController contentController = TextEditingController(
      text: initialContent ?? '',
    );
    final TextEditingController passwordController = TextEditingController(
      text: initialPassword ?? '',
    );

    double rating = initialRating;

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Form(
                    key: formkey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: RatingBar.builder(
                            initialRating: rating,
                            glow: false,
                            minRating: 0.5,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 25,
                            itemPadding: EdgeInsets.symmetric(horizontal: 2),
                            itemBuilder: (context, _) => Icon(
                              Icons.star_rate_rounded,
                              color: Color.fromARGB(255, 242, 151, 160),
                            ),
                            unratedColor: Color.fromARGB(255, 238, 203, 206),
                            onRatingUpdate: (newRating) {
                              setModalState(() {
                                rating = newRating;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: nicknameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "닉네임을 입력해 주세요!";
                            }
                            return null;
                          },
                          decoration: InputDecoration(labelText: '닉네임'),
                          onSaved: (value) {
                            nickname = value;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: contentController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "기록 내용을 입력해 주세요!";
                            }
                            return null;
                          },
                          maxLines: 5,
                          decoration: InputDecoration(labelText: '기록내용'),
                          onSaved: (value) {
                            content = value;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "비밀번호를 입력해 주세요!";
                            }
                            return null;
                          },
                          decoration: InputDecoration(labelText: '비밀번호'),
                          onSaved: (value) {
                            password = value;
                          },
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (formkey.currentState!.validate()) {
                              if (isEdit &&
                                  (reviewId == null || reviewId == 0)) {
                                print("잘못된 reviewId: $reviewId");
                                return;
                              }

                              // formkey.currentState!.save();
                              final passwordValue = passwordController.text;
                              final nicknameValue = nicknameController.text;
                              final contentValue = contentController.text;

                              final body = isEdit
                                  ? {
                                      'review_id': reviewId.toString(),
                                      'rev_nickname': nicknameController.text,
                                      'password': passwordController.text,
                                      'rev_content': contentController.text,
                                      'rev_rating': rating.toString(),
                                    }
                                  : {
                                      'book_id': selectedBook[0]['itemId']
                                          .toString(),
                                      'book_cover': selectedBook[0]['cover'],
                                      'book_title': selectedBook[0]['title'],
                                      'book_author': selectedBook[0]['author'],
                                      'book_publisher':
                                          selectedBook[0]['publisher'],
                                      'book_pubDate':
                                          selectedBook[0]['pubDate'],
                                      'rev_nickname': nicknameController.text,
                                      'rev_password': passwordController.text,
                                      'rev_content': contentController.text,
                                      'rev_rating': rating.toString(),
                                    };

                              if (isEdit &&
                                  (reviewId == null || reviewId == 0)) {
                                print("수정 요청인데 reviewId가 없습니다.");
                                return;
                              }

                              final response = await http.post(
                                Uri.parse(
                                  isEdit
                                      ? "http://localhost/heunjeok-server/bookreviews/update.php"
                                      : "http://localhost/heunjeok-server/bookreviews/insert.php",
                                ),
                                body: body,
                              );

                              if (response.statusCode == 200) {
                                final responseBody = utf8.decode(
                                  response.bodyBytes,
                                );
                                final result = json.decode(responseBody);
                                print("서버 응답: $result");
                                if (result['success'] == true) {
                                  Navigator.pop(context, 'success'); // 팝업 닫기
                                } else {
                                  print(
                                    "서버에서 실패 응답 받음: ${result['message'] ?? '메시지 없음'}",
                                  );
                                }
                              } else {
                                print("서버 요청 실패: ${response.statusCode}");
                              }
                              print(response.body.runtimeType); // 타입 확인
                              print(response.body); // 실제 값
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 182, 187, 121),
                            elevation: 0,
                          ),
                          child: Text(
                            '저장',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 239, 239, 239),
                            elevation: 0,
                          ),
                          child: Text(
                            '취소',
                            style: TextStyle(
                              color: Color.fromARGB(255, 51, 51, 51),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  //흔적 비밀번호 팝업
  void passwordAlertDialog({
    required int reviewId,
    required void Function(String password) onConfirmed,
  }) {
    final TextEditingController pwController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text('비밀번호를 입력해주세요.'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: pwController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: '흔적 남길 때 작성한 비밀번호를 입력해주세요',
                      errorText: errorMessage,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final pw = pwController.text;
                    final result = await checkPasswordServer(reviewId, pw);

                    if (result) {
                      Navigator.pop(context);
                      onConfirmed(pw); // 서버 확인 통과 시
                    } else {
                      setState(() {
                        errorMessage = '비밀번호가 일치하지 않습니다.';
                      });
                    }
                  },
                  child: Text('확인'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('취소'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  //흔적 삭제 팝업
  void deleteAlertDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Text('삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                onConfirm();
                Navigator.pop(context);
              },
              child: Text('확인'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }

  //흔적 삭제 함수
  void deleteReview(int reviewId, String password) async {
    final response = await http.post(
      Uri.parse('http://localhost/heunjeok-server/bookreviews/delete.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'review_id': reviewId, 'password': password.trim()}),
    );
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      setState(() {
        reviews = List.from(reviews)
          ..removeWhere(
            (review) => review['review_id'].toString() == reviewId.toString(),
          );
      });
      print("삭제 성공");
    } else {
      print("삭제 실패: ${data['message']}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('삭제 실패: ${data['message']}')));
    }
  }

  //비밀번호 확인용 함수
  Future<bool> checkPasswordServer(int reviewId, String password) async {
    final bodyJson = jsonEncode({
      'review_id': reviewId,
      'password': password.trim(),
    });
    print("서버에 보내는 JSON body: $bodyJson");

    final response = await http.post(
      Uri.parse(
        'http://localhost/heunjeok-server/bookreviews/password_check.php',
      ),
      headers: {'Content-Type': 'application/json'},
      body: bodyJson,
    );
    print("[Flutter] 서버 응답 상태 코드: ${response.statusCode}");
    print("[Flutter] 서버 응답 body: ${response.body}");

    final data = json.decode(response.body);
    return data['success'] == true;
  }
}
