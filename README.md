# otel_aws_sqs

Dartastic OpenTelemetry bridge for AWS SQS (managed message queue).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_aws_sqs/otel_aws_sqs.dart';

await tracedAwsSQS<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return AwsSQSCallResult(value: r, result: AwsSQSResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutAwsSQSInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
