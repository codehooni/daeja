import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../core/constants/vehicle_constants.dart';
import '../../domain/models/vehicle.dart';
import '../providers/user_provider.dart';

class VehicleAddScreen extends ConsumerStatefulWidget {
  const VehicleAddScreen({super.key});

  @override
  ConsumerState<VehicleAddScreen> createState() => _VehicleAddScreenState();
}

class _VehicleAddScreenState extends ConsumerState<VehicleAddScreen> {
  final _plateNumberController = TextEditingController();
  String? _selectedColor;
  String? _selectedManufacturer;
  String? _selectedModel;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _vehicleColors = [
    {'name': '흰색', 'color': Colors.white},
    {'name': '검정', 'color': Colors.black},
    {'name': '은색', 'color': Colors.grey.shade400},
    {'name': '회색', 'color': Colors.grey.shade700},
    {'name': '빨강', 'color': Colors.red},
    {'name': '파랑', 'color': Colors.blue},
    {'name': '갈색', 'color': Colors.brown},
    {'name': '기타', 'color': Colors.grey.shade300},
  ];

  @override
  void dispose() {
    _plateNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    // Validate plate number (required field)
    final plateNumber = _plateNumberController.text.trim();
    if (plateNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('차량 번호를 입력해주세요'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Create vehicle object
      final vehicle = Vehicle(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        plateNumber: plateNumber,
        manufacturer: _selectedManufacturer,
        model: _selectedModel,
        color: _selectedColor,
        type: VehicleType.sedan, // Default type
      );

      // Add vehicle via provider
      await ref.read(userProvider.notifier).addVehicle(vehicle);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('차량이 등록되었습니다'), backgroundColor: Colors.green),
        );

        // Navigate back
        Navigator.pop(context);
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('차량 등록에 실패했습니다: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: '차량 추가'.text.size(20).bold.make(),
        actions: [
          GestureDetector(
            onTap: _isSaving ? null : _handleSave,
            child: (_isSaving ? '저장 중...' : '저장').text
                .size(16)
                .color(_isSaving ? Colors.grey : Colors.blue)
                .bold
                .make()
                .pOnly(right: 16),
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 차량 번호
              _buildNumber(),
              SizedBox(height: 16),

              // 제조사
              _buildManufacturer(),
              SizedBox(height: 16),

              // 모델명
              _buildModel(),
              SizedBox(height: 16),

              // 색상
              _buildColor(),
              SizedBox(height: 16),
            ],
          ).p(16),
        ),
      ),
    );
  }

  Widget _buildNumber() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            '차량 번호 '.text.size(16).bold.make(),
            '*'.text.size(18).color(Colors.red).make(),
          ],
        ),
        SizedBox(height: 8),
        TextField(
          controller: _plateNumberController,
          cursorColor: Colors.blue,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(),
            focusColor: Colors.blue,
            hintText: '차량 번호를 입력하세요',
            hintStyle: TextStyle(color: Colors.grey.shade400),
          ),
        ),
        SizedBox(height: 8),
        '예: 12가 3456, 서울12가 3456'.text
            .size(12)
            .color(Colors.grey.shade700)
            .make(),
      ],
    );
  }

  Widget _buildManufacturer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        '제조사'.text.size(16).bold.make(),
        SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedManufacturer,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintText: '제조사를 선택하세요',
              hintStyle: TextStyle(color: Colors.grey.shade600),
            ),
            isExpanded: true,
            items: VehicleConstants.getManufacturers().map((manufacturer) {
              return DropdownMenuItem(
                value: manufacturer,
                child: Text(manufacturer),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedManufacturer = value;
                _selectedModel = null; // Reset model when manufacturer changes
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModel() {
    final models = VehicleConstants.getModels(_selectedManufacturer);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        '모델명'.text.size(16).bold.make(),
        SizedBox(height: 8),

        if (_selectedManufacturer == null)
          // Placeholder when no manufacturer selected
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: '제조사를 먼저 선택해주세요'.text
                  .size(14)
                  .color(Colors.grey.shade600)
                  .make(),
            ),
          )
        else
          // Dropdown when manufacturer is selected
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedModel,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                hintText: '모델을 선택하세요',
                hintStyle: TextStyle(color: Colors.grey.shade600),
              ),
              isExpanded: true,
              items: models?.map((model) {
                return DropdownMenuItem(value: model, child: Text(model));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedModel = value;
                });
              },
            ),
          ),
      ],
    );
  }

  Widget _buildColor() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        '차량 색상'.text.size(16).bold.make(),
        SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: _vehicleColors.length,
          itemBuilder: (context, index) {
            final colorData = _vehicleColors[index];
            final colorName = colorData['name'] as String;
            final color = colorData['color'] as Color;
            final isSelected = _selectedColor == colorName;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = colorName;
                });
              },
              child: _buildColorContainer(color, colorName, isSelected),
            );
          },
        ),
      ],
    );
  }

  Widget _buildColorContainer(Color color, String text, bool isSelected) {
    return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 색상 원
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
            ),

            SizedBox(height: 4),

            // 색상 이름
            text.text
                .size(11)
                .color(isSelected ? Colors.black : Colors.grey.shade600)
                .fontWeight(isSelected ? FontWeight.bold : FontWeight.normal)
                .make(),
          ],
        )
        .pSymmetric(v: 4)
        .box
        .rounded
        .border(color: isSelected ? Colors.blue : Colors.transparent, width: 2)
        .color(Colors.white)
        .make();
  }
}
