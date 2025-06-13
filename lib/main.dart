import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:heunjeok/controller/book_controller.dart';
import 'package:heunjeok/screen/book.dart';
import 'package:heunjeok/screen/home.dart';
import 'package:heunjeok/screen/search.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //flutter에서 모든 비동기 작업이면 해당 문장을 넣어줘야 함
  await Hive.initFlutter(); //hive 초기화
  await Hive.openBox('scheduleBox'); //문서 생성
  await Hive.openBox<String>('recentSearchBox');

  Get.put(BookController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '흔적',
      theme: ThemeData(
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Color.fromRGBO(51, 51, 51, 1)),
        ),
        fontFamily: 'SUITE',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.transparent),
        appBarTheme: AppBarTheme(backgroundColor: Colors.transparent),
        scaffoldBackgroundColor: Colors.white,
      ),

      // home: const MyHomePage(title: '흔적'),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // 2초 후에 MyHomePage로 이동
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MyHomePage(title: '흔적')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Image.asset('splash.png')));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int seletedIndex = 0;
  double padding = 18.0;
  late List<Widget> pageList;

  void changeIndex(int idx) {
    setState(() {
      seletedIndex = idx;
    });
  }

  void changePadding(double idx) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        padding = idx;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    // 여기서 인스턴스 메서드 참조 가능하니까 초기화
    pageList = [
      Home(changePadding: changePadding),
      Book(changePadding: changePadding),
      Search(changePadding: changePadding),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset('logo.svg'),
            SizedBox(width: 6),
            Text(
              '흔적',
              style: TextStyle(
                fontSize: 31,
                color: Color.fromRGBO(182, 187, 121, 1),
                fontFamily: 'Ownglyph',
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: pageList[seletedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: seletedIndex,
        selectedItemColor: Color.fromRGBO(182, 187, 121, 1),
        unselectedItemColor: Color.fromRGBO(153, 153, 153, 1),
        onTap: changeIndex, //굳이 인자값을 안보내줘도 알아서 idx값을 보내줌 왜? 몰라?..
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/home_grey.svg',
              color: seletedIndex == 0
                  ? Color.fromRGBO(182, 187, 121, 1)
                  : Color.fromRGBO(153, 153, 153, 1),
            ),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/book_grey.svg',
              color: seletedIndex == 1
                  ? Color.fromRGBO(182, 187, 121, 1)
                  : Color.fromRGBO(153, 153, 153, 1),
            ),
            label: '기록',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/search_grey.svg',
              color: seletedIndex == 2
                  ? Color.fromRGBO(182, 187, 121, 1)
                  : Color.fromRGBO(153, 153, 153, 1),
            ),
            label: '검색',
          ),
        ],
      ),
    );
  }
}
