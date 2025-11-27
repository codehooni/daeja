import 'package:flutter/material.dart';

class ValetBadge extends StatelessWidget {
  const ValetBadge({super.key});

  @override
  Widget build(BuildContext context) {
    // 테마에 따라 색상 변경
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 라이트 모드: 밝은 오렌지-골드, 다크 모드: 밝은 골드
    final valetColor = isDarkMode
        ? const Color(0xFFFFD700) // 밝은 골드 (다크 모드)
        : const Color(0xFFF59E0B); // 밝은 오렌지-골드 (라이트 모드)

    // 투명도 설정
    final bgOpacity = isDarkMode ? 0.2 : 0.12;
    final borderOpacity = isDarkMode ? 0.6 : 0.8;
    final contentOpacity = isDarkMode ? 0.95 : 1.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: valetColor.withOpacity(bgOpacity),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: valetColor.withOpacity(borderOpacity),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.key,
            size: 14,
            color: valetColor.withOpacity(contentOpacity),
          ),
          SizedBox(width: 5),
          Text(
            'VALET',
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: valetColor.withOpacity(contentOpacity),
            ),
          ),
        ],
      ),
    );
  }
}
