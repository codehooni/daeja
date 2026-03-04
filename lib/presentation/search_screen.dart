import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../core/database/search_history_database.dart';
import '../features/location/presentation/providers/location_providers.dart';
import '../features/parking/domain/models/parking_lot.dart';
import '../features/parking/presentation/providers/parking_providers.dart';
import '../features/parking/presentation/providers/service_providers.dart';
import '../features/parking/presentation/widgets/parking_detail_bottom_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Search state
  String _searchQuery = '';
  List<String> _recentSearches = [];

  // Filter & Sort state
  ParkingLotType? _selectedType; // null = 전체
  bool _sortByDistance = true; // true = 거리순, false = 이름순

  // Database
  final SearchHistoryDatabase _historyDb = SearchHistoryDatabase();

  // Speech to Text
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _searchController.addListener(_onSearchChanged);
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speech = stt.SpeechToText();
    _speechAvailable = await _speech.initialize(
      onError: (error) => print('음성 인식 에러: $error'),
      onStatus: (status) => print('음성 인식 상태: $status'),
    );
    setState(() {});
  }

  void _loadRecentSearches() {
    setState(() {
      _recentSearches = _historyDb.getRecentSearches();
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _speech.stop();
    super.dispose();
  }

  void _handleSearchSubmit(String query) {
    if (query.trim().isEmpty) return;
    _historyDb.addSearch(query);
    _loadRecentSearches();
    _focusNode.unfocus(); // Hide keyboard
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('음성 인식을 사용할 수 없습니다. 마이크 권한을 확인해주세요.')),
      );
      return;
    }

    setState(() => _isListening = true);

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _searchController.text = result.recognizedWords;
          _searchQuery = result.recognizedWords;
        });
      },
      localeId: 'ko_KR', // 한국어 설정
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
      ),
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);

    // 음성 입력이 완료되면 검색 실행
    if (_searchController.text.isNotEmpty) {
      _handleSearchSubmit(_searchController.text);
    }
  }

  List<ParkingLot> _getFilteredParkingLots(List<ParkingLot> allLots) {
    var filtered = allLots;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (lot) =>
                lot.name.toLowerCase().contains(query) ||
                lot.address.toLowerCase().contains(query),
          )
          .toList();
    }

    // Filter by type
    if (_selectedType != null) {
      filtered = filtered.where((lot) => lot.type == _selectedType).toList();
    }

    // Sort
    if (_sortByDistance) {
      filtered.sort(
        (a, b) => (a.distance ?? double.infinity).compareTo(
          b.distance ?? double.infinity,
        ),
      );
    } else {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: VStack([
          // Search Bar
          TextField(
            controller: _searchController,
            focusNode: _focusNode,
            onSubmitted: _handleSearchSubmit,
            decoration: InputDecoration(
              hintText: '주차장 이름, 주소 검색',
              hintStyle: TextStyle(color: Colors.grey.shade600),
              filled: true,
              fillColor: Colors.grey.shade100,
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close, color: Colors.grey.shade600),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? Colors.red : Colors.grey.shade600,
                      ),
                      onPressed: _isListening ? _stopListening : _startListening,
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ).p20(),

          // Conditional content
          if (_searchQuery.isEmpty)
            // Show recent searches
            _buildRecentList()
                .pSymmetric(h: 20, v: 10)
                .box
                .color(Colors.grey.shade100)
                .make()
          else
            // Show search results
            Expanded(
              child: _buildSearchedList()
                  .pSymmetric(h: 20, v: 10)
                  .box
                  .color(Colors.grey.shade100)
                  .make(),
            ),
        ]),
      ),
    );
  }

  Widget _buildRecentList() {
    if (_recentSearches.isEmpty) {
      return VStack([
        '최근 검색'.text.size(14).bold.make().py8(),
        40.heightBox,
        '최근 검색 기록이 없습니다'.text
            .size(14)
            .color(Colors.grey.shade500)
            .make()
            .centered(),
      ]);
    }

    return VStack([
      // Header
      HStack([
        '최근 검색'.text.size(14).bold.make(),
        const Spacer(),
        GestureDetector(
          onTap: () {
            _historyDb.clearAll();
            _loadRecentSearches();
          },
          child: '전체 삭제'.text.size(12).color(Colors.grey.shade500).make(),
        ),
      ]).py8(),

      // List items
      ...(_recentSearches.map(
        (searchTerm) => GestureDetector(
          onTap: () {
            _searchController.text = searchTerm;
            _handleSearchSubmit(searchTerm);
          },
          child: HStack([
            Icon(Icons.access_time, color: Colors.grey.shade500),
            8.widthBox,
            Expanded(
              child: searchTerm.text
                  .size(16)
                  .fontWeight(FontWeight.w500)
                  .make(),
            ),
            GestureDetector(
              onTap: () {
                _historyDb.removeSearch(searchTerm);
                _loadRecentSearches();
              },
              child: Icon(
                Icons.close,
                color: Colors.grey.shade400,
                size: 20,
              ).p4(), // Increase tap area
            ),
          ]).py8(),
        ),
      )),
    ]);
  }

  Widget _buildSearchedList() {
    final parkingLotsAsync = ref.watch(parkingLotsProvider);
    final userLocationAsync = ref.watch(userLocationProvider1);
    final distanceService = ref.watch(distanceServiceProvider);

    return parkingLotsAsync.when(
      data: (allLots) {
        // Calculate distance if user location is available
        final lotsWithDistance = userLocationAsync.maybeWhen(
          data: (userLocation) {
            return distanceService.addDistanceToLots(allLots, userLocation);
          },
          orElse: () => allLots,
        );

        final filteredLots = _getFilteredParkingLots(lotsWithDistance);

        return VStack([
          _buildSearchHeader(filteredLots.length),
          16.heightBox,
          _buildTypeChips(),
          16.heightBox,

          // Results list
          if (filteredLots.isEmpty)
            _buildEmptyState()
          else
            Expanded(
              child: ListView.builder(
                itemCount: filteredLots.length,
                itemBuilder: (context, index) {
                  return _buildParkingLotCard(
                    filteredLots[index],
                  ).pOnly(bottom: 12);
                },
              ),
            ),
        ]);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('검색 중 오류 발생: $error').text.red500.make()),
    );
  }

  Widget _buildEmptyState() {
    return VStack([
      40.heightBox,
      Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
      16.heightBox,
      '검색 결과가 없습니다'.text.size(16).color(Colors.grey.shade600).make(),
    ]).centered();
  }

  Widget _buildSearchHeader(int count) {
    return HStack([
      // Count
      HStack([
        '$count개'.text.blue700.size(16).bold.make(),
        '의 주차장'.text.black.size(16).bold.make(),
      ]),
      const Spacer(),

      // Sort toggle button
      GestureDetector(
        onTap: () {
          setState(() => _sortByDistance = !_sortByDistance);
        },
        child: HStack([
          (_sortByDistance ? '거리순' : '이름순').text
              .size(12)
              .color(Colors.grey.shade700)
              .fontWeight(FontWeight.w500)
              .make(),
          2.widthBox,
          Icon(Icons.tune, color: Colors.grey.shade600, size: 14),
        ]),
      ),
    ]);
  }

  Widget _buildTypeChips() {
    return HStack([
      _buildChip('전체', _selectedType == null, () {
        setState(() => _selectedType = null);
      }),
      _buildChip('공영', _selectedType == ParkingLotType.public, () {
        setState(() => _selectedType = ParkingLotType.public);
      }),
      _buildChip('민영', _selectedType == ParkingLotType.private, () {
        setState(() => _selectedType = ParkingLotType.private);
      }),
      _buildChip('발렛', _selectedType == ParkingLotType.valet, () {
        setState(() => _selectedType = ParkingLotType.valet);
      }),
    ]);
  }

  Widget _buildChip(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: text.text
          .size(12)
          .semiBold
          .color(isSelected ? Colors.white : Colors.grey.shade700)
          .make()
          .pSymmetric(h: 12, v: 6)
          .box
          .rounded
          .border(color: isSelected ? Colors.black : Colors.grey.shade300)
          .color(isSelected ? Colors.black : Colors.white70)
          .make()
          .pOnly(right: 8),
    );
  }

  Widget _buildParkingLotCard(ParkingLot lot) {
    return GestureDetector(
      onTap: () {
        ParkingDetailBottomSheet.show(context, lot);
      },
      child: VStack([
          // Name & Type badge
          HStack([
            Expanded(child: lot.name.text.size(16).bold.make()),
            8.widthBox,
            _buildTypeBadge(lot.type),
          ]),
          8.heightBox,

          // Address & Distance
          HStack([
            Icon(Icons.place_outlined, color: Colors.grey.shade600, size: 18),
            4.widthBox,
            Expanded(
              child: lot.address.text
                  .size(14)
                  .color(Colors.grey.shade600)
                  .make(),
            ),
            if (lot.distance != null) ...[
              8.widthBox,
              VxBox().width(2).height(10).color(Colors.grey.shade300).make(),
              8.widthBox,
              (lot.distance! >= 1.0
                      ? '${lot.distance!.toStringAsFixed(1)}km'
                      : '${(lot.distance! * 1000).toStringAsFixed(0)}m')
                  .text
                  .size(14)
                  .semiBold
                  .blue500
                  .make(),
            ],
          ]),
          16.heightBox,

          // Capacity & Fee
          HStack([
                Icon(
                  Icons.directions_car,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
                4.widthBox,
                '이용가능 ${lot.availableSpots}대'.text.size(14).make(),
                4.widthBox,
                '/ ${lot.totalSpots}대'.text
                    .size(14)
                    .color(Colors.grey.shade500)
                    .make(),
                const Spacer(),
                if (lot.fee != null)
                  '30분 ${lot.fee}원'.text.size(14).bold.make()
                else
                  '요금 정보 없음'.text.size(12).color(Colors.grey.shade400).make(),
              ])
              .pSymmetric(h: 8, v: 12)
              .box
              .roundedSM
              .color(Colors.grey.shade100)
              .make(),
        ])
        .p16()
        .box
        .rounded
        .white
        .border(color: Colors.grey.shade300)
        .shadowXs
        .make(),
    );
  }

  Widget _buildTypeBadge(ParkingLotType type) {
    final Map<ParkingLotType, Map<String, dynamic>> typeConfig = {
      ParkingLotType.public: {
        'label': '공영',
        'color': Vx.blue800,
        'bgColor': Vx.blue200,
      },
      ParkingLotType.private: {
        'label': '민영',
        'color': Vx.green800,
        'bgColor': Vx.green200,
      },
      ParkingLotType.valet: {
        'label': '발렛',
        'color': Vx.purple800,
        'bgColor': Vx.purple200,
      },
    };

    final config = typeConfig[type]!;
    return config['label']
        .toString()
        .text
        .size(12)
        .color(config['color'] as Color)
        .semiBold
        .make()
        .pSymmetric(h: 8)
        .box
        .roundedSM
        .color((config['bgColor'] as Color).withAlpha(100))
        .border(color: config['bgColor'] as Color)
        .make();
  }
}
