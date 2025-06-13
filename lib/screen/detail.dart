import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:heunjeok/widgets/cover_image.dart';

// 왼쪽 절반만 보이도록 클리퍼 구현
class _HalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width / 2, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}

class Detail extends StatefulWidget {
  final int id;
  const Detail({super.key, required this.id});

  @override
  State<Detail> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Detail> {
  Map<String, dynamic>? selectedBook;
  List<Map<String, dynamic>> reviews = []; // 리뷰 목록

  final formkey = GlobalKey<FormState>();
  TextEditingController reviewController = TextEditingController();
  String? editingName;

  String? nickname;
  String? password;
  String? content;
  double rating = 2.5; // 기록내용 작성 시 열리는 팝업 초기 별점 값

  @override
  void initState() {
    super.initState();
    print("불러올 id: ${widget.id}");
    recommend();
    loadReviews();
    // 실제 서버 호출로 변경하기
    // fetchBookAndReviews(widget.id);
  }

  Future<void> recommend() async {
    String jsonString = await rootBundle.loadString('bbbbb.json');
    List<dynamic> jsonData = json.decode(jsonString);
    final found = jsonData.firstWhere(
      (item) => item['itemId'] == widget.id,
      orElse: () => null,
    );

    if (found != null) {
      setState(() {
        selectedBook = found;
      });
    } else {
      print('해당 ID의 책을 찾을 수 없습니다.');
    }
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
        body: selectedBook == null
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
                          imagePath: selectedBook!['cover'],
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
                                    "${selectedBook!['title']}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "${selectedBook!['description']}",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "${selectedBook!['publisher']} / ${selectedBook!['author']}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "${selectedBook!['pubDate']}",
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
                                                passwordAlertDialog((pw) {
                                                  setState(() {
                                                    reviewController.text =
                                                        review["content"];
                                                    editingName =
                                                        review["nickname"];
                                                  });
                                                }, review["password"]);
                                                print(
                                                  "비밀번호 확인용: ${review["password"]}",
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
                                                passwordAlertDialog((pw) {
                                                  if (pw ==
                                                      review["password"]) {
                                                    deleteAlertDialog(
                                                      context,
                                                      () {
                                                        deleteReview(
                                                          review["review_id"],
                                                        );
                                                      },
                                                    );
                                                  }
                                                }, review["password"]);
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
                                            RatingBarIndicator(
                                              rating: review["rating"],
                                              itemCount: 5,
                                              itemSize: 20,
                                              direction: Axis.horizontal,
                                              itemBuilder: (context, index) {
                                                final fullStars =
                                                    review["rating"].floor();
                                                final hasHalfStar =
                                                    (review["rating"] -
                                                        fullStars) >=
                                                    0.5;
                                                if (index < fullStars) {
                                                  // 꽉 찬 별
                                                  return Icon(
                                                    Icons.star_rate_rounded,
                                                    color: Color.fromARGB(
                                                      255,
                                                      242,
                                                      151,
                                                      160,
                                                    ),
                                                  );
                                                } else if (index == fullStars &&
                                                    hasHalfStar) {
                                                  // 반 별 커스텀
                                                  return Stack(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .star_outline_rounded,
                                                        color: Color.fromARGB(
                                                          255,
                                                          242,
                                                          151,
                                                          160,
                                                        ),
                                                      ),
                                                      ClipRect(
                                                        clipper: _HalfClipper(),
                                                        child: Icon(
                                                          Icons
                                                              .star_rate_rounded,
                                                          color: Color.fromARGB(
                                                            255,
                                                            242,
                                                            151,
                                                            160,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                } else {
                                                  // 빈 별
                                                  return Icon(
                                                    Icons.star_outline_rounded,
                                                    color: Color.fromARGB(
                                                      255,
                                                      242,
                                                      151,
                                                      160,
                                                    ),
                                                  );
                                                }
                                              },
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
  Future<String?> addForm(context) {
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
                            onRatingUpdate: (newRating) {
                              setModalState(() {
                                rating = newRating;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
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
                              formkey.currentState!.save();

                              // 서버로 POST 요청 보내기
                              final response = await http.post(
                                Uri.parse(
                                  "http://localhost/heunjeok-server/bookreviews/insert.php",
                                ),
                                body: {
                                  'book_id': selectedBook!['itemId'].toString(),
                                  'book_cover': selectedBook!['cover'],
                                  'book_title': selectedBook!['title'],
                                  'book_author': selectedBook!['author'],
                                  'book_publisher': selectedBook!['publisher'],
                                  'book_pubDate': selectedBook!['pubDate'],
                                  'rev_nickname': nickname!,
                                  'rev_password': password!,
                                  'rev_content': content!,
                                  'rev_rating': rating.toString(),
                                },
                              );

                              if (response.statusCode == 200) {
                                final result = json.decode(response.body);
                                if (result['result'] == 'success') {
                                  Navigator.pop(context, 'success');
                                }
                              }
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
  void passwordAlertDialog(
    Function(String) onConfirmed,
    String correctPassword,
  ) {
    final TextEditingController pwController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) {
        String enteredPassword = '';
        String? errorMessage;
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text('비밀번호를 입력해주세요.'),
          content: TextField(
            controller: pwController,
            obscureText: true,
            decoration: InputDecoration(hintText: '흔적 남길 때, 작성한 비밀번호를 입력해주세요'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (enteredPassword == correctPassword) {
                  Navigator.pop(context);
                  onConfirmed(enteredPassword);
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
  void deleteReview(String reviewId) {
    setState(() {
      reviews.removeWhere((review) => review['review_id'] == reviewId);
    });
  }
}
