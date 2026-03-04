# Daeja App - Design Brief

## 프로젝트 개요

**앱 이름**: Daeja (대자)
**플랫폼**: Flutter (iOS & Android)
**타겟 사용자**: 제주도 방문객 및 거주민, 전국 공항 이용객, 서울 시민
**핵심 가치**: 실시간 주차장 정보 제공 및 발렛 주차 예약 서비스

## 앱 목적

제주도를 중심으로 전국의 주차장 정보를 지도에 표시하고, 실시간 주차 가능 여부를 제공합니다. 발렛 주차장의 경우 모바일에서 예약하고 기사님 배정까지 받을 수 있는 원스톱 서비스를 제공합니다.

---

## 핵심 기능

### 1. 실시간 주차장 지도
- **기능**: 네이버 맵 기반으로 주차장 위치를 마커로 표시
- **주차장 타입**:
  - 공영 주차장 (파란색 마커)
  - 민영 주차장 (주황색 마커)
  - 발렛 주차장 (보라색 마커, 예약 가능)
- **실시간 정보**: 주차 가능 대수, 총 주차면 수, 요금 정보
- **마커 클러스터링**: 확대/축소 시 마커 자동 그룹화

### 2. 발렛 주차 예약
- **예약 생성**: 차량 선택, 도착 시간 선택, 출차 시간 선택(선택사항), 메모 작성
- **실시간 예약 모니터링**: 예약 상태가 변경되면 즉시 앱에 반영 (LIVE 뱃지)
- **예약 상태**:
  - `대기중` (pending): 예약 생성 후 관리자 승인 대기
  - `승인됨` (approved): 관리자가 기사님 배정 완료
  - `확정` (confirmed): 예약 확정
  - `완료` (completed): 주차 서비스 완료
  - `취소됨` (cancelled): 사용자 또는 관리자가 취소
- **기사님 정보 표시**: 승인 후 배정된 기사님의 이름과 전화번호 표시

### 3. 내 예약 목록
- **실시간 업데이트**: Stream 기반으로 예약 상태 자동 갱신
- **카테고리별 분류**:
  - 활성 예약 (대기중/승인됨/확정)
  - 완료된 예약
  - 취소된 예약
- **예약 상세 정보**:
  - 주차장 이름
  - 차량 번호
  - 도착/출차 예정 시간
  - 예약 생성 시간
  - 메모
  - 배정된 기사님 정보 (승인 시)
- **예약 취소 기능**: 활성 예약에 대해 취소 가능

### 4. 사용자 인증 및 프로필
- **Firebase Phone Authentication**: 전화번호 기반 로그인
- **차량 관리**: 여러 대의 차량 등록 및 관리 가능
- **프로필 정보**: 이름, 전화번호, 차량 정보

---

## 화면 구조

### 1. 메인 화면 (지도)
- **헤더**: 앱 타이틀, 프로필 버튼, 예약 목록 버튼
- **지도**: 전체 화면 네이버 맵
- **마커**: 주차장 위치 표시 (타입별 색상 구분)
- **마커 클릭**: 주차장 정보 바텀시트
- **내 위치 버튼**: 현재 위치로 이동
- **하단 네비게이션**: 메인/검색/히스토리 (현재 메인만 구현됨)

### 2. 주차장 정보 바텀시트
- **주차장 이름**
- **주차 가능 여부**: "주차 가능" (초록색) / "만차" (빨간색)
- **주차 현황**: 이용 가능 N대 / 총 M대
- **요금 정보**: 기본 요금, 추가 요금
- **운영 시간**
- **주소 및 전화번호**
- **발렛 주차장 전용**: "발렛 예약하기" 버튼

### 3. 발렛 예약 화면 (`ValetReservationScreen`)
- **주차장 정보 요약**: 이름, 주소, 전화번호
- **차량 선택 드롭다운**: 등록된 차량 목록
- **도착 시간 선택**: DateTimePicker
- **출차 시간 선택**: DateTimePicker (선택사항)
- **메모 입력**: TextField
- **예약하기 버튼**: 하단 고정, 전체 너비

### 4. 내 예약 목록 화면 (`MyReservationsScreen`)
- **헤더**: "내 예약 목록" + "LIVE" 뱃지
- **활성 예약 섹션**: 초록색 라벨, 카드 리스트
- **완료된 예약 섹션**: 파란색 라벨, 카드 리스트
- **취소된 예약 섹션**: 회색 라벨, 카드 리스트
- **예약 카드**:
  - 상단: 예약 ID (축약), 주차장 이름, 상태 뱃지
  - 도착/출차 예정 시간
  - 차량 번호
  - 예약 생성 시간
  - 배정된 기사님 정보 (승인 시, 초록색 박스)
  - 메모 (있는 경우, 회색 박스)
  - 예약 취소 버튼 (활성 예약만)

### 5. 테스트 화면 (`TestScreen`)
- 개발자용 디버깅 화면
- 사용자 정보, 차량 정보 표시
- Firebase 데이터 확인

---

## 데이터 모델

### Reservation (예약)
```
- id: 예약 고유 ID
- visitorId: 사용자 ID
- visitorVehicleId: 차량 ID
- visitorVehiclePlate: 차량 번호 (denormalized)
- parkingLotId: 주차장 ID
- parkingLotName: 주차장 이름 (denormalized)
- expectedArrival: 도착 예정 시간
- expectedExit: 출차 예정 시간 (optional)
- status: 예약 상태 (enum)
- createdAt: 예약 생성 시간
- notes: 메모 (optional)
- assignedSpotId: 배정된 주차 구역 (optional)
- handledByStaffId: 담당 기사 ID (optional)
- handledByStaffName: 담당 기사 이름 (denormalized, optional)
- handledByStaffPhone: 담당 기사 전화번호 (denormalized, optional)
- actualArrival: 실제 도착 시간 (optional)
- actualExit: 실제 출차 시간 (optional)
- logs: 예약 로그 (optional)
```

### User (사용자)
```
- uid: Firebase Auth UID
- name: 이름
- phoneNumber: 전화번호
- email: 이메일 (optional)
- vehicles: 차량 목록
- createdAt: 가입 시간
```

### Vehicle (차량)
```
- id: 차량 ID
- userId: 소유자 ID
- plateNumber: 차량 번호
- brand: 제조사 (optional)
- model: 모델명 (optional)
- color: 색상 (optional)
```

### ParkingLot (주차장)
```
- id: 주차장 ID
- name: 주차장 이름
- address: 주소
- latitude: 위도
- longitude: 경도
- totalSpots: 총 주차 면수
- availableSpots: 이용 가능 대수
- type: 주차장 타입 (public/private/valet)
- phoneNumber: 전화번호 (optional)
- operatingHours: 운영 시간 (optional)
- baseRate: 기본 요금 (optional)
- additionalRate: 추가 요금 (optional)
```

---

## 디자인 시스템 요구사항

### 색상 스키마
- **Primary**: 앱 메인 컬러 (추천: 제주 바다 블루 계열)
- **Success/Active**: 초록색 (`Colors.green`) - 승인, 활성 예약, LIVE 뱃지
- **Warning/Pending**: 주황색 (`Colors.orange`) - 대기중 상태
- **Error/Cancelled**: 빨간색/회색 - 만차, 취소
- **Info/Completed**: 파란색 (`Colors.blue`) - 완료된 예약
- **Background**: 흰색, 밝은 회색

### 아이콘
- 상태별 아이콘:
  - `Icons.schedule`: 대기중
  - `Icons.check_circle`: 승인/확정
  - `Icons.done_all`: 완료
  - `Icons.cancel`: 취소
  - `Icons.wifi`: LIVE 실시간
- 정보 아이콘:
  - `Icons.directions_car`: 차량
  - `Icons.login/logout`: 입출차
  - `Icons.access_time`: 시간
  - `Icons.note`: 메모
  - `Icons.person`: 기사님
  - `Icons.phone`: 전화
  - `Icons.badge`: 이름

### 타이포그래피
- **대제목**: 18pt, Bold - 섹션 헤더
- **제목**: 16pt, Bold - 카드 제목, 주차장 이름
- **본문**: 13-14pt, Regular/Medium - 일반 텍스트
- **캡션**: 10-12pt, Regular - 라벨, ID, 부가 정보

### 컴포넌트 스타일
- **Card**: Elevation 2, 둥근 모서리, 16pt 패딩
- **Badge/Tag**: 작은 아이콘 + 텍스트, 투명 배경 + 테두리
- **Button**:
  - Primary: 전체 너비, 높이 48-56pt
  - Outlined: 빨간색 테두리 (취소 버튼)
- **Info Box**:
  - 기사님 정보: 초록색 배경/테두리
  - 메모: 회색 배경
- **섹션 헤더**: 왼쪽 수직선 + 텍스트 + 카운트 뱃지

---

## 사용자 플로우

### 발렛 예약 플로우
1. 지도에서 발렛 주차장 마커 선택
2. 바텀시트에서 "발렛 예약하기" 버튼 클릭
3. 예약 화면에서 차량 선택
4. 도착 시간 선택 (필수)
5. 출차 시간 선택 (선택)
6. 메모 입력 (선택)
7. "예약하기" 버튼 클릭
8. 예약 생성 완료, 내 예약 목록으로 이동
9. 예약 상태 실시간 모니터링
10. 관리자 승인 시 → 기사님 정보 확인
11. 예약 완료 또는 취소

### 예약 취소 플로우
1. 내 예약 목록에서 활성 예약 선택
2. "예약 취소" 버튼 클릭
3. 확인 다이얼로그: "정말 이 예약을 취소하시겠습니까?"
4. "예, 취소합니다" 클릭
5. 예약 상태가 "취소됨"으로 변경
6. 취소된 예약 섹션으로 이동

---

## 기술적 제약사항

### Flutter & Material Design
- Material Design 3 가이드라인 준수
- 반응형 레이아웃 (다양한 화면 크기 지원)
- 다크모드 지원 고려 (향후)

### 네이버 맵 SDK
- 마커 색상 제한 있음
- 커스텀 마커 이미지 사용 가능
- 클러스터링 UI 커스터마이징 제한적

### Firebase 실시간 업데이트
- Stream 기반 UI 업데이트
- LIVE 뱃지로 실시간 연결 상태 표시
- 네트워크 연결 끊김 시 처리 필요

### 한글 및 국제화
- 현재 한글 전용
- 향후 영어/중국어/일본어 지원 고려

---

## 우선순위별 디자인 개선 항목

### 우선순위 1 (필수)
- [ ] 앱 브랜딩 (로고, 컬러 스키마, 폰트)
- [ ] 메인 지도 화면 UI/UX 개선
- [ ] 주차장 정보 바텀시트 디자인
- [ ] 발렛 예약 화면 디자인
- [ ] 내 예약 목록 화면 디자인
- [ ] 상태 뱃지 및 아이콘 시스템

### 우선순위 2 (중요)
- [ ] 예약 카드 레이아웃 최적화
- [ ] 기사님 정보 박스 디자인
- [ ] 날짜/시간 선택 UI 개선
- [ ] 로딩 상태 및 에러 화면
- [ ] 빈 상태 일러스트레이션

### 우선순위 3 (향후)
- [ ] 온보딩 화면
- [ ] 프로필 설정 화면
- [ ] 차량 관리 화면
- [ ] 검색 기능 화면
- [ ] 히스토리 화면
- [ ] 푸시 알림 디자인

---

## 참고 자료

### 유사 앱
- 카카오내비 (주차장 정보)
- T맵 (주차장 검색)
- 파킹프렌즈 (발렛 주차)
- 발렛온 (발렛 서비스)

### 디자인 가이드
- Material Design 3: https://m3.material.io/
- Flutter Widget Gallery: https://gallery.flutter.dev/
- Naver Map SDK: https://navermaps.github.io/android-map-sdk/

---

## 제공할 파일

디자인 작업 시 참고할 현재 구현 파일:
- `lib/screens/my_reservations_screen.dart` - 내 예약 목록 화면
- `lib/screens/valet_reservation_screen.dart` - 발렛 예약 화면
- `lib/features/reservation/domain/models/reservation.dart` - 예약 데이터 모델
- `lib/features/parking/presentation/screens/map_screen.dart` - 메인 지도 화면

현재 스크린샷 및 화면 흐름도는 실제 앱 실행 후 제공 예정.

---

## 디자이너 요청사항

1. **와이어프레임**: 주요 화면 5개 (지도, 주차장 정보, 예약 생성, 예약 목록, 프로필)
2. **컬러 팔레트**: 브랜드 컬러, Primary/Secondary/Accent 정의
3. **컴포넌트 라이브러리**: 버튼, 카드, 뱃지, 입력 필드 등
4. **아이콘 세트**: 커스텀 아이콘이 필요한 경우
5. **프로토타입**: 주요 사용자 플로우 (예약 생성 → 승인 → 완료)
6. **스타일 가이드**: 타이포그래피, 간격, 그림자, 애니메이션

디자인 파일 형식: Figma 선호 (Flutter 연동 용이)
