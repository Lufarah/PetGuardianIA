import 'package:flutter_test/flutter_test.dart';
import 'package:petguardia_ai/main.dart';

void main() {
  testWidgets('shows Firebase configuration error when Firebase is unavailable',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PetGuardianAI(firebaseReady: false));

    expect(find.text('PetGuardianAI'), findsNothing);
    expect(find.textContaining('No se pudo inicializar Firebase'), findsOneWidget);
  });
}
