import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:dio_connectivity_retry_interceptor/interceptor/dio_connectivity_request_retry.dart';
import 'package:dio_connectivity_retry_interceptor/interceptor/retry_interceptor.dart';
import 'package:flutter/material.dart';

void main() {
  // HttpOverrides.global = MyHttpOverrides();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Dio Connectivity Retry Interceptor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late String firstPostTitle;
  late bool isLoading;

  final dio = Dio();

  @override
  void initState() {
    super.initState();

    firstPostTitle = 'Press the Button';
    isLoading = false;

    dio.interceptors.add(RetryOnConnectionChangeInterceptor(
        requestRetrier: DioConnectivityRequestRetrier(
            dio: dio, connectivity: Connectivity())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (isLoading)
              const CircularProgressIndicator()
            else
              Text(firstPostTitle),
            ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });

                  final response = await dio
                      .get('https://jsonplaceholder.typicode.com/posts');

                  setState(() {
                    firstPostTitle = response.data[0]['title'] as String;
                    isLoading = false;
                  });
                },
                child: const Text('GET DATA'))
          ],
        ),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
