/// 차량 제조사 + 모델명을 기반으로 적합한 이미지 경로를 반환하는 서비스
///
/// assets/images/cars/ 하위 5종:
///   ioniq-6.png  → 아이오닉 시리즈
///   staria.png   → 밴 / 미니밴
///   suv.png      → SUV / 크로스오버
///   compact.png  → 경차 / 소형차
///   sedan.png    → 세단 및 기타 (기본값)
class VehicleImageService {
  VehicleImageService._();

  // ── 아이오닉 모델 ──────────────────────────────────────────────
  static const _ioniqModels = {
    '아이오닉5', '아이오닉6',
  };

  // ── 밴 / 미니밴 모델 ───────────────────────────────────────────
  static const _vanModels = {
    '카니발',                            // 기아
    '마스터',                            // 르노
    '스타리아',                          // 현대 (직접 입력 시 대비)
  };

  // ── SUV / 크로스오버 모델 ─────────────────────────────────────
  static const _suvModels = {
    // 현대
    '투싼', '싼타페', '팰리세이드', '코나',
    // 기아
    '스포티지', '쏘렌토', '셀토스', 'EV9',
    // 제네시스
    'GV70', 'GV80',
    // 쌍용
    '티볼리', '코란도', '렉스턴', '토레스',
    // 쉐보레
    '트랙스', '트레일블레이저', '이쿼녹스', '타호',
    // 르노
    'XM3', 'QM6',
    // BMW
    'X1', 'X3', 'X5', 'X7',
    // 벤츠
    'GLA', 'GLC', 'GLE', 'GLS',
    // 아우디
    'Q3', 'Q5', 'Q7', 'Q8',
    // 폭스바겐
    '티구안', '투아렉',
    // 포르쉐
    '마칸', '카이엔',
    // 볼보
    'XC40', 'XC60', 'XC90',
    // 렉서스
    'NX', 'RX', 'GX', 'LX', 'UX',
    // 토요타
    'RAV4', '하이랜더',
    // 혼다
    'CR-V', '파일럿',
    // 닛산
    '로그', '패스파인더',
    // 마쯔다
    'CX-3', 'CX-5', 'CX-9',
    // 포드
    '익스플로러', '익스페디션', 'F-150',
    // 지프
    '랭글러', '그랜드체로키', '체로키', '컴패스',
    // 캐딜락
    'XT4', 'XT5', 'XT6', '에스컬레이드',
  };

  // ── 경차 / 소형차 모델 ────────────────────────────────────────
  static const _compactModels = {
    '캐스퍼', '베뉴',                    // 현대
    '레이', '모닝',                      // 기아
    '스파크',                            // 쉐보레
    '폴로',                              // 폭스바겐
    '쿠퍼', '쿠퍼S', '컨트리맨', '클럽맨', // 미니
    '마쯔다2', '마쯔다3',               // 마쯔다
  };

  /// 제조사와 모델명을 받아 가장 적합한 이미지 경로를 반환합니다.
  ///
  /// [manufacturer] 예: '현대', '기아', '테슬라'
  /// [model]        예: '아이오닉6', 'Model 3', 'K5'
  static String getImagePath({String? manufacturer, String? model}) {
    final m = model?.trim() ?? '';

    // 1. 아이오닉 시리즈
    if (_ioniqModels.contains(m)) return _ioniqPath;

    // 2. 밴 / 미니밴
    if (_vanModels.contains(m)) return _vanPath;

    // 3. SUV
    if (_suvModels.contains(m)) return _suvPath;

    // 4. 경차 / 소형차
    if (_compactModels.contains(m)) return _compactPath;

    // 5. 기본값: 세단
    return _sedanPath;
  }

  static const _basePath = 'assets/images/cars';
  static const _ioniqPath = '$_basePath/ioniq-6.png';
  static const _vanPath = '$_basePath/staria.png';
  static const _suvPath = '$_basePath/suv.png';
  static const _compactPath = '$_basePath/compact.png';
  static const _sedanPath = '$_basePath/sedan.png';
}
