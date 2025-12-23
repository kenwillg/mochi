import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mochi/utils/constants.dart';

void main() {
  group('Constants', () {
    test('primaryColor should be defined', () {
      expect(primaryColor, isA<Color>());
      expect(primaryColor.value, equals(0xFF86A873));
    });

    test('backgroundColor should be defined', () {
      expect(backgroundColor, isA<Color>());
      expect(backgroundColor.value, equals(0xFFF7F7F2));
    });

    test('accentColor should be defined', () {
      expect(accentColor, isA<Color>());
      expect(accentColor.value, equals(0xFFF2A384));
    });

    test('colors should be different from each other', () {
      expect(primaryColor, isNot(equals(backgroundColor)));
      expect(primaryColor, isNot(equals(accentColor)));
      expect(backgroundColor, isNot(equals(accentColor)));
    });
  });
}

