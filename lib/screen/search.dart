import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  }

  @override
  void dispose() {
    //위젯 종료 시 자원 정리용 함수
    _tabController.dispose();
    super.dispose();
  }

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
