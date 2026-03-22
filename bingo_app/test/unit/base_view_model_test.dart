import 'package:bingo_app/shared/view_models/base_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BaseViewModel', () {
    test('setLoading atualiza isLoading e notifyListeners', () {
      final vm = _TestViewModel();
      var notifications = 0;
      vm.addListener(() => notifications++);

      expect(vm.isLoading, isFalse);
      vm.setLoading(true);
      expect(vm.isLoading, isTrue);
      expect(notifications, 1);

      vm.setLoading(true);
      expect(notifications, 1);

      vm.setLoading(false);
      expect(vm.isLoading, isFalse);
      expect(notifications, 2);
    });
  });
}

class _TestViewModel extends BaseViewModel {}
