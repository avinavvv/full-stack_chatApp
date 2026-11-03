import { metrics } from "@opentelemetry/api";

const meter = metrics.getMeter("observex-backend");

// Total HTTP requests
const httpRequests = meter.createCounter(
  "observex_http_requests_total",
  {
    description: "Total number of HTTP requests",
    unit: "{request}",
  }
);

// HTTP requests returning 4xx or 5xx
const httpErrors = meter.createCounter(
  "observex_http_errors_total",
  {
    description: "Total number of HTTP error responses",
    unit: "{request}",
  }
);

// HTTP request response time
const httpRequestDuration = meter.createHistogram(
  "observex_http_request_duration_ms",
  {
    description: "HTTP request duration in milliseconds",
    unit: "ms",
  }
);

// Currently connected Socket.IO clients
const activeSocketConnections = meter.createUpDownCounter(
  "observex_socket_connections_active",
  {
    description: "Number of currently active Socket.IO connections",
    unit: "{connection}",
  }
);

export function recordHttpRequest(method, statusCode, durationMs) {
  const attributes = {
    "http.request.method": method,
    "http.response.status_code": statusCode,
  };

  httpRequests.add(1, attributes);

  if (statusCode >= 400) {
    httpErrors.add(1, attributes);
  }

  httpRequestDuration.record(durationMs, attributes);
}

export function recordSocketConnection() {
  activeSocketConnections.add(1);
}

export function recordSocketDisconnection() {
  activeSocketConnections.add(-1);
}
