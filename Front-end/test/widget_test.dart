import 'package:flutter_test/flutter_test.dart';
import 'package:study_buddy/main.dart';

void main() {
  testWidgets('Study Buddy app loads correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(const StudyBuddyApp());
        expect(find.byType(StudyBuddyApp), findsOneWidget);
      });
}