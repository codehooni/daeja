class VehicleConstants {
  // Map of manufacturer name to list of popular models
  static const Map<String, List<String>> manufacturersAndModels = {
    // Korean Domestic Brands
    '현대': [
      '아반떼',
      '쏘나타',
      '그랜저',
      '투싼',
      '싼타페',
      '팰리세이드',
      '코나',
      '베뉴',
      '캐스퍼',
      '아이오닉5',
      '아이오닉6',
      '넥쏘',
      '기타'
    ],
    '기아': [
      'K3',
      'K5',
      'K8',
      'K9',
      '스포티지',
      '쏘렌토',
      'EV6',
      'EV9',
      '셀토스',
      '니로',
      '카니발',
      '레이',
      '모닝',
      '기타'
    ],
    '제네시스': ['G70', 'G80', 'G90', 'GV60', 'GV70', 'GV80', '기타'],
    '쉐보레': [
      '트랙스',
      '트레일블레이저',
      '이쿼녹스',
      '타호',
      '말리부',
      '스파크',
      '기타'
    ],
    '르노': ['XM3', 'QM6', 'SM6', '마스터', '기타'],
    '쌍용': ['티볼리', '코란도', '렉스턴', '토레스', '기타'],

    // Import Brands (European)
    'BMW': [
      '1시리즈',
      '2시리즈',
      '3시리즈',
      '5시리즈',
      '7시리즈',
      'X1',
      'X3',
      'X5',
      'X7',
      'i4',
      'iX',
      '기타'
    ],
    '벤츠': [
      'A클래스',
      'C클래스',
      'E클래스',
      'S클래스',
      'GLA',
      'GLC',
      'GLE',
      'GLS',
      'EQE',
      'EQS',
      '기타'
    ],
    '아우디': ['A3', 'A4', 'A6', 'Q3', 'Q5', 'Q7', 'Q8', 'e-tron', '기타'],
    '폭스바겐': ['폴로', '골프', '티구안', '투아렉', '파사트', 'ID.4', '기타'],
    '포르쉐': ['911', '718', '타이칸', '마칸', '카이엔', '기타'],
    '볼보': ['S60', 'S90', 'XC40', 'XC60', 'XC90', 'C40', '기타'],
    '미니': ['쿠퍼', '쿠퍼S', '컨트리맨', '클럽맨', '기타'],

    // Import Brands (Japanese)
    '렉서스': ['ES', 'IS', 'LS', 'NX', 'RX', 'GX', 'LX', 'UX', '기타'],
    '토요타': ['캠리', '코롤라', '프리우스', 'RAV4', '하이랜더', '기타'],
    '혼다': ['어코드', '시빅', 'CR-V', '파일럿', '기타'],
    '닛산': ['알티마', '로그', '패스파인더', 'GT-R', '기타'],
    '마쯔다': ['마쯔다2', '마쯔다3', '마쯔다6', 'CX-3', 'CX-5', 'CX-9', '기타'],

    // Import Brands (American)
    '테슬라': ['Model 3', 'Model S', 'Model X', 'Model Y', '기타'],
    '포드': ['익스플로러', '익스페디션', '머스탱', 'F-150', '기타'],
    '지프': ['랭글러', '그랜드체로키', '체로키', '컴패스', '기타'],
    '캐딜락': ['CT4', 'CT5', 'XT4', 'XT5', 'XT6', '에스컬레이드', '기타'],

    // Always last option
    '기타': ['직접 입력'],
  };

  // Get sorted manufacturer list (Korean brands first, then alphabetical)
  static List<String> getManufacturers() {
    final korean = ['현대', '기아', '제네시스', '쉐보레', '르노', '쌍용'];
    final others = manufacturersAndModels.keys
        .where((k) => !korean.contains(k) && k != '기타')
        .toList()
      ..sort();

    return [...korean, ...others, '기타'];
  }

  // Get models for a manufacturer
  static List<String>? getModels(String? manufacturer) {
    if (manufacturer == null) return null;
    return manufacturersAndModels[manufacturer];
  }
}
