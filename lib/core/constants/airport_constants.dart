class AirportParkingInfo {
  final double lat;
  final double lng;
  final String address;

  const AirportParkingInfo({
    required this.lat,
    required this.lng,
    required this.address,
  });
}

class AirportConstants {
  static const Map<String, AirportParkingInfo> parkingLots = {
    // 제주국제공항
    '제주국제공항_P1주차장': AirportParkingInfo(
      lat: 33.5050521,
      lng: 126.4934536,
      address: '제주특별자치도 제주시 공항로 2 (P1 주차장)',
    ),
    '제주국제공항_P2장기주차장': AirportParkingInfo(
      lat: 33.5027973,
      lng: 126.4905564,
      address: '제주특별자치도 제주시 공항로 2 (P2 장기주차장)',
    ),
    '제주국제공항_화물주차장': AirportParkingInfo(
      lat: 33.5068259,
      lng: 126.4995465,
      address: '제주특별자치도 제주시 용담2동 2254 (화물주차장)',
    ),

    // 김포국제공항
    '김포국제공항_국내선 제1주차장': AirportParkingInfo(
      lat: 37.559914,
      lng: 126.804517,
      address: '서울 강서구 하늘길 111 (국내선 제1주차장)',
    ),
    '김포국제공항_국내선 제2주차장': AirportParkingInfo(
      lat: 37.558107,
      lng: 126.807377,
      address: '서울 강서구 공항동 80-7 (국내선 제2주차장)',
    ),
    '김포국제공항_국제선 주차빌딩': AirportParkingInfo(
      lat: 37.564670,
      lng: 126.799639,
      address: '서울 강서구 하늘길 77 (국제선 주차빌딩)',
    ),
    '김포국제공항_국제선 지하': AirportParkingInfo(
      lat: 37.564943,
      lng: 126.802141,
      address: '서울 강서구 방화동 (국제선 지하)',
    ),
    '김포국제공항_화물청사': AirportParkingInfo(
      lat: 37.555228,
      lng: 126.808120,
      address: '서울 강서구 하늘길 170-1 AAS정비동 (화물청사)',
    ),

    // 김해국제공항
    '김해국제공항_P1 여객주차장': AirportParkingInfo(
      lat: 35.171435,
      lng: 128.950050,
      address: '부산 강서구 대저1동 2 (P1 여객주차장)',
    ),
    '김해국제공항_P2 여객주차장': AirportParkingInfo(
      lat: 35.173713,
      lng: 128.948814,
      address: '부산 강서구 대저1동 2 (P2 여객주차장)',
    ),
    '김해국제공항_P3 여객(화물)': AirportParkingInfo(
      lat: 35.178474,
      lng: 128.949743,
      address: '부산 강서구 대저2동 2148 (P3 여객(화물))',
    ),

    // 대구국제공항
    '대구국제공항_여객주차장': AirportParkingInfo(
      lat: 35.899895,
      lng: 128.637549,
      address: '대구 동구 공항로 221 대구공항 여객주차장',
    ),
    '대구국제공항_화물주차장': AirportParkingInfo(
      lat: 35.898696,
      lng: 128.639861,
      address: '대구 동구 공항로 221 대구국제공항 (화물주차장)',
    ),

    // 광주공항
    '광주공항_여객주차장(제1+제2)': AirportParkingInfo(
      lat: 35.140674,
      lng: 126.810049,
      address: '광주 광산구 상무대로 420-25 광주공항 (여객주차장(제1+제2))',
    ),

    // 여수공항
    '여수공항_여객주차장': AirportParkingInfo(
      lat: 34.840114,
      lng: 127.613235,
      address: '전남 여수시 율촌면 신풍리 568-1 (여객주차장)',
    ),

    // 울산공항
    '울산공항_여객주차장': AirportParkingInfo(
      lat: 35.593441,
      lng: 129.357183,
      address: '울산 북구 산업로 1103 (여객주차장)',
    ),

    // 군산공항
    '군산공항_여객주차장': AirportParkingInfo(
      lat: 35.926776,
      lng: 126.615734,
      address: '전북 군산시 옥서면 산동길 2 (여객주차장)',
    ),

    // 원주공항
    '원주공항_여객주차장': AirportParkingInfo(
      lat: 37.458804,
      lng: 127.977348,
      address: '강원 횡성군 횡성읍 횡성로 38 (여객주차장)',
    ),

    // 청주국제공항
    '청주국제공항_여객 제1주차장': AirportParkingInfo(
      lat: 36.722782,
      lng: 127.495283,
      address: '충북 청주시 청원구 내수읍 오창대로 980 (제1주차장)',
    ),
    '청주국제공항_여객 제2주차장': AirportParkingInfo(
      lat: 36.722598,
      lng: 127.492857,
      address: '충북 청주시 청원구 내수읍 오창대로 980 청주국제공항 제 2 여객주차장',
    ),
    '청주국제공항_여객 제3주차장': AirportParkingInfo(
      lat: 36.724971,
      lng: 127.498504,
      address: '충북 청주시 청원구 내수읍 오창대로 980 (제3주차장)',
    ),
    '청주국제공항_여객 제4주차장': AirportParkingInfo(
      lat: 36.724863,
      lng: 127.500016,
      address: '충북 청주시 청원구 내수읍 오창대로 980 (제4주차장)',
    ),

    // 무안국제공항
    '무안국제공항_여객주차장': AirportParkingInfo(
      lat: 34.992682,
      lng: 126.389632,
      address: '전남 무안군 망운면 피서리 1067-1 (여객주차장)',
    ),

    // 사천공항
    '사천공항_여객주차장': AirportParkingInfo(
      lat: 35.088590,
      lng: 128.070320,
      address: '경남 사천시 사천읍 사천대로 1971 (여객주차장)',
    ),

    // 양양국제공항
    '양양국제공항_여객주차장': AirportParkingInfo(
      lat: 38.058092,
      lng: 128.661886,
      address: '강원 양양군 손양면 동호리 547 (여객주차장)',
    ),
  };
}
