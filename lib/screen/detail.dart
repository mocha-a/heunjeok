import 'package:flutter/services.dart';
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

  //비밀번호 입력값 제어용
  final TextEditingController passwordController = TextEditingController();

  //닉네임 입력값 제어용
  final TextEditingController nicknameController = TextEditingController();

  //내용 입력값 제어용
  final TextEditingController contentController = TextEditingController();

  //닉네임 포커스 감지용
  final FocusNode nicknameFocusNode = FocusNode();

  //비밀번호 포커스 감지용
  final FocusNode passwordFocusNode = FocusNode();

  //비밀번호 보이게/안보이게 제어용
  bool obscureText = true;
  //닉네임 중복 유무
  bool nicknameAvailable = true;
  String? nicknameErrorText;

  String? editingName;

  String? nickname;
  String? password;
  String? content;
  double rating = 2.5; // 기록내용 작성 시 열리는 팝업 초기 별점 값

  @override
  void initState() {
    super.initState();
    print("불러올 id: ${widget.id}");
    itemIDApi(widget.id);
    loadReviews();

    passwordFocusNode.addListener(() {
      if (!passwordFocusNode.hasFocus) {
        // 포커스를 잃었을 때 유효성 검사 실행
        formkey.currentState!.validate();
      }
    });
  }

  @override
  void dispose() {
    reviewController.dispose();
    passwordController.dispose();
    passwordFocusNode.dispose();
    nicknameController.dispose();
    nicknameFocusNode.dispose();
    super.dispose();
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
  Future<String?> addForm(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // nicknameFocusNode에 리스너 붙이기
            nicknameFocusNode.addListener(() async {
              if (!nicknameFocusNode.hasFocus) {
                final nickname = nicknameController.text.trim();
                if (nickname.isNotEmpty) {
                  final available = await checkNickname(nickname);
                  setModalState(() {
                    nicknameAvailable = available;
                    nicknameErrorText = available ? null : "이미 사용 중인 닉네임이에요.";
                  });
                }
              }
            });

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
                          focusNode: nicknameFocusNode,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "닉네임을 입력해 주세요!";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: '닉네임',
                            errorText: nicknameErrorText,
                          ),
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
                          obscureText: obscureText,
                          controller: passwordController,
                          focusNode: passwordFocusNode,
                          keyboardType: TextInputType.text,
                          // inputFormatters: [
                          //   //조건이 맞지 않으면 입력 차단
                          //   FilteringTextInputFormatter.allow(
                          //     //입력 가능한 패턴을 받아서 가능한 패턴만 허용
                          //     RegExp(r'[a-zA-Z0-9!@#\$%^&*]'), //정규식 만드는 곳
                          //   ),
                          // ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "비밀번호를 입력해 주세요!";
                            }
                            if (!validationPassword(value)) {
                              return "🔒 영문, 숫자, 특수문자가 모두 포함된 6자 이상의 비밀번호를 입력해 주세요!";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: '비밀번호',
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureText
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setModalState(() {
                                  obscureText = !obscureText;
                                });
                              },
                            ),
                          ),
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
                                  'book_id': selectedBook[0]['itemId']
                                      .toString(),
                                  'book_cover': selectedBook[0]['cover'],
                                  'book_title': selectedBook[0]['title'],
                                  'book_author': selectedBook[0]['author'],
                                  'book_publisher':
                                      selectedBook[0]['publisher'],
                                  'book_pubDate': selectedBook[0]['pubDate'],
                                  'rev_nickname': nickname!,
                                  'rev_password': password!,
                                  'rev_content': content!,
                                  'rev_rating': rating.toString(),
                                },
                              );

                              if (response.statusCode == 200) {
                                final result = json.decode(response.body);
                                if (result['result'] == 'success') {
                                  // 저장 후 입력 내용 초기화
                                  nicknameController.clear();
                                  passwordController.clear();
                                  contentController.clear();
                                  rating = 0;
                                  nicknameAvailable = false;
                                  nicknameErrorText = null;
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
                            // 취소 클릭 시 입력 내용 초기화
                            nicknameController.clear();
                            passwordController.clear();
                            contentController.clear();
                            rating = 0;
                            nicknameAvailable = false;
                            nicknameErrorText = null;
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

  // 비밀번호 유효성 검사
  bool validationPassword(String password) {
    final regex = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$%^&*])[A-Za-z\d!@#\$%^&*]{6,}$',
    ); //
    return regex.hasMatch(password); //검사
  }

  // 닉네임 중복 검사
  Future<bool> checkNickname(String nickname) async {
    final url = Uri.parse(
      'http://localhost/heunjeok-server/bookreviews/check_nickname.php',
    );

    final response = await http.post(url, body: {'rev_nickname': nickname});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // 서버 응답 => {result: available}(가능), {result: duplicate}(중복)
      if (data['result'] == 'available') {
        return true; //사용 가능
      } else if (data['result'] == 'duplicate') {
        //
        return false; //중복
      }
    }
    throw Exception('닉네임 중복 체크 실패');
  }
}
