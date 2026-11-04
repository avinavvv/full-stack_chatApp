import { NodeSDK } from "@opentelemetry/sdk-node";
import { getNodeAutoInstrumentations } from "@opentelemetry/auto-instrumentations-node";

import { OTLPTraceExporter } from "@opentelemetry/exporter-trace-otlp-http";
import { OTLPMetricExporter } from "@opentelemetry/exporter-metrics-otlp-http";
import { OTLPLogExporter } from "@opentelemetry/exporter-logs-otlp-http";

import { PeriodicExportingMetricReader } from "@opentelemetry/sdk-metrics";
import {
  LoggerProvider,
  BatchLogRecordProcessor,
} from "@opentelemetry/sdk-logs";

import { logs, SeverityNumber } from "@opentelemetry/api";
import { format } from "node:util";

const collectorEndpoint =
  process.env.OTEL_EXPORTER_OTLP_ENDPOINT || "http://localhost:4318";

const traceEndpoint =
  process.env.OTEL_EXPORTER_OTLP_TRACES_ENDPOINT ||
  `${collectorEndpoint.replace(/\/$/, "")}/v1/traces`;

const metricEndpoint =
  process.env.OTEL_EXPORTER_OTLP_METRICS_ENDPOINT ||
  `${collectorEndpoint.replace(/\/$/, "")}/v1/metrics`;

const logEndpoint =
  process.env.OTEL_EXPORTER_OTLP_LOGS_ENDPOINT ||
  `${collectorEndpoint.replace(/\/$/, "")}/v1/logs`;

// Traces and metrics
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

// Logs
const loggerProvider = new LoggerProvider({
  processors: [
    new BatchLogRecordProcessor({
      exporter: new OTLPLogExporter({
        url: logEndpoint,
      }),
    }),
  ],
});

logs.setGlobalLoggerProvider(loggerProvider);

const logger = loggerProvider.getLogger("observex-backend", "1.0.0");

// Capture existing application console calls.
// Original console output is preserved.
const originalConsole = {
  log: console.log.bind(console),
  info: console.info.bind(console),
  warn: console.warn.bind(console),
  error: console.error.bind(console),
  debug: console.debug.bind(console),
};

const severityMap = {
  log: SeverityNumber.INFO,
  info: SeverityNumber.INFO,
  warn: SeverityNumber.WARN,
  error: SeverityNumber.ERROR,
  debug: SeverityNumber.DEBUG,
};

let emittingOtelLog = false;

for (const method of Object.keys(originalConsole)) {
  console[method] = (...args) => {
    originalConsole[method](...args);

    if (emittingOtelLog) return;

    emittingOtelLog = true;

    try {
      const error = args.find((arg) => arg instanceof Error);

      logger.emit({
        severityNumber: severityMap[method],
        severityText: method.toUpperCase(),
        body: format(...args),
        attributes: {
          "service.name": "observex-backend",
          "log.iostream": method === "error" ? "stderr" : "stdout",
          ...(error
            ? {
                "exception.type": error.name,
                "exception.message": error.message,
                "exception.stacktrace": error.stack || "",
              }
            : {}),
        },
      });
    } catch (error) {
      originalConsole.error(
        "[ObserveX] Failed to emit OpenTelemetry log:",
        error
      );
    } finally {
      emittingOtelLog = false;
    }
  };
}

sdk.start();

console.log("[ObserveX] OpenTelemetry initialized");
console.log(`[ObserveX] Trace endpoint: ${traceEndpoint}`);
console.log(`[ObserveX] Metrics endpoint: ${metricEndpoint}`);
console.log(`[ObserveX] Logs endpoint: ${logEndpoint}`);

export { sdk, loggerProvider };
