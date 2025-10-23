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

<br>

## 🛠 기술 스택

### 📲 **Frontend Framework**
| 항목 | 기술 | 버전 |
|------|------|------|
| Framework | Flutter | 3.0+ |
| Language | Dart | 2.17+ |
| 상태관리 | Provider / GetX | - |
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
  flutter_naver_map: ^1.0.0+  # 네이버 지도
  http: ^1.1.0+               # HTTP 통신
  geolocator: ^9.0.0+         # GPS 위치 서비스
  permission_handler: ^11.0.0+ # 권한 관리
  url_launcher: ^6.1.0+       # 외부 앱 실행
  shared_preferences: ^2.1.0+ # 로컬 저장소
```

<br>

## 📸 스크린샷

```
[메인 화면]              [주차장 목록]           [지도 화면]
내 위치 기반            거리별 정렬              네이버 지도 연동
실시간 위치 업데이트     실시간 정보 표시         길찾기 기능
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
- `lib/config/api_keys.dart` 파일에 입력

```dart
// lib/config/api_keys.dart
class ApiKeys {
  static const String naverMapClientId = 'YOUR_NAVER_MAP_CLIENT_ID';
  static const String jejuItsApiKey = 'YOUR_JEJU_ITS_API_KEY';
}
```

#### 4️⃣ **앱 실행**
```bash
flutter run
```

<br>

## 🏗️ 프로젝트 구조

```
lib/
├── config/
│   ├── api_keys.dart           # API 키 설정
│   └── app_constants.dart      # 앱 상수 정의
├── models/
│   ├── parking_lot.dart        # 주차장 데이터 모델
│   ├── parking_info.dart       # 주차 정보 모델
│   └── user_location.dart      # 사용자 위치 모델
├── services/
│   ├── jeju_its_service.dart   # 제주 ITS API 연동
│   ├── location_service.dart   # GPS 위치 서비스
│   ├── map_service.dart        # 네이버 지도 서비스
│   └── parking_service.dart    # 주차장 정보 조회
├── providers/
│   ├── location_provider.dart  # 위치 상태 관리
│   ├── parking_provider.dart   # 주차장 상태 관리
│   └── ui_provider.dart        # UI 상태 관리
├── screens/
│   ├── home_screen.dart        # 메인 화면 (지도)
│   ├── parking_list_screen.dart # 주차장 목록 화면
│   ├── parking_detail_screen.dart # 주차장 상세 화면
│   └── settings_screen.dart    # 설정 화면
├── widgets/
│   ├── parking_card.dart       # 주차장 카드 위젯
│   ├── location_button.dart    # 위치 업데이트 버튼
│   └── custom_app_bar.dart     # 커스텀 앱바
├── utils/
│   ├── distance_calculator.dart # 거리 계산 유틸
│   ├── permission_helper.dart  # 권한 관리 헬퍼
│   └── logger.dart             # 로깅 유틸
└── main.dart                   # 앱 진입점
```

<br>

## 🔌 API 명세

### 제주 교통정보센터 Open API

**Base URL:** `http://api.jejuits.go.kr/api/`

**주차장 기본 정보 조회**
```
GET /infoParkingList?code={API_KEY}

Response:
{
  "parkingLot": [
    {
      "id": "주차장ID",
      "name": "주차장명",
      "location": "위치정보",
      "totalCapacity": 150,
      "latitude": 33.4996,
      "longitude": 126.5312
    }
  ]
}
```

**주차장 실시간 현황**
```
GET /infoParkingCnt?code={API_KEY}

Response:
{
  "parkingInfo": [
    {
      "id": "주차장ID",
      "name": "주차장명",
      "totalCapacity": 150,
      "availableSpaces": 45,
      "occupancyRate": 70,
      "lastUpdated": "2024-10-15 14:30:00"
    }
  ]
}
```

<br>

## 📦 배포 현황

### 🤖 Android
- **상태:** Google Play Store 비공개 테스트 진행 중
- **테스터 모집:** 제주도 주민 및 방문객 대상
- **정식 출시 예정일:** 2025년 10월 중순

### 🍎 iOS
- **상태:** 준비 중
- **예정일:** 2025년 11월 중

<br>

## 🎯 주요 개발 경험 및 배운 점

### 💡 **기술적 성과**
- **공공 데이터 API 연동:** 제주 교통정보센터 Open API를 활용한 실시간 데이터 처리
- **GPS 기반 서비스:** Geolocator를 이용한 현재 위치 추적 및 근처 주차장 자동 검색
- **지도 API 통합:** 네이버 지도 API 및 다중 네비게이션 앱 연동
- **권한 관리:** iOS/Android 플랫폼별 권한 요청 처리

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
![Version](https://img.shields.io/badge/Version-1.0.0-brightgreen?style=flat)
![Status](https://img.shields.io/badge/Status-Beta%20Testing-yellow?style=flat)

</div>
