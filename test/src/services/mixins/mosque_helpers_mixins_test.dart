import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mawaqit/src/domain/model/home_active_screen.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';
import 'package:mawaqit/src/models/times.dart';
import 'package:mawaqit/src/services/mixins/mosque_helpers_mixins.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';

void main() {
  group('mosque helpers mixins ...', () {
    test('Next Jumua Calculator', () async {
      final helperMixin = MosqueManager();

      final saturday = DateTime(2023, 9, 2); // saturday
      final sunday = DateTime(2023, 9, 3); // sunday
      final monday = DateTime(2023, 9, 4); // monday
      final tuesday = DateTime(2023, 9, 5); // tuesday
      final wednesday = DateTime(2023, 9, 6); // wednesday
      final thursday = DateTime(2023, 9, 7); // thursday
      final friday = DateTime(2023, 9, 8); // friday

      expect(helperMixin.nextFridayDate(saturday), friday);
      expect(helperMixin.nextFridayDate(sunday), friday);
      expect(helperMixin.nextFridayDate(monday), friday);
      expect(helperMixin.nextFridayDate(tuesday), friday);
      expect(helperMixin.nextFridayDate(wednesday), friday);
      expect(helperMixin.nextFridayDate(thursday), friday);
      expect(helperMixin.nextFridayDate(friday), friday);
    });
  });
}
