import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 약관 표시 화면
class TermsScreen extends StatefulWidget {
  final String title;
  final String assetPath;

  const TermsScreen({
    super.key,
    required this.title,
    required this.assetPath,
  });

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      // HTML 파일 로드
      final String htmlContent = await rootBundle.loadString(widget.assetPath);

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                });
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
          ),
        )
        ..loadHtmlString(htmlContent);

      if (mounted) {
        setState(() {
          _controller = controller;
        });
      }
    } catch (e) {
      debugPrint('약관 로드 실패: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: _controller == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                WebViewWidget(controller: _controller!),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
    );
  }
}
