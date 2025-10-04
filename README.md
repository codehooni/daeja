# 대자 (Daeja) 🅿️

> 제주도 실시간 주차장 정보 제공 앱

## 📱 프로젝트 소개

**대자(Daeja)** 는 제주도 내 주차장의 실시간 주차 가능 여부를 확인할 수 있는 Flutter 기반 모바일 애플리케이션입니다. 
제주 교통정보센터의 공공 API를 활용하여 정확한 주차 정보를 제공하며, 네이버 지도를 통해 주차장까지의 길찾기 기능을 지원합니다.

<br>

## ✨ 주요 기능

### 🗺️ 위치 기반 주차장 검색
- GPS를 활용한 내 위치 기반 근처 주차장 자동 탐색
- 실시간 위치 업데이트로 이동 중에도 편리한 검색

### 📊 실시간 주차 현황
- 제주 교통정보센터 API를 통한 실시간 주차 가능 대수 확인
- 주차장별 총 주차 면수 및 현재 주차 가능 면수 표시
- 주차 가능 여부를 한눈에 파악할 수 있는 직관적인 UI

### 🧭 네이버 지도 길찾기
- 선택한 주차장까지 네이버 지도 앱 연동
- 최적 경로 안내 및 실시간 내비게이션 지원

<br>

## 🛠 기술 스택

### Frontend
- **Framework**: Flutter (Dart)
- **최소 버전**: Flutter 3.0 이상

### API & Services
- **지도 서비스**: Naver Map API
- **주차 정보**: 제주특별자치도 교통정보센터 (Jeju ITS) Open API
  - 주차장 기본 정보 API
  - 주차장 실시간 현황 API

### 주요 패키지
```yaml
dependencies:
  flutter_naver_map: # 네이버 지도
  http: # API 통신
  geolocator: # 위치 정보
  permission_handler: # 권한 관리
  url_launcher: # 네이버 지도 앱 연동
```

<br>

## 📸 스크린샷

> 📌 **참고**: 여기에 앱 스크린샷 3장을 넣어주세요!

<p align="center">
  <img width="250" alt="메인화면" src="https://github.com/user-attachments/assets/이미지1-URL" />
  <img width="250" alt="지도화면" src="https://github.com/user-attachments/assets/이미지2-URL" />
  <img width="250" alt="상세화면" src="https://github.com/user-attachments/assets/이미지3-URL" />
</p>

<br>

## 🚀 시작하기

### 사전 요구사항
- Flutter SDK 3.0 이상
- Dart SDK 2.17 이상
- Android Studio / Xcode (플랫폼별)

### 설치 방법

1. **저장소 클론**
```bash
git clone https://github.com/codehooni/daeja.git
cd daeja
```

2. **패키지 설치**
```bash
flutter pub get
```

3. **API 키 설정**
- 네이버 클라우드 플랫폼에서 지도 API 키 발급
- 제주 교통정보센터에서 Open API 키 발급
- `lib/config/api_keys.dart` 파일에 키 입력

```dart
// lib/config/api_keys.dart
class ApiKeys {
  static const String naverMapClientId = 'YOUR_NAVER_MAP_CLIENT_ID';
  static const String jejuItsApiKey = 'YOUR_JEJU_ITS_API_KEY';
}
```

4. **앱 실행**
```bash
flutter run
```

<br>

## 📦 배포

### Android
- **Google Play Store** 비공개 테스트 진행 중
- 정식 출시 예정일: 2025년 10월 중

### iOS
- 준비 중

<br>

## 🔑 주요 API

### 제주 교통정보센터 API
```
Base URL: http://api.jejuits.go.kr/api/
```

**주차장 기본 정보 조회**
```
GET /infoParkingList?code={API_KEY}
```

**주차장 실시간 현황**
```
GET /infoParkingCnt?code={API_KEY}
```

<br>

## 📂 프로젝트 구조

```
lib/
├── config/          # API 키, 환경설정
├── models/          # 데이터 모델
├── services/        # API 통신, 위치 서비스
├── screens/         # 화면 UI
├── widgets/         # 재사용 가능한 위젯
└── main.dart        # 앱 진입점
```

<br>

## 🤝 기여하기

버그 리포트나 기능 제안은 [Issues](https://github.com/codehooni/daeja/issues)에 남겨주세요!

<br>

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 있습니다.

<br>

## 👨‍💻 개발자

**이지훈**
- Email: jihooni0113@gmail.com
- GitHub: [@codehooni](https://github.com/codehooni)

<br>

## 🙏 감사의 말

- 제주특별자치도 교통정보센터의 Open API 제공에 감사드립니다
- 네이버 지도 API를 활용할 수 있게 해주신 네이버에 감사드립니다

---

**Made with ❤️ in Jeju, South Korea**
