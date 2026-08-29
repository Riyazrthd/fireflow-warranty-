const CACHE_NAME = 'fireflow-pwa-v3';
const DYNAMIC_CACHE = 'fireflow-dynamic-v3';

// Relative assets without leading slashes for perfect GitHub Pages & Custom Domain compatibility
const PRECACHE_ASSETS = [
  './',
  './index.html',
  './app.bundle.js',
  './manifest.json',
  './icons/favicon.png'
];

// Install Event: Precache static assets gracefully
self.addEventListener('install', (event) => {
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE_NAME).then(async (cache) => {
      console.log('[Service Worker v3] Precaching Core Assets...');
      for (const asset of PRECACHE_ASSETS) {
        try {
          await cache.add(asset);
        } catch (err) {
          console.warn('[Service Worker] Non-critical precache skip for:', asset, err);
        }
      }
    })
  );
});

// Activate Event: Cleanup old caches immediately
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME && cacheName !== DYNAMIC_CACHE) {
            console.log('[Service Worker] Removing deprecated cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => {
      return self.clients.claim();
    })
  );
});

// Fetch Event: Network-First for HTML/Navigations, Cache-First with Network Fallback for JS/Assets
self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;

  const url = new URL(event.request.url);

  // 1. HTML / Document Navigation: Network First -> Cache Fallback
  if (event.request.mode === 'navigate' || (event.request.headers.get('accept') && event.request.headers.get('accept').includes('text/html'))) {
    event.respondWith(
      fetch(event.request)
        .then((response) => {
          if (response && response.status === 200) {
            const respClone = response.clone();
            caches.open(DYNAMIC_CACHE).then((cache) => cache.put(event.request, respClone));
          }
          return response;
        })
        .catch(async () => {
          const cached = await caches.match(event.request);
          if (cached) return cached;
          const fallback = await caches.match('./index.html');
          return fallback || new Response('Offline', { status: 503, statusText: 'Offline' });
        })
    );
    return;
  }

  // 2. JS / CSS / Static Assets: Stale-While-Revalidate (Never return HTML for JS requests!)
  event.respondWith(
    caches.match(event.request).then((cachedResponse) => {
      const fetchPromise = fetch(event.request).then((networkResponse) => {
        if (networkResponse && (networkResponse.status === 200 || networkResponse.type === 'opaque')) {
          const respClone = networkResponse.clone();
          caches.open(DYNAMIC_CACHE).then((cache) => cache.put(event.request, respClone));
        }
        return networkResponse;
      }).catch((err) => {
        // Network offline or failed, rely on cache
      });

      return cachedResponse || fetchPromise;
    })
  );
});

// Push Notifications
self.addEventListener('push', (event) => {
  let data = { title: 'FireFlow Alert', body: 'You have a new update in FireFlow Portal.' };
  if (event.data) {
    try {
      data = event.data.json();
    } catch (e) {
      data = { title: 'FireFlow Alert', body: event.data.text() };
    }
  }
  const options = {
    body: data.body,
    icon: './icons/icon-192x192.png',
    badge: './icons/icon-72x72.png',
    vibrate: [100, 50, 100],
    data: { url: './' }
  };
  event.waitUntil(self.registration.showNotification(data.title, options));
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.waitUntil(
    clients.matchAll({ type: 'window' }).then((clientList) => {
      for (const client of clientList) {
        if (client.url.includes(self.registration.scope) && 'focus' in client) {
          return client.focus();
        }
      }
      if (clients.openWindow) {
        return clients.openWindow('./');
      }
    })
  );
});
