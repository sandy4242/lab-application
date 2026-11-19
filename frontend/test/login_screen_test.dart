import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:relab_frontend/providers/auth_provider.dart';
import 'package:relab_frontend/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen renders with mobile dimensions (375.4 x 834.5)', (tester) async {
    tester.view.devicePixelRatio = 3.3;
    tester.view.physicalSize = const Size(375.4 * 3.3, 834.5 * 3.3);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final auth = AuthProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Demo Accounts'), findsOneWidget);

    // Tap on another chip
    await tester.tap(find.text('Teacher Guardian'));
    await tester.pumpAndSettle();

    expect(find.text('Dr. Ananya Sen'), findsOneWidget);

    // Tap Sign In button
    await tester.tap(find.text('Sign In'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    print('LOGIN SCREEN INTERACTION TEST PASSED!');
  });
}
