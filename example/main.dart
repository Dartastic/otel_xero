// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_xero/otel_xero.dart';

/// Traces Xero calls with OpenTelemetry.
///
/// `otel_xero` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Xero call in
/// [tracedXero]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'xero-example');

  // Traces a Xero call.
  final xeroId = await tracedXero<String>(
    operation: 'create',
    invoke: () async {
      // Make the Xero call here, then report what it returned.
      const id = 'xero_8f3a2c';
      return const XeroCallResult(
          value: id,
          result: XeroResult(
              tenantId: 'tenant_8f3a2c',
              tenantName: 'example',
              entity: 'example',
              entityId: 'entity_8f3a2c',
              contactId: 'contact_8f3a2c',
              invoiceId: 'invoice_8f3a2c',
              amount: 0.5,
              currency: 'usd',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedXero create returned $xeroId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutXeroInstrumentationAsync.
  await runWithoutXeroInstrumentationAsync(
    () => tracedXero<String>(
      operation: 'create',
      invoke: () async {
        const id = 'xero_8f3a2c';
        return const XeroCallResult(
            value: id,
            result: XeroResult(
                tenantId: 'tenant_8f3a2c',
                tenantName: 'example',
                entity: 'example',
                entityId: 'entity_8f3a2c',
                contactId: 'contact_8f3a2c',
                invoiceId: 'invoice_8f3a2c',
                amount: 0.5,
                currency: 'usd',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
