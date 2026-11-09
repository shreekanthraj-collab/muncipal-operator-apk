import 'package:flutter_test/flutter_test.dart';
import 'package:muncipal_operator_apk/main.dart';

void main() {
  testWidgets('operator app starts with role selection login', (tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Agent / Operator'), findsOneWidget);
    expect(find.text('REQUEST OTP'), findsOneWidget);
    expect(find.textContaining('Phone / mobile change'), findsOneWidget);
  });
}
