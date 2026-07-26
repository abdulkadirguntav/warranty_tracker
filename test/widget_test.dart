import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:warranty_tracker/main.dart';

void main() {
  testWidgets('App boots and shows initialization screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: WarrantyTrackerApp()));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
