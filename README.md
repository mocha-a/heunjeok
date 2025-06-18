![Image](https://github.com/user-attachments/assets/a2262025-5003-4b62-8517-0f0afa0f34ad)

## 📜🖋 요약

#### 1. **주제**

- 독서 후 기록을 남기고 싶은 사용자들을 위한 독서 기록 플랫폼 제공
- 책에 대한 생각과 느낌을 자유롭게 작성하고, 작성한 기록을 모아볼 수 있는 공간 제공

#### 2. **목표**

- 중, 고등학생부터 20-30대까지, 기록을 남기고 싶은 사용자들을 위해 쉽게 이용 가능하도록 설계
- 리뷰마다 비밀번호 기능을 넣어, 글을 안전하게 수정 및 삭제 기능

#### 3. **개발 환경**

- Front-End : Flutter, Dart, GetX, HTTP
- Back-End : PHP, MySQL, xampp

#### 4. **기간 및 인원**

- 2025-06-10 ~ 2025-06-11 : 기획 및 디자인
- 2025-06-11 ~ 2025-06-16 : 개발
- 2025-06-16 : 테스트 및 배포

총 7일, 2인


## 🔗 배포 URL

- https://heunjeok.vercel.app/

## 💁‍♀️ 저희가 만들었어요 !

| 이름 | 깃허브 | 주요 위젯 | 해당 |
| :---:| :---: | :---: | :---: |
| 소연희 | [yeonhee001](https://github.com/yeonhee001) |  book.dart, detail.dart|  |
| 안지현 | [mocha-a](https://github.com/mocha-a) | home.dart, search.dart | ✔️ |


## 📌 주요 기능

- 비회원 사용 ➡ 로그인 없이 앱 전체 기능 이용 가능
- 비밀번호 기반 기록 관리 ➡ 리뷰 작성 시 비밀번호 설정 → 이후 수정/삭제 시 인증용으로 사용
- 비밀번호 유효성 검사
- 추천도서 · 베스트셀러를 슬라이드 형식의 UI로 직각적으로 제공
- 책에 대한 감상(리뷰) 저장 및 관리 기능
- 책, 기록 리스트 및 상세 내용 검색 기능
- 별점 평가 기능 ➡ 도서에 대해 1~5점 별점으로 평가 가능


## 💼 프로젝트 폴더 구조

```
📦heunjeok                     # heunjeok ( Front-End )
 ┣ 📂assets
 ┃ ┗ 📂fonts
 ┣ 📂build                     # Flutter가 빌드한 결과물
 ┃ ┣ 📂web
 ┃ ┃ ┗ 📜index.html
 ┣ 📂lib
 ┃ ┣ 📂controller              # 컴포넌트 폴더
 ┃ ┃ ┣ 📜book_api.dart         # 알라딘 API 함수 정의
 ┃ ┃ ┗ 📜book_controller.dart  # GetX 컨트롤러 (ViewModel)
 ┃ ┣ 📂screen                  # 화면 단위 위젯 (각 페이지별 UI 구성)
 ┃ ┃ ┗ 📜book.dart
 ┃ ┃ ┗ 📜detail.dart
 ┃ ┃ ┗ 📜home.dart
 ┃ ┃ ┗ 📜search.dart
 ┃ ┣ 📂utils                   
 ┃ ┃ ┗ 📜scroll_listener.dart  # 스크롤 이벤트 감지 기능 클래스
 ┃ ┣ 📂widgets
 ┃ ┗ 📜main.dart               # 앱 실행 진입점, 전체 라우팅 및 초기 설정
 ┣ 🔗.env                      # 환경변수
 ┗ 📜README.md
 
 📦heunjeok-server             # heunjeok ( Back-End )
 ┣ 📂bookreviews               # 리뷰 관련 API API Endpoint 모음 (프론트에서 호출하는 PHP API 파일들)
 ┃ ┣ 🐘all_get.php             # 전체 리뷰+도서 목록 조회 API
 ┃ ┣ 🐘check_nickname.php      # 닉네임 중복 확인 API
 ┃ ┣ 🐘delete.php              # 리뷰 삭제 API
 ┃ ┣ 🐘insert.php              # 리뷰 등록 API
 ┃ ┣ 🐘password_check.php      # 리뷰 비밀번호 확인 API
 ┃ ┣ 🐘review_get.php          # 도서 리뷰 목록 조회 API
 ┃ ┗ 🐘update.php              # 리뷰 수정 API
 ┣ 🐘bestseller.php            # 베스트셀러 도서 리스트 조회 API
 ┣ 🐘recommend.php             # 추천 도서 리스트 조회 API
 ┣ 🐘item_id.php               # 도서 ID 기반 상세 조회 API
 ┣ 🐘serach_book.php           # 도서 제목 기반 검색 API
 ┣ 🐘serach_write.php          # 리뷰 작성자 기준 리뷰 검색
 ┣ 🐘config.php                # DB 연결 설정
 ┗ 🐘table.php                 # DB 테이블 생성
```

## 🛠️ 사용 기술

### 1. Frond-End

| 사용기술 | 설명 |Badge |
| :---:| :---: | :---: |
| **Flutter** | **크로스 플랫폼 앱 개발 프레임워크** |![flutter](https://img.shields.io/badge/flutter-02569B?style=flat-square&logo=flutter&logoColor=white)|
| **Dart** | **Flutter 전용 프로그래밍 언어** |![dart](https://img.shields.io/badge/dart-0175C2?style=flat-square&logo=dart&logoColor=white)|
| **GetX** | **상태 관리** |![getx](https://img.shields.io/badge/getx-8A2BE2?style=flat-square&logo=getx&logoColor=white)|
| **HTTP** | **REST API 통신용 라이브러리**|![HTTP](https://img.shields.io/badge/HTTP-ffffff?style=flat-square&logoColor=white)|

### 2. Back-End

| 사용기술 | 설명 | Badge |
| :---:| :---: | :---: |
| **PHP** | **백엔드 언어** |![php](https://img.shields.io/badge/php-777BB4?style=flat-square&logo=php&logoColor=white)|
| **MySQL** | **데이터베이스** |![mysql](https://img.shields.io/badge/mysql-4479A1?style=flat-square&logo=mysql&logoColor=white)|
| **xampp** | **로컬에서 Apache, MySQL, PHP<br>서버를 한번에 실행** |![xampp](https://img.shields.io/badge/xampp-FB7A24?style=flat-square&logo=xampp&logoColor=white)|

### 3. 개발 도구

|사용기술 | 설명 | Badge | 
|:---:| :---: |:---: |
| **Visual Studio Code<br>(VS Code)** | **코드 편집기( 에디터 )** |![VSCode](https://img.shields.io/badge/VSCode-007ACC?style=flat-square&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzIiIGhlaWdodD0iMzIiIHZpZXdCb3g9IjAgMCAzMiAzMiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTI0LjAwMyAyTDEyIDEzLjMwM0w0Ljg0IDhMMiAxMEw4Ljc3MiAxNkwyIDIyTDQuODQgMjRMMTIgMTguNzAyTDI0LjAwMyAzMEwzMCAyNy4wODdWNC45MTNMMjQuMDAzIDJaTTI0IDkuNDM0VjIyLjU2NkwxNS4yODkgMTZMMjQgOS40MzRaIiBmaWxsPSJ3aGl0ZSIvPgo8L3N2Zz4K&logoColor=white) |
|**GitHub** | **버전 관리** |![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat-square&logo=GitHub&logoColor=white)| 
|**Slack** | **협업 도구 (커뮤니케이션)** |![Slack](https://img.shields.io/badge/Slack-4A154B?style=flat-square&logo=slack&logoColor=white)| 
|**Notion** | **협업 도구 (문서 & 관리)** |![notion](https://img.shields.io/badge/Notion-000000?style=flat-square&logo=notion&logoColor=white)| 
| **Vercel** | **서버리스 플랫폼** |![Vercel](https://img.shields.io/badge/Vercel-000000?style=flat-square&logo=vercel&logoColor=white)|
| **dothome** | **무료 웹호스팅으로 PHP 서버 배포<br>([heunjeok.dothome.co.kr](http://heunjeok.dothome.co.kr/heunjeok-server/bestseller.php))** |![dothome](https://img.shields.io/badge/dothome-22AEE4?style=flat-square&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABoAAAAYCAYAAADkgu3FAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAEnQAABJ0Ad5mH3gAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAADqGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4NCjx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4NCgk8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPg0KCQk8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdFJlZj0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlUmVmIyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ1M2IChXaW5kb3dzKSIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDozNEIyQjQzMjQ5QTMxMUU3OTUyNjg4QjQyMjBFN0JGNSIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDozNEIyQjQzMzQ5QTMxMUU3OTUyNjg4QjQyMjBFN0JGNSI+DQoJCQk8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDozNEIyQjQzMDQ5QTMxMUU3OTUyNjg4QjQyMjBFN0JGNSIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDozNEIyQjQzMTQ5QTMxMUU3OTUyNjg4QjQyMjBFN0JGNSIvPg0KCQk8L3JkZjpEZXNjcmlwdGlvbj4NCgkJPHJkZjpEZXNjcmlwdGlvbiB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyI+PHRpZmY6T3JpZW50YXRpb24+MTwvdGlmZjpPcmllbnRhdGlvbj48L3JkZjpEZXNjcmlwdGlvbj48L3JkZjpSREY+DQo8L3g6eG1wbWV0YT4NCjw/eHBhY2tldCBlbmQ9J3cnPz7Bo9ixAAACbklEQVRIS52VTaiNURSG3/VdrvzmXib+iyKUEorBRWTMADMDMz9JMlGGkoEkA1EGlJFCiTLASClkJKQYSMlP/kou4nkNzvcd+6zuuTf3ma13vWuts8/e+9vSCAAzgF3ANeAF8An4BpzM3lEBzASOA288BMCV5F9me2qpjQiwHfiQm5cAl8sa2xeA58CSUm+osmD7UERciojpOTcctn9ExEJJd22vz/mOQcBeScdK7X+JiH7bV4Hlpd4eBKySdLxMjpaI6IuIc8D4RitXdCQi2okS279sX7e93/Zm2+cl9WZfYoWkPR0KsDZvdgPwuF5t6d8K3Eja2SFqXwJTVKxoW1nUYPtJRGyqquphqUdElHE3ImK+pI2SVNnukbQ6m2oORMTbJrA9xvYE272S3GntylrVg2ZImpOztu9XVXWriYF5km7bfivpjKSfnRVdWar6r5smaULOSnqQ4qOS1kXE5IiYnHLD0ad8jxJfUjw3xT0pHpZK0kdJ33NC0oIUX0/xsxR3G/xZau1FBTwY4mi+tt3XuGvfTuAisK8+EE2uB3iUe7jV599XHjiVDW6ZDrdNwwDszLUFW0rjQM66Neg3sKOjawLYAHzNtU4Xtiy4mY1umf8Ap4GOPQNmA0eBwVzTABxs/O0bDqyUdC8ixra7FdgerA/A+/pKLI6ISdlX8Mj2QFVVgx0qMMv2l/yrRkP93Hc8E22AE7lgNAAfh3r4pNaQXfXGfwZeAe+AX7nJSAAPuz3lst0LrAEWAf3ARGAKsBQ4AbzPDTPAM2A3MC73bxjxc297uu2Nkgbqr0W/pN/1oXgq6U5E3IuIH7m25C/8PXPCVobe0AAAAABJRU5ErkJggg==&logoColor=white)|
| **Figma** | **디자인 & UI/UX**|![Figma](https://img.shields.io/badge/Figma-F24E1E?style=flat-square&logo=Figma&logoColor=white) |

## 🧂전체 소스 코드

이 저장소에는 Flutter 웹 빌드 결과물만 포함되어 있습니다.<br>
프로젝트 전체 소스를 보시려면 아래 링크를 클릭해 주세요 !

- [Flutter 전체 소스](https://github.com/mocha-a/heunjeok)
- [PHP 소스](https://github.com/mocha-a/heunjeok-server.git)

## 📚 참고 URL

- 기획서 : heunjeok Google Docs
- 화면 설계 : heunjeok Figma
- ppt : heunjeok Canva

## 🌠 트러블슈팅 (Troubleshooting)

> 개발 중 이슈와 해결 방안
> 
### ✅detail.dart

 - 기록 내용 수정 삭제 시, 비밀번호가 일치하는데 불일치하다는 메시지가 뜨는 이슈 발생
비밀번호 입력 후 수정 시, 해당 기록 데이터에 값이 변경되는게 아니라 새로 추가되는 이슈 발생

    ⇒ **해결방법**: 서버 요청 시, 필요한 칼럼의 값을 누락 없이 포함하도록 수정하여 기능이 정상 작동 되도록 개선


### ✅insert.php

- 프론트의 검색-기록 탭에서 실제로는 리뷰가 1개 밖에 없는데, 검색 결과가 비정상적으로 많이 나오는 이슈 발생


    ⇒ **원인**: reviews 테이블과 book 테이블을 book_id 기준으로 JOIN하는데, book 테이블에 중복된 book_id가 있어서 하나의 리뷰가 중복된 책 행 수만큼 곱해져서 출력<br>
    ⇒ **해결방법**: book 테이블에서 중복된 book_id 데이터를 삭제하고, book_id가 유일하게 유지되도록 데이터 정리

## 💭 느낀점

flutter를 활용해서 만든 프로젝트지만, 이전에 사용했던 React와 개념적으로 비슷한 부분들이 있어 비교적 빠르게 적응할 수 있었습니다.<br>
상태관리나 컴포넌트 구조도 비슷해서 기능 구현에 집중할 수 있었고, <br>
기본으로 제공되는 위젯들을 사용하며 편리함을 느꼈습니다. <br>
CRUD를 기반으로 한 커뮤니티 앱을 만들면서 서버와의 연동 경험도 다시 한 번 쌓을 수 있었습니다.
