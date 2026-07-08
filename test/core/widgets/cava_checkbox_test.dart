import 'package:cava_ecommerce/core/theme/app_colors.dart';
import 'package:cava_ecommerce/core/widgets/cava_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('unchecked: white fill, burgundy border, empty inside',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CavaCheckbox(
            value: false,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.check), findsNothing);
    final outer = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer).first,
    );
    final decoration = outer.decoration! as BoxDecoration;
    expect(decoration.color, Colors.white);
    expect(decoration.border?.top.color, AppColors.burgundy);
  });

  testWidgets('checked: white fill, burgundy border, inner square, no tick',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CavaCheckbox(
            value: true,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.check), findsNothing);
    final containers = find.byType(AnimatedContainer);
    expect(containers, findsNWidgets(2));

    final outer = tester.widget<AnimatedContainer>(containers.first);
    final outerDecoration = outer.decoration! as BoxDecoration;
    expect(outerDecoration.color, Colors.white);
    expect(outerDecoration.border?.top.color, AppColors.burgundy);

    final inner = tester.widget<AnimatedContainer>(containers.at(1));
    final innerDecoration = inner.decoration! as BoxDecoration;
    expect(innerDecoration.color, AppColors.burgundy);
  });

  testWidgets('tap toggles via onChanged', (tester) async {
    var value = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return CavaCheckbox(
                value: value,
                onChanged: (next) => setState(() => value = next ?? false),
              );
            },
          ),
        ),
      ),
    );

    expect(find.byType(AnimatedContainer), findsOneWidget);
    await tester.tap(find.byType(CavaCheckbox));
    await tester.pump();
    expect(find.byType(AnimatedContainer), findsNWidgets(2));
    expect(find.byIcon(Icons.check), findsNothing);
  });
}
