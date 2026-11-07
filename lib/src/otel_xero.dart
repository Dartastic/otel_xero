// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_xero_suppression.dart';

class XeroResult {
  /// Creates a result.
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

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class XeroCallResult<T> {
  /// Creates a call result.
  const XeroCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final XeroResult? result;
}

Future<T> tracedXero<T>({
  required String operation,
  required Future<XeroCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (xeroInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_xero');
  final span = t.startSpan('xero $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('rpc.system', 'xero')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.tenantId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('xero.tenant.id', res.tenantId!)]));
      }
      if (res.tenantName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('xero.tenant.name', res.tenantName!)]));
      }
      if (res.entity != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('xero.entity', res.entity!)]));
      }
      if (res.entityId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('xero.entity.id', res.entityId!)]));
      }
      if (res.contactId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('xero.contact.id', res.contactId!)]));
      }
      if (res.invoiceId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('xero.invoice.id', res.invoiceId!)]));
      }
      if (res.amount != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeDouble('xero.amount', res.amount!)]));
      }
      if (res.currency != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('xero.currency', res.currency!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('xero.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'xero.error',
          )
        ]));
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
