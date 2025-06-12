import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:heunjeok/controller/book_controller.dart';
import 'package:heunjeok/widgets/search_book.dart';
import 'package:heunjeok/widgets/search_write.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<Search>
    with SingleTickerProviderStateMixin {
  final BookController bookController = Get.put(BookController());
  final TextEditingController _controller = TextEditingController();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    recentSearchBox = Hive.box<String>('recentSearchBox');
    // Hive에 저장된 최근검색어 불러오기
    recentSearch = recentSearchBox.values.toList();
  }

  void addSearchQuery(String query) {
    if (!recentSearch.contains(query)) {
      setState(() {
        recentSearch.add(query);
      });
      // Hive에 저장 (중복 방지 위해 추가 전에 확인했으니 그냥 추가)
      recentSearchBox.add(query);
    }
  }

  @override
  void dispose() {
    //위젯 종료 시 자원 정리용 함수
    _tabController.dispose();
    super.dispose();
  }

  List<String> recentSearch = []; //최근검색어

  late Box<String> recentSearchBox;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0, backgroundColor: Colors.white),
      body: Column(
        children: [
          // 검색창
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: TextField(
              controller: _controller,
              cursorColor: Colors.white,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 25),
                filled: true,
                fillColor: const Color.fromRGBO(182, 187, 121, 1),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(
                    color: const Color.fromRGBO(182, 187, 121, 1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(
                    color: const Color.fromRGBO(182, 187, 121, 1),
                  ),
                ),
                hintText: '기록할 도서를 검색해주세요.',
                hintStyle: TextStyle(color: Colors.white),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 25),
                  child: IconButton(
                    icon: SvgPicture.asset('search_white.svg'),
                    onPressed: () => bookController.searchInput(_controller),
                  ),
                ),
              ),
              style: TextStyle(color: Colors.white),
              onSubmitted: (_) => bookController.searchInput(
                _controller,
              ), // 키보드 검색 버튼 눌렀을 때도 실행
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('최근 검색어'),
                  SizedBox(height: 8), // 텍스트 아래 여백
                  Wrap(
                    alignment: WrapAlignment.start, // ← 정렬 왼쪽으로
                    spacing: 6, // 요소들 가로 여백
                    runSpacing: 6, // 줄 간 여백
                    children: recentSearch.map((item) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          _controller.text = item; // 검색창에 검색어 넣고
                          bookController.searchInput(
                            _controller,
                          ); // 검색 함수 호출해서 결과 보여주고
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ), // 내부 여백
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color.fromRGBO(232, 192, 252, 1),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(item, overflow: TextOverflow.ellipsis),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // 2. 탭바
          TabBar(
            controller: _tabController,
            labelColor: const Color.fromRGBO(51, 51, 51, 1),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color.fromRGBO(182, 187, 121, 1),
            tabs: const [
              Tab(
                child: Text(
                  '도서',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              Tab(
                child: Text(
                  '기록',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          // 3. 탭뷰 - 남은 공간 다 차지하게 Expanded로 감싸기
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [SearchBook(), SearchWrite()],
            ),
          ),
        ],
      ),
    );
  }
}
