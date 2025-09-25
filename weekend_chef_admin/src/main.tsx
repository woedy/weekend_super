import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter as Router } from 'react-router-dom';
import * as Sentry from '@sentry/react';
import App from './App';
import './css/style.css';
import './css/satoshi.css';
import 'jsvectormap/dist/css/jsvectormap.css';
import 'flatpickr/dist/flatpickr.min.css';

const sentryDsn = import.meta.env.VITE_SENTRY_DSN ?? '';
if (sentryDsn) {
  Sentry.init({
    dsn: sentryDsn,
    environment: import.meta.env.VITE_SENTRY_ENVIRONMENT ?? 'development',
    integrations: [
      Sentry.browserTracingIntegration(),
      Sentry.replayIntegration({ blockAllMedia: false }),
    ],
    tracesSampleRate: Number(import.meta.env.VITE_SENTRY_TRACES_SAMPLE_RATE ?? '0.1'),
    replaysSessionSampleRate: Number(import.meta.env.VITE_SENTRY_REPLAY_SESSION_SAMPLE_RATE ?? '0.0'),
    replaysOnErrorSampleRate: Number(import.meta.env.VITE_SENTRY_REPLAY_ON_ERROR_SAMPLE_RATE ?? '1.0'),
  });
}

const Root = () => (
  <React.StrictMode>
    <Sentry.ErrorBoundary fallback={<ErrorFallback />}>
      <Router>
        <App />
      </Router>
    </Sentry.ErrorBoundary>
  </React.StrictMode>
);

const ErrorFallback: React.FC = () => (
  <div style={{ padding: 24, fontFamily: 'Inter, sans-serif' }}>
    <h1>Something went wrong</h1>
    <p>Our monitoring has been notified. Please refresh the page and try again.</p>
  </div>
);

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(<Root />);
