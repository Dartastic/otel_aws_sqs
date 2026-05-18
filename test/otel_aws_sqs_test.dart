// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_aws_sqs/otel_aws_sqs.dart';
import 'package:test/test.dart';

void main() {
  group('otel_aws_sqs', () {
    test('suppression toggles in zone', () async {
      expect(awsSQSInstrumentationSuppressed(), isFalse);
      await runWithoutAwsSQSInstrumentationAsync(() async {
        expect(awsSQSInstrumentationSuppressed(), isTrue);
      });
      expect(awsSQSInstrumentationSuppressed(), isFalse);
    });

    test('AwsSQSResult fields default null', () {
      const r = AwsSQSResult();
      expect(r.statusCode, isNull);
    });
  });
}
