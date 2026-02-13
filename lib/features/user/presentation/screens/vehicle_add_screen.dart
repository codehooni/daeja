import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class VehicleEditScreen extends StatefulWidget {
  const VehicleEditScreen({super.key});

  @override
  State<VehicleEditScreen> createState() => _VehicleEditScreenState();
}

class _VehicleEditScreenState extends State<VehicleEditScreen> {
  String? _selectedColor;

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: '차량 수정'.text.size(20).bold.make(),
        actions: [
          '저장'.text.size(16).color(Colors.blue).bold.make().pOnly(right: 16),
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

              // Divider
              Divider(color: Colors.grey.shade200),
              SizedBox(height: 16),

              // delete button
              _buildDelete(),
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
          cursorColor: Colors.blue,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(),
            focusColor: Colors.blue,
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

        // todo 제조사 선택 (하드코딩)
      ],
    );
  }

  Widget _buildModel() {
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
          cursorColor: Colors.blue,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(),
            focusColor: Colors.blue,
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

  Widget _buildDelete() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Icon(Icons.delete_outline, color: Colors.redAccent),
          SizedBox(width: 8),

          // Text
          '차량 삭제'.text.size(16).color(Colors.redAccent).make(),
        ],
      ).pSymmetric(v: 8).box.roundedSM.color(Vx.red100).make(),
    );
  }
}
