import { getApp, getApps, initializeApp } from 'firebase/app';
import { getAnalytics, isSupported } from 'firebase/analytics';
import { firebaseConfig } from '@/lib/firebase/config';

export const firebaseApp = getApps().length ? getApp() : initializeApp(firebaseConfig);

let analyticsPromise = null;

export function initializeFirebaseAnalytics() {
  if (typeof window === 'undefined' || import.meta.env.DEV) {
    return Promise.resolve(null);
  }

  if (!analyticsPromise) {
    // Analytics is only available when the browser environment supports it.
    analyticsPromise = isSupported()
      .then((supported) => (supported ? getAnalytics(firebaseApp) : null))
      .catch(() => null);
  }

  return analyticsPromise;
}

export function initializeFirebase() {
  void initializeFirebaseAnalytics();
  return firebaseApp;
}
