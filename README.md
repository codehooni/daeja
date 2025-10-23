# 대자 (Daeja) 🅿️

> 제주도 실시간 주차장 정보 제공 모바일 앱

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)
![Naver Map](https://img.shields.io/badge/Naver%20Map%20API-00C73C?style=flat&logo=naver&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

<br>

## 📱 프로젝트 개요

**대자(Daeja)** 는 제주도 내 주차장의 실시간 주차 가능 여부를 한눈에 확인할 수 있는 Flutter 기반 모바일 애플리케이션입니다.

제주 교통정보센터의 공공 API를 활용하여 **정확한 실시간 주차 현황**을 제공하며, 네이버 지도를 통해 **직관적인 위치 기반 서비스**를 구현했습니다. GPS를 활용해 이동 중에도 근처 주차장을 실시간으로 검색할 수 있어, 제주도 방문객과 주민 모두에게 편리한 주차 경험을 제공합니다.

<br>

## ✨ 핵심 기능

### 🎯 **위치 기반 주차장 검색**
- GPS를 활용한 현재 위치 기반 근처 주차장 자동 탐색
- 실시간 위치 업데이트로 이동 중에도 편리한 검색
- 주차장까지의 거리 계산 및 정렬 기능

### 📊 **실시간 주차 현황 확인**
- 제주 교통정보센터 API를 통한 실시간 주차 가능 대수 표시
- 주차장별 총 주차 면수 및 현재 주차 가능 면수 비교
- 주차 가능 여부를 **직관적인 색상 UI**로 한눈에 파악

### 🗺️ **네이버 지도 길찾기**
- 선택한 주차장까지 네이버, 카카오, TMAP, 애플, 구글 지도 연동
- 최적 경로 안내 및 실시간 내비게이션 지원
- 앱 내 지도에서 즉시 길찾기 가능

### 📤 **주차장 정보 공유**
- 주차장 상세 정보를 텍스트로 공유
- Google Maps 링크 포함
- 요금 및 운영 시간 정보 포함


<br>

## 🛠 기술 스택

### 📲 **Frontend Framework**
| 항목 | 기술 | 버전 |
|------|------|------|
| Framework | Flutter | 3.0+ |
| Language | Dart | 2.17+ |
| 상태관리 | Provider / BLoC(Cubit) | - |
| 로컬 저장소 | SharedPreferences | - |

### 🌐 **External APIs & Services**
| 서비스 | 목적 | 비고 |
|--------|------|------|
| Naver Map API | 지도 표시 및 길찾기 | 클라이언트 ID 필요 |
| Jeju ITS Open API | 실시간 주차 정보 | 공공데이터 포털 |
| GPS / Geolocator | 현재 위치 조회 | Native 권한 필요 |
| URL Launcher | 네이버 지도 앱 연동 | 다중 지도 앱 지원 |

### 📦 **주요 패키지**
```yaml
dependencies:
  flutter_naver_map: ^1.4.1+       # 네이버 지도
  http: ^1.2.2                     # HTTP 통신
  geolocator: ^14.0.2              # GPS 위치 서비스
  url_launcher: ^6.3.1             # 외부 앱 실행
  provider: ^6.1.5+                # 상태 관리
  flutter_bloc: ^9.1.1             # BLoC/Cubit 상태 관리
  map_launcher: ^4.4.2             # 다중 지도 앱 지원
  flutter_svg: ^2.0.16             # SVG 렌더링
  share_plus: ^12.0.0              # 공유 기능
  flutter_dotenv: ^6.0.0           # 환경 변수 관리
```

<br>

## 📸 스크린샷

```
  | 지도 화면 | 주차장 목록 | 상세 정보 | 길찾기 |
  |:---:|:---:|:---:|:---:|
  | <img width="1290" height="2796" alt="Simulator Screenshot - iPhone 16 Plus - 2025-10-23 at 23 59 03" src="https://github.com/user-attachments/assets/d287688f-a961-4780-ab7c-ab9392e28af2" />
 | <img width="1290" height="2796" alt="Simulator Screenshot - iPhone 16 Plus - 2025-10-23 at 23 59 07" src="https://github.com/user-attachments/assets/8b8df077-49ea-4ed8-b795-29e488ca51cd" />
 |
  <img width="1290" height="2796" alt="Simulator Screenshot - iPhone 16 Plus - 2025-10-23 at 23 59 11" src="https://github.com/user-attachments/assets/b3dd58e6-d97d-4cd5-8bca-cc2a0594a761" />
 | <img width="1290" height="2796" alt="Simulator Screenshot - iPhone 16 Plus - 2025-10-24 at 00 00 49" src="https://github.com/user-attachments/assets/d76c517a-2be5-4d87-ab3a-23652e5c6a76" />
 |
  | 실시간 위치 기반 지도 | 거리순 정렬 목록 | 주차 현황 및 요금 |
   다중 지도 앱 지원 |

```

> 💡 **스크린샷 추가 방법:**
> 1. 앱 실행 후 주요 화면 3-4장 캡처
> 2. `screenshots/` 폴더에 저장
> 3. 위 자리에 이미지 경로 추가

<br>

## 🚀 시작하기

### 📋 사전 요구사항

```
- Flutter SDK 3.0 이상
- Dart SDK 2.17 이상
- Android Studio 또는 Xcode
- 네이버 클라우드 플랫폼 계정
- 제주 교통정보센터 Open API 가입
```

### ⚙️ 설치 방법

#### 1️⃣ **저장소 클론**
```bash
git clone https://github.com/codehooni/daeja.git
cd daeja
```

#### 2️⃣ **패키지 설치**
```bash
flutter pub get
```

#### 3️⃣ **API 키 설정**

**네이버 지도 API 키 발급:**
- [네이버 클라우드 플랫폼](https://console.ncloud.com) 접속
- Maps API 신청 후 Client ID 발급
- `lib/config/api_keys.dart` 파일에 입력

**제주 교통정보센터 Open API 키 발급:**
- [제주 교통정보센터](https://www.jejuits.go.kr/open_api/open_apiView.do) 접속
- Open API 신청
- 프로젝트 루트에 `.env` 파일 생성:

```bash
# .env
NAVER_MAP_CLIENT_ID=your_naver_map_client_id
JEJU_API_CODE=your_jeju_api_code
DEVELOPER_EMAIL=your_email@example.com
```

#### 4️⃣ **앱 실행**
```bash
flutter run
```

<br>

## 🏗️ 프로젝트 구조

  lib/
  ├── constants/
  │   └── constants.dart              # 앱 전역 상수 (패딩, 테마 등)
  ├── features/
  │   ├── parking_lot/
  │   │   ├── cubit/
  │   │   │   ├── parking_lot_cubit.dart   # 주차장 상태 관리 (Cubit)
  │   │   │   └── parking_lot_state.dart   # 주차장 상태 정의
  │   │   ├── data/
  │   │   │   ├── model/
  │   │   │   │   └── parking_lot.dart     # 주차장 데이터 모델
  │   │   │   ├── provider/
  │   │   │   │   └── parking_lot_provider.dart # 제주 ITS API 데이터 제공
  │   │   │   ├── repository/
  │   │   │   │   └── parking_lot_repository.dart # 주차장 데이터 저장소
  │   │   │   └── static_parking_lots.dart # 정적 주차장 데이터
  │   └── user_location/
  │       └── provider/
  │           └── user_location_provider.dart # 사용자 위치 상태 관리
  ├── presentation/
  │   ├── dialogs/
  │   │   └── dialogs.dart            # 공통 다이얼로그/스낵바
  │   ├── helper/
  │   │   └── parking_marker_helper.dart # 지도 마커 생성 헬퍼
  │   ├── screen/
  │   │   ├── home_screen.dart        # 홈 화면 (지도)
  │   │   ├── main_screen.dart        # 메인 화면 (네비게이션)
  │   │   └── settings_screen.dart    # 설정 화면
  │   ├── theme/
  │   │   ├── dark_mode.dart          # 다크 모드 테마
  │   │   ├── light_mode.dart         # 라이트 모드 테마
  │   │   └── theme_provider.dart     # 테마 상태 관리
  │   └── widget/
  │       ├── map/
  │       │   ├── compass_button.dart      # 나침반 버튼
  │       │   ├── map_control_buttons.dart # 지도 제어 버튼 모음
  │       │   ├── my_location_button.dart  # 내 위치 버튼
  │       │   ├── refresh_button.dart      # 새로고침 버튼
  │       │   └── zoom_buttons.dart        # 줌 버튼
  │       ├── sheet/
  │       │   ├── navigation_selection_sheet.dart # 길찾기 앱 선택
  │       │   ├── parking_detail_sheet.dart # 주차장 상세 정보
  │       │   ├── parking_list_sheet.dart   # 주차장 목록
  │       │   └── sheet_handle_bar.dart     # 바텀시트 핸들바
  │       ├── my_bottom_navigation_item.dart # 하단 네비게이션 아이템
  │       ├── my_floating_action_button.dart # 커스텀 FAB
  │       └── my_setting_container.dart      # 설정 컨테이너
  ├── utils/
  │   ├── email_utils.dart            # 이메일 관련 유틸
  │   └── share_parking_lot.dart      # 주차장 정보 공유
  ├── models/
  │   └── parking_lot.dart            # (레거시) 주차장 모델
  ├── my_observer.dart                # Bloc 옵저버
  └── main.dart                       # 앱 진입점

```

<br>

## 🔌 API 명세

### 제주 교통정보센터 Open API

**Base URL:** `http://api.jejuits.go.kr/api/`

**주차장 기본 정보 조회**
```
GET /infoParkingInfoList?code={API_KEY}

RESPONSE

{
   "result" : "success",
   "info_cnt" : 2,
   "Info": [{ :
      "id" : "16488201",
      "name" : "법원북측공영주차장",
      "addr" : "법원북측",
      "x_crdn" : 126.53534209,
      "y_crdn" : 33.49472463,
      "park_day" : "월화수목금토일",
      "wkdy_strt" : "090000",
      "wkdy_end" : "180000",
      "lhdy_strt" : "090000",
      "lhdy_end" : "180000",
      "basic_time" : 30,
      "basic_fare" : 1000,
      "add_time" : 15,
      "add_farc" : 500,
      "whol_npls" : 91
   }]
}
```

**주차장 실시간 현황**
```
GET /infoParkingStateList?code={API_KEY}

RESPONSE

{
   "result" : "success",
   "info_cnt" : 2,
   "Info": [{ :
      "id" : "16488201",
      "gnrl" : 10,
      "lgvh" : 7,
      "hvvh" : 0,
      "emvh" : 0,
      "hndc" : 2,
      "wmon" : 0,
      "etc" : 0
   }]
}
```

<br>

## 📦 배포 현황

### 🤖 Android
- **상태:** Google Play Store 비공개 테스트 진행 중
- **테스터 모집:** 제주도 주민 및 방문객 대상
- **정식 출시 예정일:** 2025년 11월 중
- **빌드 버전:** 1.1.0+15

### 🍎 iOS
- **상태:** 출시
- **출시일:** 2025년 10월 17일
- **빌드 버전:** 1.1.0+15

<br>

## 🎯 주요 개발 경험 및 배운 점

### 💡 **기술적 성과**
- **공공 데이터 API 연동:** 제주 교통정보센터 Open API를 활용한 실시간 데이터 처리
- **GPS 기반 서비스:** Geolocator를 이용한 현재 위치 추적 및 근처 주차장 자동 검색
- **지도 API 통합:** 네이버 지도 API 및 다중 네비게이션 앱 연동
- **권한 관리:** iOS/Android 플랫폼별 권한 요청 처리
- **환경 변수 관리:** flutter_dotenv를 활용한 안전한 API 키 관리
- **다중 지도 앱 지원:** 네이버, 카카오, 구글, 애플 지도 등 사용자 선택 가능
- **정보 공유 기능:** share_plus를 활용한 주차장 정보 공유

### 🚀 **개발 프로세스**
- **UI/UX:** 직관적인 주차 현황 표시를 위한 색상 코딩 시스템 개발
- **성능 최적화:** 대량의 주차장 데이터 처리 및 위치 업데이트 최적화
- **에러 처리:** 네트워크 오류, 권한 거부 등 다양한 예외 상황 대응

<br>

## 🤝 기여하기

버그 리포트나 기능 제안은 [Issues](https://github.com/codehooni/daeja/issues)에 남겨주세요!

**Pull Request 작성 가이드:**
1. Fork 후 기능 브랜치 생성 (`git checkout -b feature/AmazingFeature`)
2. 변경사항 커밋 (`git commit -m 'Add some AmazingFeature'`)
3. 브랜치 푸시 (`git push origin feature/AmazingFeature`)
4. Pull Request 작성

<br>

## 📄 라이선스

이 프로젝트는 **MIT 라이선스** 하에 있습니다.
자유롭게 사용, 수정, 배포할 수 있습니다.

<br>

## 👨‍💻 개발자

**이지훈 (Lee Ji-Hoon)**
- 📧 **Email:** jihooni0113@gmail.com
- 🔗 **GitHub:** [@codehooni](https://github.com/codehooni)
- 📱 **Phone:** 010-2624-8748

<br>

## 🙏 감사의 말

- 🏢 제주특별자치도 교통정보센터의 **Open API 제공**에 감사드립니다
- 🗺️ 네이버 지도 API를 활용할 수 있게 해주신 **네이버**에 감사드립니다
- 💙 피드백을 주신 **테스트 사용자**들께 감사드립니다

<br>

---

<div align="center">

**Made with ❤️ in Jeju, South Korea**

![Jeju](https://img.shields.io/badge/Location-Jeju%20Island-FF6B6B?style=flat)
![Version](https://img.shields.io/badge/Version-1.1.0-brightgreen?style=flat)
![Status](https://img.shields.io/badge/Status-Beta%20Testing-yellow?style=flat)

</div>
