# 대자(Daeja) 앱 아키텍처 문서

## 개요
제주도 주차장 정보 제공 Flutter 앱으로, Clean Architecture + DDD (Domain-Driven Design) 패턴을 적용하여 구조화되었습니다.

## 아키텍처 원칙

### 1. Clean Architecture
```
Presentation Layer  →  Domain Layer  ←  Data Layer
    (UI/State)         (Business Logic)    (Data Sources)
```

- **Domain Layer**: 비즈니스 로직과 엔티티 (외부 의존성 없음)
- **Data Layer**: 데이터 소스 및 Repository 구현
- **Presentation Layer**: UI 및 State Management

### 2. Feature-First 구조
기능별로 독립적인 모듈화하여 각 feature가 완전한 레이어 구조를 포함합니다.

## 프로젝트 구조

```
lib/
├── core/                          # 공통 인프라
│   ├── di/                        # Dependency Injection
│   │   └── injection.dart
│   ├── error/                     # 에러 처리
│   │   ├── failures.dart          # Domain layer failures
│   │   └── exceptions.dart        # Data layer exceptions
│   ├── network/                   # 네트워크 추상화
│   │   └── api_client.dart        # HTTP client wrapper
│   └── utils/                     # 유틸리티
│       ├── either.dart            # Result type (Either<L, R>)
│       └── constants.dart         # App constants
│
├── features/                      # 기능별 모듈
│   ├── parking/                   # 주차장 기능
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── parking_lot.dart         # 순수 비즈니스 객체
│   │   │   ├── repositories/
│   │   │   │   └── parking_repository.dart  # Repository interface
│   │   │   └── usecases/
│   │   │       ├── get_parking_lots.dart
│   │   │       ├── refresh_parking_data.dart
│   │   │       ├── get_nearby_parking.dart
│   │   │       └── search_parking.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── parking_lot_model.dart   # DTO (API ↔ Entity)
│   │   │   ├── datasources/
│   │   │   │   ├── parking_remote_datasource.dart  # API 호출
│   │   │   │   └── parking_local_datasource.dart   # 캐싱
│   │   │   └── repositories/
│   │   │       └── parking_repository_impl.dart    # Repository 구현
│   │   └── presentation/
│   │       └── providers/
│   │           └── parking_provider.dart    # State management
│   │
│   ├── location/                  # 위치 기능
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_location.dart
│   │   │   ├── repositories/
│   │   │   │   └── location_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_current_location.dart
│   │   │       └── check_location_permission.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── datasources/
│   │   │   └── repositories/
│   │   └── presentation/
│   │
│   ├── navigation/                # 네비게이션 기능 (지도앱 연동)
│   │   └── data/
│   │       └── repositories/
│   │           └── navigation_repository_impl.dart
│   │
│   ├── map/                       # 지도 기능 (클러스터링)
│   │   └── domain/
│   │       └── entities/
│   │           └── cluster_point.dart
│   │
│   └── settings/                  # 설정 기능
│       └── presentation/
│           ├── providers/
│           │   └── theme_provider.dart
│           └── pages/
│               └── settings_page.dart
│
├── shared/                        # 공유 UI 컴포넌트
│   ├── widgets/                   # 공통 위젯
│   ├── theme/                     # 테마 (light/dark)
│   └── extensions/                # Extension methods
│
├── pages/                         # Legacy pages (점진적 마이그레이션)
│   ├── main_page.dart
│   └── home_page.dart
│
└── main.dart                      # 앱 진입점
```

## 주요 패턴

### 1. Repository 패턴
```dart
// Domain (interface)
abstract class ParkingRepository {
  Future<Either<Failure, List<ParkingLot>>> getParkingLots();
}

// Data (implementation)
class ParkingRepositoryImpl implements ParkingRepository {
  final ParkingRemoteDataSource remoteDataSource;
  final ParkingLocalDataSource localDataSource;
  // 구현...
}
```

### 2. UseCase 패턴
```dart
class GetParkingLots {
  final ParkingRepository repository;

  Future<Either<Failure, List<ParkingLot>>> call() {
    return repository.getParkingLots();
  }
}
```

### 3. Either 패턴 (Error Handling)
```dart
final result = await getParkingLots();
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (parkingLots) => print('Success: ${parkingLots.length} lots'),
);
```

### 4. DTO ↔ Entity 변환
```dart
// Data layer - API 응답
class ParkingLotModel {
  factory ParkingLotModel.fromJson(Map<String, dynamic> json);
  ParkingLot toEntity();
}

// Domain layer - 순수 비즈니스 객체
class ParkingLot {
  // fromJson 없음, 외부 의존성 없음
}
```

## 의존성 방향

```
Presentation  →  Domain  ←  Data
     ↓            ↓          ↓
  Provider    UseCase    Repository
                ↓            ↓
             Entity    DataSource
```

- **단방향 의존**: Presentation → Domain ← Data
- **Domain은 독립적**: 외부 패키지 의존성 없음
- **의존성 역전**: Repository는 Domain의 interface, Data가 구현

## Dependency Injection

```dart
// lib/core/di/injection.dart
class Injection {
  static List<SingleChildWidget> providers = [
    // Data Sources
    Provider<ParkingRemoteDataSource>(...),
    Provider<ParkingLocalDataSource>(...),

    // Repositories
    Provider<ParkingRepository>(...),

    // UseCases
    Provider<GetParkingLots>(...),

    // Providers (State)
    ChangeNotifierProvider<ParkingProvider>(...),
  ];
}
```

## 테스트 전략

### Unit Tests
- **UseCases**: 비즈니스 로직 테스트
- **Repositories**: Mock DataSource 사용
- **Entities**: 순수 로직 테스트

### Widget Tests
- **Providers**: State 변경 테스트
- **Pages**: UI 렌더링 테스트

### Integration Tests
- End-to-end 시나리오 테스트

## 확장 가능성

### 새로운 기능 추가
```
lib/features/new_feature/
  ├── domain/
  ├── data/
  └── presentation/
```

### 새로운 데이터 소스
```dart
class NewDataSource implements BaseDataSource {
  // 구현
}

// DI에 등록
Provider<NewDataSource>(...)
```

## 마이그레이션 계획

### Phase 1: ✅ 완료
- Core 인프라 구축
- Parking feature 리팩토링
- Location feature 구조화
- DI 설정

### Phase 2: 🔄 진행 중
- Pages 리팩토링 (UseCase 사용)
- Legacy code 정리

### Phase 3: 📋 예정
- Unit/Widget 테스트 작성
- API Error 처리 개선
- 성능 최적화

## 주요 이점

✅ **테스트 가능성**: 각 레이어 독립 테스트 가능
✅ **확장성**: 새 기능 추가 시 기존 코드 영향 최소화
✅ **유지보수성**: 명확한 책임 분리
✅ **재사용성**: 도메인 로직 재사용 가능
✅ **의존성 관리**: 단방향 의존성으로 결합도 낮음

## 참고자료
- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)
- [Domain-Driven Design](https://martinfowler.com/bliki/DomainDrivenDesign.html)
