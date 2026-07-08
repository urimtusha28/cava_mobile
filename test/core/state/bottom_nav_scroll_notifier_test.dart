import 'package:cava_ecommerce/core/state/bottom_nav_scroll_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(BottomNavScrollNotifier.reset);

  test('reportScrollDelta ignores tiny deltas until threshold', () {
    BottomNavScrollNotifier.reportScrollDelta(3);
    expect(BottomNavScrollNotifier.compactness.value, 0);
    BottomNavScrollNotifier.reportScrollDelta(3);
    expect(BottomNavScrollNotifier.compactness.value, 0);
    BottomNavScrollNotifier.reportScrollDelta(3);
    expect(BottomNavScrollNotifier.compactness.value, greaterThan(0));
  });

  test('scroll down increases compactness gradually', () {
    for (var i = 0; i < 20; i++) {
      BottomNavScrollNotifier.reportScrollDelta(10);
    }
    expect(BottomNavScrollNotifier.compactness.value, greaterThan(0));
    expect(BottomNavScrollNotifier.compactness.value, lessThanOrEqualTo(1));
  });

  test('scroll up decreases compactness', () {
    for (var i = 0; i < 20; i++) {
      BottomNavScrollNotifier.reportScrollDelta(20);
    }
    expect(BottomNavScrollNotifier.compactness.value, 1);
    BottomNavScrollNotifier.reportScrollDelta(-60);
    expect(BottomNavScrollNotifier.compactness.value, lessThan(1));
  });

  test('expand resets compactness to zero', () {
    BottomNavScrollNotifier.reportScrollDelta(120);
    BottomNavScrollNotifier.expand();
    expect(BottomNavScrollNotifier.compactness.value, 0);
  });
}
