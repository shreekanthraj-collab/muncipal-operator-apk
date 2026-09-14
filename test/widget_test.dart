import 'package:flutter_test/flutter_test.dart';
import 'package:muncipal_operator_apk/main.dart';

void main() {
  testWidgets('operator app starts at login page', (tester) async {
    await tester.pumpWidget(const MunicipalOperatorApp());

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Admin'), findsNothing);
    expect(find.text('Agent / Operator'), findsOneWidget);
  });
}
