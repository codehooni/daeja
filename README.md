# 대자 (Daeja) 🅿️

> 제주도 실시간 주차장 정보 제공 모바일 앱

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)
![Naver Map](https://img.shields.io/badge/Naver%20Map%20API-00C73C?style=flat&logo=naver&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-02569B?style=flat&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat&logo=firebase&logoColor=black)
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

### 🗺️ **다중 네비게이션 앱 연동**
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
| Framework | Flutter | 3.8+ |
| Language | Dart | 3.8+ |
| 상태관리 | Riverpod | 3.0.3+ |
| 로컬 저장소 | Hive | 2.2.3+ |
| 백엔드 | Firebase Firestore | 6.1.0+ |
| 인증 | Firebase Auth | 6.1.2+ |
| 아키텍처 | Clean Architecture | - |

### 🌐 **External APIs & Services**

| 서비스 | 목적 | 패키지 |
|--------|------|--------|
| Firebase Auth | 전화번호 인증 | firebase_auth ^6.1.2 |
| Firebase Firestore | 주차장 데이터 저장 | cloud_firestore ^6.1.0 |
| Naver Map API | 지도 표시 및 길찾기 | flutter_naver_map ^1.4.1+1 |
| Jeju ITS Open API | 실시간 주차 정보 | dio ^5.9.0 |
| Airport Open API | 공항 주차 정보 | dio ^5.9.0 |
| GPS / Geolocator | 현재 위치 조회 | geolocator ^14.0.2 |
| URL Launcher | 네이버 지도 앱 연동 | url_launcher ^6.3.1 |
| Map Launcher | 다중 지도 앱 지원 | map_launcher ^4.4.2 |

### 📦 **주요 패키지**

```yaml
dependencies:
  flutter_riverpod: ^3.0.3         # 상태 관리
  firebase_core: ^4.2.1            # Firebase 코어
  firebase_auth: ^6.1.2            # Firebase 인증
  cloud_firestore: ^6.1.0          # Firestore 데이터베이스
  hive: ^2.2.3                     # 로컬 저장소
  hive_flutter: ^1.1.0             # Hive Flutter 통합
  flutter_naver_map: ^1.4.1+1      # 네이버 지도
  dio: ^5.9.0                      # 네트워크 요청
  geolocator: ^14.0.2              # GPS 위치 서비스
  url_launcher: ^6.3.1             # 외부 앱 실행
  map_launcher: ^4.4.2             # 다중 지도 앱 지원
  flutter_svg: ^2.0.16             # SVG 렌더링
  share_plus: ^12.0.0              # 공유 기능
  flutter_dotenv: ^6.0.0           # 환경 변수 관리
  intl: ^0.20.2                    # 시간 형식
```

<br>

## 📸 스크린샷

| 지도 화면 | 주차장 목록 | 상세 정보 | 길찾기 |
|:---:|:---:|:---:|:---:|
| <img width="280" height="606" alt="지도 화면" src="https://github.com/user-attachments/assets/cff31169-f4dc-4fa3-a6e7-2e3208334cd3" /> | <img width="280" height="606" alt="주차장 목록" src="https://github.com/user-attachments/assets/bd87b92a-8f95-4638-ae96-5a388e732cba" /> | <img width="280" height="606" alt="상세 정보" src="https://github.com/user-attachments/assets/85a41308-b937-4d79-b1f2-ad5395d3cfdc" /> | <img width="280" height="606" alt="길찾기" src="https://github.com/user-attachments/assets/c6db46f7-c344-4538-86f2-377ef877d77d" /> |
| 실시간 위치 기반 지도 | 거리순 정렬 목록 | 주차 현황 및 요금 | 다중 지도 앱 지원 |

<br>

## 🚀 시작하기

### 📋 사전 요구사항

```
- Flutter SDK 3.0 이상
- Dart SDK 2.17 이상
- Android Studio 또는 Xcode
- 네이버 클라우드 플랫폼 계정
- 제주 교통정보센터 Open API 가입
- 공항 API 가입
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

#### 3️⃣ **환경 변수 설정**

프로젝트 루트에 `.env` 파일 생성:

```bash
# .env
NAVER_MAP_CLIENT_ID=your_naver_map_client_id
NAVER_CLIENT_ID=your_naver_client_id
NAVER_CLIENT_SECRET=your_naver_client_secret
JEJU_API_CODE=your_jeju_api_code
AIRPORT_API_KEY=your_airport_api_code
DEVELOPER_EMAIL=your_email@example.com
```

#### 4️⃣ **앱 실행**

```bash
flutter run
```

<br>

## 🏗️ 프로젝트 구조

Clean Architecture 기반으로 설계된 프로젝트 구조입니다.

```
lib/
├── core/                                 # 공통 모듈
│   ├── constants/
│   │   ├── airport_constants.dart        # 공항 주차장 상수
│   │   ├── api_constants.dart            # API 상수
│   │   └── app_constants.dart            # 앱 전역 상수
│   │
│   ├── utils/
│   │   └── logger.dart                   # 로깅 유틸리티
│   │
│   └── widgets/                          # 공통 위젯
│       ├── common/
│       │   ├── error_view.dart           # 에러 뷰
│       │   └── loading_indicator.dart    # 로딩 인디케이터
│       │
│       ├── map/
│       │   ├── cluster_marker.dart       # 클러스터 마커
│       │   └── parking_marker.dart       # 주차장 마커
│       │
│       └── sheet/
│           └── parking_bottom_sheet.dart # 주차장 바텀시트
│
├── features/                             # 도메인별 기능 모듈
│   ├── auth/                             # 인증 도메인
│   │   ├── data/
│   │   │   ├── datasource/
│   │   │   │   └── remote/
│   │   │   │       ├── auth_remote_datasource.dart
│   │   │   │       ├── auth_remote_datasource_fake.dart
│   │   │   │       └── auth_remote_datasource_firebase.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   └── auth_user.dart        # 인증 사용자 모델
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart  # 인증 저장소 인터페이스
│   │   │
│   │   └── presentation/
│   │       └── providers/
│   │           ├── auth_provider.dart    # 인증 상태 제공자
│   │           ├── data/
│   │           │   └── datasource_providers.dart
│   │           └── domain/
│   │               └── repository_providers.dart
│   │
│   ├── location/                         # 위치 도메인
│   │   ├── data/
│   │   │   ├── datasource/
│   │   │   │   └── local/
│   │   │   │       └── location_datasource.dart
│   │   │   └── repositories/
│   │   │       └── location_repository_impl.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   └── user_location.dart    # 사용자 위치 모델
│   │   │   └── repositories/
│   │   │       └── location_repository.dart
│   │   │
│   │   └── presentation/
│   │       └── providers/
│   │           ├── location_providers.dart
│   │           ├── data/
│   │           │   └── datasource_providers.dart
│   │           └── domain/
│   │               └── repository_providers.dart
│   │
│   ├── parking/                          # 주차장 도메인
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── remote/
│   │   │   │       ├── airport_api_datasource.dart
│   │   │   │       ├── jeju_api_datasource.dart
│   │   │   │       ├── private_parking_lot_datasource.dart
│   │   │   │       └── seoul_api_datasource.dart
│   │   │   │
│   │   │   ├── entities/                 # API 응답 모델
│   │   │   │   ├── airport_parking_entity.dart
│   │   │   │   ├── jeju_parking_info_entity.dart
│   │   │   │   ├── jeju_parking_status_entity.dart
│   │   │   │   ├── private_parking_entity.dart
│   │   │   │   └── seoul_parking_entity.dart
│   │   │   │
│   │   │   ├── mappers/
│   │   │   │   └── parking_mapper.dart   # Entity → Model 변환
│   │   │   │
│   │   │   └── repositories/
│   │   │       └── parking_repository_impl.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── parking_cluster.dart  # 주차장 클러스터 모델
│   │   │   │   └── parking_lot.dart      # 주차장 모델
│   │   │   │
│   │   │   ├── repositories/
│   │   │   │   └── parking_repository.dart
│   │   │   │
│   │   │   └── services/
│   │   │       ├── distance_service.dart # 거리 계산 서비스
│   │   │       ├── parking_clustering_service.dart # 클러스터링 서비스
│   │   │       └── parking_search_service.dart # 검색 서비스
│   │   │
│   │   └── presentation/
│   │       └── providers/
│   │           ├── parking_providers.dart
│   │           ├── service_providers.dart
│   │           ├── data/
│   │           │   └── datasource_providers.dart
│   │           └── domain/
│   │               └── repository_providers.dart
│   │
│   └── user/                             # 사용자 도메인
│       ├── data/
│       │   ├── datasource/
│       │   │   └── remote/
│       │   │       ├── user_remote_datasource.dart
│       │   │       └── user_remote_datasource_firebase.dart
│       │   │
│       │   ├── entities/
│       │   │   └── user_location_entity.dart
│       │   │
│       │   └── repositories/
│       │       └── user_repository_impl.dart
│       │
│       ├── domain/
│       │   ├── models/
│       │   │   ├── car.dart              # 차량 모델
│       │   │   └── user.dart             # 사용자 모델
│       │   │
│       │   └── repositories/
│       │       └── user_repository.dart
│       │
│       └── presentation/
│           └── providers/
│               ├── user_provider.dart
│               ├── data/
│               │   └── datasource_providers.dart
│               └── domain/
│                   └── repository_providers.dart
│
├── screens/                              # 화면 (임시)
│   ├── parking_map_screen.dart
│   ├── parking_test_screen.dart
│   └── test_screen.dart
│
└── main.dart                             # 앱 진입점
```

### 아키텍처 설명

각 도메인(feature)은 **Clean Architecture** 3계층으로 구성:

- **Data Layer**: API 통신, 데이터 변환, Repository 구현
- **Domain Layer**: 비즈니스 로직, 모델, Repository 인터페이스, 서비스
- **Presentation Layer**: UI 상태 관리(Riverpod), Provider 정의

<br>

## 🔌 API 명세

### 제주 교통정보센터 Open API

**Base URL:** `http://api.jejuits.go.kr/api/`

#### 주차장 기본 정보 조회

```
GET /infoParkingInfoList?code={API_KEY}
```

**Response:**

```json
{
  "result": "success",
  "info_cnt": 2,
  "Info": [
    {
      "id": "16488201",
      "name": "법원북측공영주차장",
      "addr": "법원북측",
      "x_crdn": 126.53534209,
      "y_crdn": 33.49472463,
      "park_day": "월화수목금토일",
      "wkdy_strt": "090000",
      "wkdy_end": "180000",
      "lhdy_strt": "090000",
      "lhdy_end": "180000",
      "basic_time": 30,
      "basic_fare": 1000,
      "add_time": 15,
      "add_fare": 500,
      "whol_npls": 91
    }
  ]
}
```

#### 주차장 실시간 현황

```
GET /infoParkingStateList?code={API_KEY}
```

**Response:**

```json
{
  "result": "success",
  "info_cnt": 2,
  "Info": [
    {
      "id": "16488201",
      "gnrl": 10,
      "lgvh": 7,
      "hvvh": 0,
      "emvh": 0,
      "hndc": 2,
      "wmon": 0,
      "etc": 0
    }
  ]
}
```

| 필드 | 설명 |
|------|------|
| `gnrl` | 일반 주차 가능 대수 |
| `lgvh` | 대형차 주차 가능 대수 |
| `hvvh` | 장애인 주차 가능 대수 |
| `emvh` | 여성 전용 주차 가능 대수 |
| `hndc` | 휠체어 접근 가능 대수 |

<br>

## 📦 배포 현황

### 🤖 Android

- **상태:** Google Play Store 출시 완료 ✅
- **출시일:** 2025년 11월 6일
- **빌드 버전:** 1.1.8+24

### 🍎 iOS

- **상태:** App Store 출시 완료 ✅
- **출시일:** 2025년 10월 17일
- **빌드 버전:** 1.1.8+24

<br>

## 🎯 주요 개발 경험 및 배운 점

### 💡 **기술적 성과**

- **Clean Architecture 적용:** 도메인별 레이어 분리로 유지보수성 및 테스트 용이성 향상
- **공공 데이터 API 연동:** 제주 교통정보센터 및 공항 Open API를 활용한 실시간 데이터 처리
- **Firebase 통합:** Firebase Auth(전화번호 인증), Cloud Firestore를 활용한 데이터 관리
- **Riverpod 상태관리:** BLoC/Cubit에서 Riverpod으로 마이그레이션하여 더 효율적인 상태 관리 구현
- **로컬 저장소 최적화:** SharedPreferences에서 Hive로 마이그레이션하여 성능 향상
- **GPS 기반 서비스:** Geolocator를 이용한 현재 위치 추적 및 근처 주차장 자동 검색
- **지도 API 통합:** 네이버 지도 API 및 다중 네비게이션 앱 연동
- **권한 관리:** iOS/Android 플랫폼별 권한 요청 처리
- **환경 변수 관리:** flutter_dotenv를 활용한 안전한 API 키 관리
- **다중 지도 앱 지원:** 네이버, 카카오, 구글, 애플 지도 등 사용자 선택 가능
- **정보 공유 기능:** share_plus를 활용한 주차장 정보 공유
- **테마 관리:** 라이트/다크 모드 지원

### 🚀 **개발 프로세스**

- **UI/UX:** 직관적인 주차 현황 표시를 위한 색상 코딩 시스템 개발
- **성능 최적화:** 대량의 주차장 데이터 처리 및 위치 업데이트 최적화
- **에러 처리:** 네트워크 오류, 권한 거부 등 다양한 예외 상황 대응
- **플랫폼 배포:** iOS App Store와 Android Google Play Store 배포 경험

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

이 프로젝트는 **독점 소프트웨어**입니다.
무단 복제, 수정, 배포를 금지합니다.
© 2025 이지훈. All Rights Reserved.

<br>

## 👨‍💻 개발자

**이지훈 (Lee Ji-Hoon)**

- 📧 **Email:** jihooni0113@gmail.com
- 🔗 **GitHub:** [@codehooni](https://github.com/codehooni)
- 📱 **Phone:** 010-2624-8748

<br>

## 🙏 감사의 말

- 🏢 제주특별자치도 교통정보센터의 **Open API 제공**에 감사드립니다
- 🏢 한국항공공사의 **Open API 제공**에 감사드립니다. 
- 🗺️ 네이버 지도 API를 활용할 수 있게 해주신 **네이버**에 감사드립니다
- 💙 피드백을 주신 **테스트 사용자**들께 감사드립니다
- 🅿️ 첫 파트너가 되어주신 **조은주차장**께 감사드립니다

<br>

---

<div align="center">

**Made with ❤️ in Jeju, South Korea**

![Jeju](https://img.shields.io/badge/Location-Jeju%20Island-FF6B6B?style=flat)
![Version](https://img.shields.io/badge/Version-1.1.8-brightgreen?style=flat)
![Status](https://img.shields.io/badge/Status-Active%20Development-yellow?style=flat)

</div>
