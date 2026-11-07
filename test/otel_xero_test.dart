// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_xero/otel_xero.dart';
import 'package:test/test.dart';

void main() {
  group('otel_xero', () {
    test('suppression toggles in zone', () async {
      expect(xeroInstrumentationSuppressed(), isFalse);
      await runWithoutXeroInstrumentationAsync(() async {
        expect(xeroInstrumentationSuppressed(), isTrue);
      });
      expect(xeroInstrumentationSuppressed(), isFalse);
    });

    test('XeroResult fields default null', () {
      const r = XeroResult();
      expect(r.statusCode, isNull);
    });
  });
}
