import { WebTracerProvider } from 'https://cdn.jsdelivr.net/npm/@opentelemetry/sdk-trace-web/+esm';
import { BatchSpanProcessor } from 'https://cdn.jsdelivr.net/npm/@opentelemetry/sdk-trace-base/+esm';
import { OTLPTraceExporter } from 'https://cdn.jsdelivr.net/npm/@opentelemetry/exporter-trace-otlp-http/+esm';
import { registerInstrumentations } from 'https://cdn.jsdelivr.net/npm/@opentelemetry/instrumentation/+esm';
import { FetchInstrumentation } from 'https://cdn.jsdelivr.net/npm/@opentelemetry/instrumentation-fetch/+esm';
import { XMLHttpRequestInstrumentation } from 'https://cdn.jsdelivr.net/npm/@opentelemetry/instrumentation-xml-http-request/+esm';
import { UserInteractionInstrumentation } from 'https://cdn.jsdelivr.net/npm/@opentelemetry/instrumentation-user-interaction/+esm';

console.log('tracing loaded');

const exporter = new OTLPTraceExporter({
  url: 'http://signoz-otel-http-signoz.apps.ocp-dev-cluster.easelogics.com/v1/traces',
});

const provider = new WebTracerProvider({
  spanProcessors: [new BatchSpanProcessor(exporter)],
});

provider.register();

registerInstrumentations({
  instrumentations: [
    new FetchInstrumentation(),
    new XMLHttpRequestInstrumentation(),
    new UserInteractionInstrumentation(),
  ],
});

console.log('otel registered');
