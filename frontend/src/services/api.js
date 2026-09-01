/**
 * RaktDrishti API Service
 * Handles live requests with automatic failover to live Render cloud backend
 */

const CLOUD_BACKEND_URL = 'https://raktdrishti-backend.onrender.com/api/v1';

export async function apiFetch(endpoint, options = {}) {
  const path = endpoint.startsWith('/') ? endpoint : `/${endpoint}`;
  
  // 1. First attempt: standard relative request (works with Vite dev proxy and Vercel rewrites)
  try {
    const res = await fetch(`/api/v1${path}`, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...(options.headers || {})
      }
    });

    if (res.ok) {
      return res;
    }
  } catch (err) {
    console.warn(`Local endpoint /api/v1${path} failed, attempting live cloud failover:`, err);
  }

  // 2. Failover: Direct request to live Render cloud backend
  try {
    const cloudRes = await fetch(`${CLOUD_BACKEND_URL}${path}`, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...(options.headers || {})
      }
    });
    return cloudRes;
  } catch (cloudErr) {
    console.error(`Live cloud failover to ${CLOUD_BACKEND_URL}${path} failed:`, cloudErr);
    throw cloudErr;
  }
}

export const api = {
  getSummary: async () => {
    const res = await apiFetch('/dashboard/summary');
    return res.json();
  },

  getPatients: async () => {
    const res = await apiFetch('/patients?limit=50');
    return res.json();
  },

  createPatient: async (patient) => {
    const res = await apiFetch('/patients', {
      method: 'POST',
      body: JSON.stringify(patient)
    });
    return res.json();
  },

  getScreenings: async () => {
    const res = await apiFetch('/screenings?limit=50');
    return res.json();
  },

  createScreening: async (screening) => {
    const res = await apiFetch('/screenings', {
      method: 'POST',
      body: JSON.stringify(screening)
    });
    return res.json();
  },

  getReferrals: async () => {
    const res = await apiFetch('/referrals?limit=50');
    return res.json();
  },

  updateReferral: async (id, payload) => {
    const res = await apiFetch(`/referrals/${id}`, {
      method: 'PATCH',
      body: JSON.stringify(payload)
    });
    return res.json();
  },

  getAnalytics: async () => {
    const res = await apiFetch('/analytics/charts');
    return res.json();
  },

  getLocations: async () => {
    const res = await apiFetch('/analytics/locations');
    return res.json();
  },

  resetDemoData: async () => {
    const res = await apiFetch('/demo/reset', { method: 'POST' });
    return res.json();
  },

  syncQueue: async (queueItems) => {
    const res = await apiFetch('/sync/batch', {
      method: 'POST',
      body: JSON.stringify({ items: queueItems })
    });
    return res.json();
  }
};
