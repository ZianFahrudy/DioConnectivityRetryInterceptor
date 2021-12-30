import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';

class DioConnectivityRequestRetrier {
  final Dio dio;
  final Connectivity connectivity;
  DioConnectivityRequestRetrier({
    required this.dio,
    required this.connectivity,
  });

  Future<Response> scheduleRequestRetry(RequestOptions requestOptions) async {
    late StreamSubscription streamSubscription;

    final responseCompleter = Completer<Response>();

    streamSubscription = connectivity.onConnectivityChanged.listen(
      (connectivitityResult) {
        if (connectivitityResult != ConnectivityResult.none) {
          streamSubscription.cancel();

          responseCompleter.complete(
            dio.fetch(requestOptions),
          );
        }
      },
    );

    return responseCompleter.future;
  }
}
