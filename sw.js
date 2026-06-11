// VapeTrack Service Worker — offline support + auto-update
const VERSION = 'vapetrack-v45-active-only';
const CACHE = `vt-cache-${VERSION}`;
const ASSETS = [
  '/',
  '/index.html',
  '/manifest.json',
  '/icon-192.png',
  '/icon-512.png',
];

// Hostnames that should NEVER be cached (always go to network)
// Critical: Supabase API responses must be fresh, not cached
const NO_CACHE_HOSTS = [
  'supabase.co',
  'supabase.in',
];

function isNoCacheHost(hostname) {
  return NO_CACHE_HOSTS.some(h => hostname === h || hostname.endsWith('.' + h));
}

// Install: pre-cache core assets
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE).then((cache) => cache.addAll(ASSETS).catch(() => {}))
  );
  self.skipWaiting();
});

// Activate: clean old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)))
    )
  );
  self.clients.claim();
});

// Fetch strategy:
//   - Supabase API: ALWAYS network (bypass SW completely)
//   - HTML: network-first (so updates are picked up), fallback to cache
//   - Other same-origin: cache-first, fallback to network
//   - Cross-origin (CDN, fonts): network with no caching to avoid stale issues
self.addEventListener('fetch', (event) => {
  const req = event.request;
  if (req.method !== 'GET') return;

  let url;
  try { url = new URL(req.url); } catch { return; }

  // CRITICAL: bypass SW for Supabase calls — never cache API data
  if (isNoCacheHost(url.hostname)) {
    return; // let browser handle directly, no SW interception
  }

  const sameOrigin = url.origin === self.location.origin;
  const isHTML = req.mode === 'navigate' ||
                 (req.headers.get('accept') || '').includes('text/html');

  if (isHTML) {
    // Network-first for HTML (so app updates propagate)
    event.respondWith(
      fetch(req)
        .then((res) => {
          if (sameOrigin) {
            const clone = res.clone();
            caches.open(CACHE).then((c) => c.put(req, clone));
          }
          return res;
        })
        .catch(() => caches.match(req).then((r) => r || caches.match('/index.html')))
    );
    return;
  }

  if (sameOrigin) {
    // Cache-first for same-origin static assets
    event.respondWith(
      caches.match(req).then((cached) => {
        if (cached) return cached;
        return fetch(req).then((res) => {
          if (res.ok) {
            const clone = res.clone();
            caches.open(CACHE).then((c) => c.put(req, clone));
          }
          return res;
        }).catch(() => cached);
      })
    );
    return;
  }

  // Cross-origin (CDN, fonts): let browser handle, don't intercept
  // (avoids accidentally caching stale third-party resources)
});

// Allow page to trigger an immediate update
self.addEventListener('message', (event) => {
  if (event.data === 'SKIP_WAITING') self.skipWaiting();
});
