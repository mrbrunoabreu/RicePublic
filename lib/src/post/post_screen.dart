import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rice/src/post/index.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../base_bloc.dart';
import '../utils.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({
    Key? key,
    required String postId,
    required PostBloc postBloc,
  })  : _postBloc = postBloc,
        _postId = postId,
        super(key: key);

  final PostBloc _postBloc;
  final String _postId;

  @override
  PostScreenState createState() {
    return PostScreenState(_postBloc, _postId);
  }
}

class PostScreenState extends State<PostScreen> {
  final PostBloc _postBloc;
  final String _postId;
  PostScreenState(this._postBloc, this._postId);

  final Completer<WebViewController> _webViewController =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    this._load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
        bloc: widget._postBloc,
        builder: (
          BuildContext context,
          PostState currentState,
        ) =>
            BaseBloc.widgetBlocBuilderDecorator(context, currentState,
                builder: (
              BuildContext context,
              PostState currentState,
            ) {
              if (currentState is ErrorPostState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ackAlert(context, currentState.errorMessage);
                });
              }

              if (currentState is InPostState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _loadUrl(currentState.post.url);
                  //_loadHtml(currentState.post.html);
                });
              }
              return Scaffold(
                  appBar: _appBar() as PreferredSizeWidget?, body: _body());
            }));
  }

  //region Widget --------------------------------------------------------------
  Widget _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  // Adicionado

  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://www.youtube.com/')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse('https://flutter.dev'));

  // Adicionado

  Widget _body() {
    return WebViewWidget(controller: controller);
    // return WebView(
    //   initialUrl: "about:blank",
    //   onWebViewCreated: (WebViewController webViewController) =>
    //       _webViewController.complete(webViewController),
    //   javascriptMode: JavascriptMode.unrestricted,
    // );
  }
  //endregion

  //region Private -------------------------------------------------------------
  void _load([bool isError = false]) {
    widget._postBloc.add(LoadPostEvent(isError, _postId));
  }

// Modificado

  _loadUrl(String? url) async {
    final parsedUrl = Uri.parse(url!);
    _webViewController.future
        .then((webViewController) => webViewController.loadRequest(parsedUrl));
  }

  /// Load html from string
  _loadHtml(String html) async {
    _webViewController.future.then((webViewController) =>
        webViewController.loadRequest(Uri.dataFromString(html,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))));
  }
  //endregion
}
