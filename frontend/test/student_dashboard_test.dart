import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:relab_frontend/providers/auth_provider.dart';
import 'package:relab_frontend/screens/student_dashboard.dart';
import 'package:relab_frontend/services/mock_data_service.dart';

void main() {
  testWidgets('StudentDashboard renders with mobile dimensions (375.4 x 738.5)', (tester) async {
    tester.view.physicalSize = const Size(375.4, 738.5);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final auth = AuthProvider();
    final dataService = MockDataService();

    final signInFuture = auth.signIn('student@relab.com', 'password123');
    await tester.pump(const Duration(milliseconds: 300));
    await signInFuture;

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(
          home: StudentDashboard(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('Student Portal'), findsOneWidget);
    print('MOBILE DIMENSIONS TEST PASSED!');
  });
}
