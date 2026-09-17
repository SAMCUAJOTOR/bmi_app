import 'package:bmi_management_system/widgets/common/connectivity_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ConnectivityBanner does not assert when used as the app home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ConnectivityBanner(
          child: const Scaffold(
            body: Center(child: Text('Home')),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
