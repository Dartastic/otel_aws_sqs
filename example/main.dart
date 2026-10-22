// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_aws_sqs/otel_aws_sqs.dart';

/// Traces Aws Sqs calls with OpenTelemetry.
///
/// `otel_aws_sqs` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Aws Sqs call in
/// [tracedAwsSQS]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'aws-sqs-example');

  // Traces a Aws Sqs call.
  final awsSQSId = await tracedAwsSQS<String>(
    operation: 'create',
    invoke: () async {
      // Make the Aws Sqs call here, then report what it returned.
      const id = 'aws_sqs_8f3a2c';
      return const AwsSQSCallResult(
          value: id,
          result: AwsSQSResult(
              queueUrl: 'https://api.example.com/v1/resource',
              queueName: 'orders',
              fifo: true,
              messageId: 'message_8f3a2c',
              messageGroupId: 'messagegroup_8f3a2c',
              messageCount: 3,
              region: 'us-east-1',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedAwsSQS create returned $awsSQSId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAwsSQSInstrumentationAsync.
  await runWithoutAwsSQSInstrumentationAsync(
    () => tracedAwsSQS<String>(
      operation: 'create',
      invoke: () async {
        const id = 'aws_sqs_8f3a2c';
        return const AwsSQSCallResult(
            value: id,
            result: AwsSQSResult(
                queueUrl: 'https://api.example.com/v1/resource',
                queueName: 'orders',
                fifo: true,
                messageId: 'message_8f3a2c',
                messageGroupId: 'messagegroup_8f3a2c',
                messageCount: 3,
                region: 'us-east-1',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
