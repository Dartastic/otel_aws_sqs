// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_aws_sqs_suppression.dart';

class AwsSQSResult {
  const AwsSQSResult({
    this.queueUrl,
    this.queueName,
    this.fifo,
    this.messageId,
    this.messageGroupId,
    this.messageCount,
    this.region,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? queueUrl;
  final String? queueName;
  final bool? fifo;
  final String? messageId;
  final String? messageGroupId;
  final int? messageCount;
  final String? region;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class AwsSQSCallResult<T> {
  const AwsSQSCallResult({required this.value, this.result});
  final T value;
  final AwsSQSResult? result;
}

Future<T> tracedAwsSQS<T>({
  required String operation,
  required Future<AwsSQSCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (awsSQSInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_aws_sqs');
  final span = t.startSpan('sqs $operation', kind: SpanKind.producer);
  try {
    span.setStringAttribute('messaging.system', 'aws_sqs');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.queueUrl != null) {
        span.setStringAttribute('messaging.destination.url', res.queueUrl!);
      }
      if (res.queueName != null) {
        span.setStringAttribute('messaging.destination.name', res.queueName!);
      }
      if (res.fifo != null) {
        span.setBoolAttribute('messaging.aws.sqs.fifo', res.fifo!);
      }
      if (res.messageId != null) {
        span.setStringAttribute('messaging.message.id', res.messageId!);
      }
      if (res.messageGroupId != null) {
        span.setStringAttribute(
          'messaging.aws.sqs.message_group_id',
          res.messageGroupId!,
        );
      }
      if (res.messageCount != null) {
        span.setIntAttribute(
          'messaging.batch.message_count',
          res.messageCount!,
        );
      }
      if (res.region != null) {
        span.setStringAttribute('cloud.region', res.region!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('sqs.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'sqs.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
