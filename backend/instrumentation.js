import { NodeSDK } from "@opentelemetry/sdk-node";
import { getNodeAutoInstrumentations } from "@opentelemetry/auto-instrumentations-node";
import { OTLPTraceExporter } from "@opentelemetry/exporter-trace-otlp-http";
import { OTLPMetricExporter } from "@opentelemetry/exporter-metrics-otlp-http";
import { PeriodicExportingMetricReader } from "@opentelemetry/sdk-metrics";

const collectorEndpoint =
  process.env.OTEL_EXPORTER_OTLP_ENDPOINT || "http://localhost:4318";

const traceEndpoint =
  process.env.OTEL_EXPORTER_OTLP_TRACES_ENDPOINT ||
  `${collectorEndpoint.replace(/\/$/, "")}/v1/traces`;

const metricEndpoint =
  process.env.OTEL_EXPORTER_OTLP_METRICS_ENDPOINT ||
  `${collectorEndpoint.replace(/\/$/, "")}/v1/metrics`;

const sdk = new NodeSDK({
  serviceName: "observex-backend",

  traceExporter: new OTLPTraceExporter({
    url: traceEndpoint,
  }),

  metricReaders: [
    new PeriodicExportingMetricReader({
      exporter: new OTLPMetricExporter({
        url: metricEndpoint,
      }),
      exportIntervalMillis: 60000,
    }),
  ],

  instrumentations: [
    getNodeAutoInstrumentations({
      "@opentelemetry/instrumentation-fs": {
        enabled: false,
      },
    }),
  ],
});

sdk.start();

console.log("[ObserveX] OpenTelemetry initialized");
console.log(`[ObserveX] Trace endpoint: ${traceEndpoint}`);
console.log(`[ObserveX] Metrics endpoint: ${metricEndpoint}`);

export { sdk };
