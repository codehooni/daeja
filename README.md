# 대자 (Daeja) 🅿️

> 제주도 실시간 주차장 정보 제공 및 발렛 예약 서비스

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)
![Naver Map](https://img.shields.io/badge/Naver%20Map%20API-00C73C?style=flat&logo=naver&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-02569B?style=flat&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat&logo=firebase&logoColor=black)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

<br>

## 📱 프로젝트 개요

**대자(Daeja)** 는 제주도 내 주차장의 실시간 주차 가능 여부를 확인하고, 편리하게 **발렛 주차를 예약**할 수 있는 Flutter 기반 모바일 애플리케이션입니다.

제주 교통정보센터의 공공 API를 활용하여 **정확한 실시간 주차 현황**을 제공하며, 발렛 서비스가 가능한 주차장의 경우 앱 내에서 즉시 예약하고 기사님 배정까지 확인할 수 있는 원스톱 서비스를 제공합니다.

<br>

## ✨ 핵심 기능

### 🎯 **위치 기반 주차장 검색**
- GPS 기반 현재 위치 근처 주차장 자동 탐색
- 네이버 지도를 통한 직관적인 위치 확인 및 마커 클러스터링
- 주차장 타입별(공영/민영/발렛) 색상 구분 마커

### 📊 **실시간 주차 현황 확인**
- 제주 교통정보센터 & 전국 공항 API 연동 실시간 데이터 제공
- 주차 가능 여부를 **직관적인 색상 UI**로 한눈에 파악
- 주차장별 상세 요금 및 운영 시간 정보

### 🚗 **발렛 주차 예약 (신규)**
- 원하는 주차장 선택 후 즉시 발렛 예약 신청
- **실시간 예약 상태 모니터링** (대기/승인/확정/완료)
- 배정된 기사님 정보 및 연락처 확인 가능

### 🗺️ **다중 네비게이션 연동**
- 네이버, 카카오, TMAP, 애플, 구글 지도 앱 즉시 실행
- 최적 경로 안내 및 실시간 내비게이션 지원

### 🎙️ **스마트 검색 및 알림**
- **음성 인식(STT)** 기반 주차장 검색 지원
- 예약 상태 변경에 따른 **실시간 푸시 알림**

<br>

## 🛠 기술 스택

### 📲 **Frontend & Core**

| 항목 | 기술 | 버전 |
|------|------|------|
| Framework | Flutter | 3.24+ |
| Language | Dart | 3.5+ |
| 상태관리 | Riverpod | 3.0.3+ |
| 로컬 저장소 | Hive | 2.2.3+ |
| 백엔드 | Firebase Cloud Firestore | 6.1.0+ |
| 인증 | Firebase Auth (Phone) | 6.1.2+ |
| 푸시 알림 | Firebase Messaging | 16.1.0+ |

### 🌐 **External APIs & Library**

| 서비스 | 목적 | 패키지 |
|--------|------|--------|
| Naver Map API | 지도 표시 및 마커 관리 | flutter_naver_map ^1.4.4 |
| Jeju ITS / Airport | 실시간 주차 정보 수집 | dio ^5.9.0 |
| Location | GPS 위치 추적 | geolocator ^14.0.2 |
| Animation | 매끄러운 UI 인터랙션 | flutter_animate ^4.5.2 / velocity_x |
| Voice | 음성 검색 기능 | speech_to_text ^7.0.0 |
| Webview | 외부 공지 및 약관 표시 | webview_flutter ^4.13.1 |

<br>

## 📸 스크린샷

| 지도 화면 | 주차장 목록 | 상세 정보 | 발렛 예약 |
|:---:|:---:|:---:|:---:|
| <img width="280" alt="지도 화면" src="https://github.com/user-attachments/assets/cff31169-f4dc-4fa3-a6e7-2e3208334cd3" /> | <img width="280" alt="주차장 목록" src="https://github.com/user-attachments/assets/bd87b92a-8f95-4638-ae96-5a388e732cba" /> | <img width="280" alt="상세 정보" src="https://github.com/user-attachments/assets/85a41308-b937-4d79-b1f2-ad5395d3cfdc" /> | <img width="280" alt="발렛 예약" src="https://github.com/user-attachments/assets/c6db46f7-c344-4538-86f2-377ef877d77d" /> |
| 실시간 위치 기반 지도 | 거리순 정렬 목록 | 주차 현황 및 요금 | 편리한 발렛 예약 신청 |

<br>

## 🚀 시작하기

### ⚙️ 설치 및 실행

1. **저장소 클론**
   ```bash
   git clone https://github.com/codehooni/daeja.git
   ```
2. **패키지 설치**
   ```bash
   flutter pub get
   ```
3. **환경 변수 설정**
   `.env` 파일을 루트에 생성하고 API 키를 입력하세요. (상세 내역은 `.env.example` 참조)
4. **실행**
   ```bash
   flutter run
   ```

<br>

## 🏗️ 프로젝트 구조

Clean Architecture 기반의 기능별(Feature-First) 구조입니다.

```
lib/
├── core/                                 # 공통 유틸, 상수, 위젯
├── features/                             # 도메인별 기능 모듈
│   ├── auth/                             # 전화번호 기반 인증
│   ├── location/                         # 위치 추적 및 권한
│   ├── parking/                          # 주차장 데이터 (Jeju, Airport, Seoul)
│   ├── reservation/                      # 발렛 예약 관리 (신규)
│   └── user/                             # 사용자 프로필 및 차량 정보
├── presentation/                         # 공통 화면 (Splash, Search, Map)
└── main.dart                             # 앱 진입점
```

<br>

## 🎯 주요 개발 성과

- **Clean Architecture + Riverpod**: 견고한 아키텍처와 최신 상태 관리 기법을 통한 코드 유지보수성 극대화
- **실시간 데이터 파이프라인**: 다중 공공 API(제주, 전국 공항, 서울)의 비동기 병렬 처리 및 데이터 매핑
- **발렛 예약 시스템 구축**: Firestore Stream을 활용한 실시간 예약 상태 동기화 및 푸시 알림 통합
- **UI/UX 최적화**: `flutter_animate`를 활용한 매끄러운 화면 전환과 직관적인 마커 클러스터링 구현
- **성능 최적화**: `Hive` 로컬 DB를 활용한 설정 데이터 및 검색 기록 캐싱 처리

<br>

## 📄 라이선스

이 프로젝트는 **독점 소프트웨어**입니다.
무단 복제, 수정, 배포를 금지합니다.
© 2025 이지훈. All Rights Reserved.

---

<div align="center">

**Made with ❤️ in Jeju, South Korea**

![Version](https://img.shields.io/badge/Version-1.2.1-brightgreen?style=flat)
![Status](https://img.shields.io/badge/Status-Active%20Development-yellow?style=flat)

</div>

