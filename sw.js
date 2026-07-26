// MatCalc Service Worker
// Bump this version when you update the app — forces refresh on all devices
const VERSION = 'matcalc-v2';
const CACHE = VERSION;

// Files to cache for offline use
const ASSETS = [
  '/Price-calculate/',
  '/Price-calculate/index.html',
  '/Price-calculate/manifest.json'
];

// ── Install: cache core files ──
self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE).then(cache => cache.addAll(ASSETS))
  );
  // Take over immediately — don't wait for old SW to finish
  self.skipWaiting();
});

// ── Activate: delete old caches ──
self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    )
  );
  // Take control of all open tabs immediately
  self.clients.claim();
});

// ── Fetch: network first, fallback to cache ──
// This means: always try to get fresh version from server first.
// If offline — serve cached version.
// Result: app always auto-updates when online.
self.addEventListener('fetch', e => {
  // Skip non-GET and cross-origin (Supabase API calls)
  if (e.request.method !== 'GET') return;
  const url = new URL(e.request.url);
  if (url.origin !== location.origin) return;

  e.respondWith(
    fetch(e.request)
      .then(response => {
        // Update cache with fresh version
        const clone = response.clone();
        caches.open(CACHE).then(cache => cache.put(e.request, clone));
        return response;
      })
      .catch(() => caches.match(e.request))
  );
});

// ── Notify open tabs when new version is available ──
self.addEventListener('message', e => {
  if (e.data === 'skipWaiting') self.skipWaiting();
});
