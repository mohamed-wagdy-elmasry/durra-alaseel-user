import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../base/api/services/basic_services.dart';
import '../../../../base/utils/basic_import.dart';
import '../../../../languages/locale_service.dart';

class WebViewScreen extends StatefulWidget {
  final String title;
  final bool useAssets;

  WebViewScreen({
    super.key,
    required this.title,
    this.useAssets = true,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late InAppWebViewController webViewController;
  String? _content;

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      if (widget.useAssets) {
        // Load from asset HTML files based on current locale
        final assetPath = _getAssetPath(widget.title);
        _content = await rootBundle.loadString(assetPath);
      } else {
        // Fallback to URL-based loading from API
        final url = _getUrl(widget.title);
        if (url.isNotEmpty) {
          _content = url;
        }
      }
    } catch (e) {
      print('Error loading content: $e');
      _content = null;
    } finally {
      isLoading.value = false;
    }
  }

  String _getAssetPath(String title) {
    final lang = LocaleService.to.currentLocale.languageCode;
    final suffix = lang.startsWith('ar') ? 'ar' : 'en';
    
    switch (title) {
      case Strings.privacyPolicy:
        return 'assets/html/privacy-policy-$suffix.html';
      case Strings.contactUs:
        return 'assets/html/contact-us-$suffix.html';
      case Strings.aboutUs:
        return 'assets/html/about-us-$suffix.html';
      default:
        return 'assets/html/privacy-policy-$suffix.html';
    }
  }

  String _getUrl(String title) {
    var url = '';
    switch (title) {
      case Strings.privacyPolicy:
        url = BasicServices.privacyPolicy.value;
        break;
      case Strings.aboutUs:
        url = BasicServices.aboutUs.value;
        break;
      case Strings.contactUs:
        url = BasicServices.contactUs.value;
        break;
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        widget.title,
        centerTitle: false,
      ),
      body: _bodyWidget(context),
    );
  }

  Widget _bodyWidget(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoading,
      builder: (context, loading, _) {
        if (loading) {
          return Center(child: Loader());
        }

        if (_content == null || _content!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('Unable to load content'),
              ],
            ),
          );
        }

        // If content is asset-based HTML, use InAppWebView to render
        if (widget.useAssets) {
          return InAppWebView(
            initialData: InAppWebViewInitialData(data: _content!),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                javaScriptEnabled: true,
                useShouldOverrideUrlLoading: true,
              ),
            ),
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              return await _handleNavigationAction(navigationAction);
            },
          );
        }

        // Otherwise load from URL
        return InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(_content!)),
          onWebViewCreated: (controller) {
            webViewController = controller;
            controller.addJavaScriptHandler(
              handlerName: 'jsHandler',
              callback: (args) {},
            );
          },
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              javaScriptEnabled: true,
              useShouldOverrideUrlLoading: true,
            ),
          ),
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            return await _handleNavigationAction(navigationAction);
          },
        );
      },
    );
  }

  Future<NavigationActionPolicy> _handleNavigationAction(
      NavigationAction navigationAction) async {
    final uri = navigationAction.request.url;
    if (uri == null) return NavigationActionPolicy.CANCEL;

    final uriString = uri.toString();
    final scheme = uri.scheme.toLowerCase();

    // Handle telephone, email, sms, whatsapp
    if (scheme == 'tel' ||
        scheme == 'mailto' ||
        scheme == 'sms' ||
        uriString.startsWith('https://wa.me/') ||
        uriString.startsWith('whatsapp://')) {
      try {
        final parsedUri = Uri.parse(uriString);
        await launchUrl(parsedUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('Could not launch $uriString: $e');
      }
      return NavigationActionPolicy.CANCEL;
    }

    // For asset-based content, any web link (http/https) should open in external browser
    if (widget.useAssets && (scheme == 'http' || scheme == 'https')) {
      try {
        final parsedUri = Uri.parse(uriString);
        await launchUrl(parsedUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('Could not launch external URL $uriString: $e');
      }
      return NavigationActionPolicy.CANCEL;
    }

    return NavigationActionPolicy.ALLOW;
  }
}
