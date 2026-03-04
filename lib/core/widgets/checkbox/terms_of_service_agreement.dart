import 'package:daeja/core/utils/url_utils.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class TermsOfServiceAgreement extends StatefulWidget {
  final void Function(bool isValid)? onTermsChanged;

  const TermsOfServiceAgreement({
    super.key,
    this.onTermsChanged,
  });

  @override
  State<TermsOfServiceAgreement> createState() =>
      _TermsOfServiceAgreementState();
}

class _TermsOfServiceAgreementState extends State<TermsOfServiceAgreement> {
  // 약관 변경시 변경
  List<bool> _isChecked = List.generate(3, (_) => false);

  bool get _buttonActive => _isChecked[1] && _isChecked[2];

  void _updateCheckState(int index) {
    setState(() {
      // 모두 동의 체크박스일 경우
      if (index == 0) {
        bool isAllChecked = !_isChecked.every((element) => element);
        _isChecked = List.generate(4, (index) => isAllChecked);
      } else {
        _isChecked[index] = !_isChecked[index];
        _isChecked[0] = _isChecked
            .getRange(1, 3)
            .every((element) => element); // 약관 변경시 변경
      }
    });

    // Notify parent of validation state
    widget.onTermsChanged?.call(_buttonActive);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _renderCheckList(),
    );
  }

  List<Widget> _renderCheckList() {
    // 약관 변경시 변경
    List<String> labels = [
      '약관 전체 동의',
      '이용약관 동의 (필수)',
      '개인정보 처리방침 동의 (필수)',
      // '마케팅 수신 동의 (선택)',
    ];

    // URL list for each checkbox
    List<String?> urls = [
      null, // No URL for "전체 동의"
      UrlUtils.termsOfServiceUrl,
      UrlUtils.privacyPolicyUrl,
    ];

    List<Widget> list = [
      renderAllContainer(_isChecked[0], labels[0], () => _updateCheckState(0)),
      SizedBox(height: 12),
    ];

    list.addAll(
      List.generate(
        2, // 약관 변경시 변경
        (index) => renderContainer(
          _isChecked[index + 1],
          labels[index + 1],
          () => _updateCheckState(index + 1),
          urls[index + 1], // Pass URL parameter
        ),
      ),
    );

    return list;
  }

  Widget renderAllContainer(bool checked, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child:
          Row(
                children: [
                  Icon(Icons.check, color: Colors.white, size: 18)
                      .p(4)
                      .box
                      .roundedFull
                      .border(
                        color: checked ? Colors.blue : Colors.grey.shade500,
                      )
                      .color(checked ? Colors.blue : Colors.white)
                      .make(),
                  const SizedBox(width: 12),
                  text.text.size(18).fontWeight(FontWeight.w800).make(),
                ],
              )
              .pSymmetric(h: 18, v: 18)
              .box
              .rounded
              .border(color: Colors.grey.shade300)
              .color(Colors.grey.shade50)
              .make(),
    );
  }

  Widget renderContainer(
    bool checked,
    String text,
    VoidCallback onTap,
    String? url, // Add URL parameter
  ) {
    return GestureDetector(
      onTap: onTap, // Checkbox toggle
      child: Row(
        children: [
          Icon(Icons.check, color: Colors.white, size: 18)
              .p(2)
              .box
              .roundedSM
              .border(color: checked ? Colors.blue : Colors.grey.shade500)
              .color(checked ? Colors.blue : Colors.white)
              .make(),
          const SizedBox(width: 12),
          text.text.size(14).color(Colors.grey.shade800).make(),
          Spacer(),
          if (url != null) // Show arrow only if URL exists
            GestureDetector(
              onTap: () => UrlUtils.openUrl(context, url), // Open URL
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Larger tap target
                child: Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
              ),
            ),
        ],
      ).p(12).box.make(),
    );
  }
}
