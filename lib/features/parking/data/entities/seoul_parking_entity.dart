// {
//         "PKLT_CD": "171721",
//         "PKLT_NM": "세종로 공영주차장(시)",
//         "ADDR": "종로구 세종로 80-1",
//         "PKLT_TYPE": "NW",
//         "PRK_TYPE_NM": "노외 주차장",
//         "OPER_SE": "1",
//         "OPER_SE_NM": "시간제 주차장",
//         "TELNO": "02-2290-6566",
//         "PRK_STTS_YN": "1",
//         "PRK_STTS_NM": "현재~20분이내 연계데이터 존재(현재 주차대수 표현)",
//         "TPKCT": 1260,
//         "NOW_PRK_VHCL_CNT": 376,
//         "NOW_PRK_VHCL_UPDT_TM": "2025-12-13 15:24:30",
//         "PAY_YN": "Y",
//         "PAY_YN_NM": "유료",
//         "NGHT_PAY_YN": "N",
//         "NGHT_PAY_YN_NM": "야간 미개방",
//         "WD_OPER_BGNG_TM": "0000",
//         "WD_OPER_END_TM": "2400",
//         "WE_OPER_BGNG_TM": "0000",
//         "WE_OPER_END_TM": "2400",
//         "LHLDY_OPER_BGNG_TM": "0000",
//         "LHLDY_OPER_END_TM": "2400",
//         "SAT_CHGD_FREE_SE": "N",
//         "SAT_CHGD_FREE_NM": "무료",
//         "LHLDY_CHGD_FREE_SE": "N",
//         "LHLDY_CHGD_FREE_SE_NAME": "무료",
//         "PRD_AMT": "176000",
//         "STRT_PKLT_MNG_NO": "",
//         "BSC_PRK_CRG": 430,
//         "BSC_PRK_HR": 5,
//         "ADD_PRK_CRG": 430,
//         "ADD_PRK_HR": 5,
//         "BUS_BSC_PRK_CRG": 0,
//         "BUS_BSC_PRK_HR": 0,
//         "BUS_ADD_PRK_HR": 0,
//         "BUS_ADD_PRK_CRG": 0,
//         "DAY_MAX_CRG": 30900,
//         "SHRN_PKLT_MNG_NM": "*",
//         "SHRN_PKLT_MNG_URL": "*",
//         "SHRN_PKLT_YN": "N",
//         "SHRN_PKLT_ETC": "*"
//       },
class SeoulParkingEntity {
  final String pkltCd; // 주차장 코드
  final String pkltNm; // 주차장명
  final String addr; // 주소
  final String pkltType; // 주차장 타입 코드
  final String prkTypeNm; // 주차장 타입명 (노외/노상)
  final String operSe; // 운영 구분 코드
  final String operSeNm; // 운영 구분명 (시간제 등)
  final String telno; // 전화번호
  final String prkSttsYn; // 주차 상태 여부
  final String prkSttsNm; // 주차 상태 설명
  final int tpkct; // 총 주차면수
  final int nowPrkVhclCnt; // 현재 주차 차량 수
  final String nowPrkVhclUpdtTm; // 현재 주차 업데이트 시간
  final String payYn; // 유료 여부
  final String payYnNm; // 유료 여부명
  final String nghtPayYn; // 야간 개방 여부
  final String nghtPayYnNm; // 야간 개방 여부명
  final String wdOperBgngTm; // 평일 운영 시작
  final String wdOperEndTm; // 평일 운영 종료
  final String weOperBgngTm; // 주말 운영 시작
  final String weOperEndTm; // 주말 운영 종료
  final String lhldyOperBgngTm; // 공휴일 운영 시작
  final String lhldyOperEndTm; // 공휴일 운영 종료
  final String satChgdFreeSe; // 토요일 유무료 코드
  final String satChgdFreeNm; // 토요일 유무료명
  final String lhldyChgdFreeSe; // 공휴일 유무료 코드
  final String lhldyChgdFreeSeName; // 공휴일 유무료명
  final String prdAmt; // 정기권 금액
  final int bscPrkCrg; // 기본 주차 요금
  final int bscPrkHr; // 기본 주차 시간(분)
  final int addPrkCrg; // 추가 주차 요금
  final int addPrkHr; // 추가 주차 시간(분)
  final int busBscPrkCrg; // 버스 기본 요금
  final int busBscPrkHr; // 버스 기본 시간
  final int busAddPrkHr; // 버스 추가 시간
  final int busAddPrkCrg; // 버스 추가 요금
  final int dayMaxCrg; // 일 최대 요금
  final String shrnPkltYn; // 공유 주차장 여부

  SeoulParkingEntity({
    required this.pkltCd,
    required this.pkltNm,
    required this.addr,
    required this.pkltType,
    required this.prkTypeNm,
    required this.operSe,
    required this.operSeNm,
    required this.telno,
    required this.prkSttsYn,
    required this.prkSttsNm,
    required this.tpkct,
    required this.nowPrkVhclCnt,
    required this.nowPrkVhclUpdtTm,
    required this.payYn,
    required this.payYnNm,
    required this.nghtPayYn,
    required this.nghtPayYnNm,
    required this.wdOperBgngTm,
    required this.wdOperEndTm,
    required this.weOperBgngTm,
    required this.weOperEndTm,
    required this.lhldyOperBgngTm,
    required this.lhldyOperEndTm,
    required this.satChgdFreeSe,
    required this.satChgdFreeNm,
    required this.lhldyChgdFreeSe,
    required this.lhldyChgdFreeSeName,
    required this.prdAmt,
    required this.bscPrkCrg,
    required this.bscPrkHr,
    required this.addPrkCrg,
    required this.addPrkHr,
    required this.busBscPrkCrg,
    required this.busBscPrkHr,
    required this.busAddPrkHr,
    required this.busAddPrkCrg,
    required this.dayMaxCrg,
    required this.shrnPkltYn,
  });

  factory SeoulParkingEntity.fromJson(Map<String, dynamic> json) {
    return SeoulParkingEntity(
      pkltCd: json['PKLT_CD']?.toString() ?? '',
      pkltNm: json['PKLT_NM']?.toString() ?? '',
      addr: json['ADDR']?.toString() ?? '',
      pkltType: json['PKLT_TYPE']?.toString() ?? '',
      prkTypeNm: json['PRK_TYPE_NM']?.toString() ?? '',
      operSe: json['OPER_SE']?.toString() ?? '',
      operSeNm: json['OPER_SE_NM']?.toString() ?? '',
      telno: json['TELNO']?.toString() ?? '',
      prkSttsYn: json['PRK_STTS_YN']?.toString() ?? '',
      prkSttsNm: json['PRK_STTS_NM']?.toString() ?? '',
      tpkct: json['TPKCT'] ?? 0,
      nowPrkVhclCnt: json['NOW_PRK_VHCL_CNT'] ?? 0,
      nowPrkVhclUpdtTm: json['NOW_PRK_VHCL_UPDT_TM']?.toString() ?? '',
      payYn: json['PAY_YN']?.toString() ?? '',
      payYnNm: json['PAY_YN_NM']?.toString() ?? '',
      nghtPayYn: json['NGHT_PAY_YN']?.toString() ?? '',
      nghtPayYnNm: json['NGHT_PAY_YN_NM']?.toString() ?? '',
      wdOperBgngTm: json['WD_OPER_BGNG_TM']?.toString() ?? '',
      wdOperEndTm: json['WD_OPER_END_TM']?.toString() ?? '',
      weOperBgngTm: json['WE_OPER_BGNG_TM']?.toString() ?? '',
      weOperEndTm: json['WE_OPER_END_TM']?.toString() ?? '',
      lhldyOperBgngTm: json['LHLDY_OPER_BGNG_TM']?.toString() ?? '',
      lhldyOperEndTm: json['LHLDY_OPER_END_TM']?.toString() ?? '',
      satChgdFreeSe: json['SAT_CHGD_FREE_SE']?.toString() ?? '',
      satChgdFreeNm: json['SAT_CHGD_FREE_NM']?.toString() ?? '',
      lhldyChgdFreeSe: json['LHLDY_CHGD_FREE_SE']?.toString() ?? '',
      lhldyChgdFreeSeName: json['LHLDY_CHGD_FREE_SE_NAME']?.toString() ?? '',
      prdAmt: json['PRD_AMT']?.toString() ?? '',
      bscPrkCrg: json['BSC_PRK_CRG'] ?? 0,
      bscPrkHr: json['BSC_PRK_HR'] ?? 0,
      addPrkCrg: json['ADD_PRK_CRG'] ?? 0,
      addPrkHr: json['ADD_PRK_HR'] ?? 0,
      busBscPrkCrg: json['BUS_BSC_PRK_CRG'] ?? 0,
      busBscPrkHr: json['BUS_BSC_PRK_HR'] ?? 0,
      busAddPrkHr: json['BUS_ADD_PRK_HR'] ?? 0,
      busAddPrkCrg: json['BUS_ADD_PRK_CRG'] ?? 0,
      dayMaxCrg: json['DAY_MAX_CRG'] ?? 0,
      shrnPkltYn: json['SHRN_PKLT_YN']?.toString() ?? '',
    );
  }
}
