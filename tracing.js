import { trace } from 'https://cdn.jsdelivr.net/npm/@opentelemetry/api/+esm';
import { WebTracerProvider } from 'https://cdn.jsdelivr.net/npm/@opentelemetry/sdk-trace-web/+esm';
import { BatchSpanProcessor } from 'https://cdn.jsdelivr.net/npm/@opentelemetry/sdk-trace-base/+esm';
import { OTLPTraceExporter } from 'https://cdn.jsdelivr.net/npm/@opentelemetry/exporter-trace-otlp-http/+esm';

console.log('tracing loaded');

const exporter = new OTLPTraceExporter({
  url: 'http://signoz-otel-http-signoz.apps.ocp-dev-cluster.easelogics.com/v1/traces',
});

const provider = new WebTracerProvider({
  spanProcessors: [new BatchSpanProcessor(exporter)],
});

provider.register();

const tracer = trace.getTracer('newsite-browser');

window.addEventListener('load', () => {
  const span = tracer.startSpan('page-load-test');
  span.end();
  console.log('test span created');
});
