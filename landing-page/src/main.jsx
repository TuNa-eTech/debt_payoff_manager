import React from 'react';
import ReactDOM from 'react-dom/client';
import App from '@/app/App';
import { AppProviders } from '@/app/providers/AppProviders';
import { initializeFirebase } from '@/lib/firebase/client';
import '@/styles/globals.css';

initializeFirebase();

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <AppProviders>
      <App />
    </AppProviders>
  </React.StrictMode>,
);
