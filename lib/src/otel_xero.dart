// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_xero_suppression.dart';

class XeroResult {
  const XeroResult({
    this.tenantId,
    this.tenantName,
    this.entity,
    this.entityId,
    this.contactId,
    this.invoiceId,
    this.amount,
    this.currency,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? tenantId;
  final String? tenantName;
  final String? entity;
  final String? entityId;
  final String? contactId;
  final String? invoiceId;
  final double? amount;
  final String? currency;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class XeroCallResult<T> {
  const XeroCallResult({required this.value, this.result});
  final T value;
  final XeroResult? result;
}

Future<T> tracedXero<T>({
  required String operation,
  required Future<XeroCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (xeroInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_xero');
  final span = t.startSpan('xero $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'xero');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.tenantId != null) {
        span.setStringAttribute('xero.tenant.id', res.tenantId!);
      }
      if (res.tenantName != null) {
        span.setStringAttribute('xero.tenant.name', res.tenantName!);
      }
      if (res.entity != null) {
        span.setStringAttribute('xero.entity', res.entity!);
      }
      if (res.entityId != null) {
        span.setStringAttribute('xero.entity.id', res.entityId!);
      }
      if (res.contactId != null) {
        span.setStringAttribute('xero.contact.id', res.contactId!);
      }
      if (res.invoiceId != null) {
        span.setStringAttribute('xero.invoice.id', res.invoiceId!);
      }
      if (res.amount != null) {
        span.setDoubleAttribute('xero.amount', res.amount!);
      }
      if (res.currency != null) {
        span.setStringAttribute('xero.currency', res.currency!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('xero.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'xero.error',
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
