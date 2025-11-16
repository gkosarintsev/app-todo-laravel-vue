import axios from 'axios';

const api = axios.create({
  baseURL: '/api',
  withCredentials: true,
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  },
});

// Separate axios instance for CSRF cookie (not using /api baseURL)
const csrfAxios = axios.create({
  withCredentials: true,
  headers: {
    'Accept': 'application/json',
  },
});

export async function getCsrfCookie() {
  // Request the CSRF cookie from the backend root (proxied by Vite)
  await csrfAxios.get('/sanctum/csrf-cookie');
}

export default api;
