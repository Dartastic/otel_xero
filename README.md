# otel_xero

Dartastic OpenTelemetry bridge for Xero (SMB accounting).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_xero/otel_xero.dart';

await tracedXero<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return XeroCallResult(value: r, result: XeroResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutXeroInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
