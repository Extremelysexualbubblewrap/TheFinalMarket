// Service Worker with precaching and runtime caching strategies
const CACHE_VERSION = 'v1';
const CACHE_NAME = `final-market-${CACHE_VERSION}`;

// Assets to precache
const PRECACHE_ASSETS = [
  '/',
  '/offline',
  '/manifest.json',
  '/icon-192x192.png',
  '/icon-512x512.png',
  '/app.css',
  '/app.js'
];

// Install event - precache assets
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(PRECACHE_ASSETS))
      .then(() => self.skipWaiting())
  );
});

// Activate event - cleanup old caches
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames
          .filter(cacheName => cacheName.startsWith('final-market-'))
          .filter(cacheName => cacheName !== CACHE_NAME)
          .map(cacheName => caches.delete(cacheName))
      );
    })
  );
});

// Helper function to determine if request is for an API
const isApiRequest = request => {
  const url = new URL(request.url);
  return url.pathname.startsWith('/api/');
};

// Helper function to determine if request is for an asset
const isAssetRequest = request => {
  return request.destination === 'style' || 
         request.destination === 'script' || 
         request.destination === 'image';
};

// Fetch event - handle network requests
self.addEventListener('fetch', event => {
  // Skip cross-origin requests
  if (!event.request.url.startsWith(self.location.origin)) return;

  // Different strategies based on request type
  if (isApiRequest(event.request)) {
    // Network-first strategy for API requests
    event.respondWith(
      fetch(event.request)
        .then(response => {
          const responseClone = response.clone();
          caches.open(CACHE_NAME).then(cache => {
            cache.put(event.request, responseClone);
          });
          return response;
        })
        .catch(() => {
          return caches.match(event.request);
        })
    );
  } else if (isAssetRequest(event.request)) {
    // Cache-first strategy for assets
    event.respondWith(
      caches.match(event.request)
        .then(response => {
          return response || fetch(event.request)
            .then(response => {
              const responseClone = response.clone();
              caches.open(CACHE_NAME).then(cache => {
                cache.put(event.request, responseClone);
              });
              return response;
            });
        })
    );
  } else {
    // Network-first strategy with offline fallback for everything else
    event.respondWith(
      fetch(event.request)
        .catch(() => {
          return caches.match(event.request)
            .then(response => {
              if (response) return response;
              
              if (event.request.mode === 'navigate') {
                return caches.match('/offline');
              }
              
              return Response.error();
            });
        })
    );
  }
});

// Push event - handle push notifications
self.addEventListener('push', event => {
  const data = event.data.json();
  
  const options = {
    body: data.body,
    icon: '/icon-192x192.png',
    badge: '/badge.png',
    vibrate: [100, 50, 100],
    data: {
      url: data.url
    },
    actions: data.actions || []
  };

  event.waitUntil(
    self.registration.showNotification(data.title, options)
  );
});

// Notification click event
self.addEventListener('notificationclick', event => {
  event.notification.close();

  if (event.action) {
    // Handle notification action buttons
    clients.openWindow(event.action);
  } else {
    // Handle notification click
    event.waitUntil(
      clients.matchAll({ type: 'window' })
        .then(clientList => {
          const url = event.notification.data.url;
          
          for (const client of clientList) {
            if (client.url === url && 'focus' in client) {
              return client.focus();
            }
          }
          
          if (clients.openWindow) {
            return clients.openWindow(url);
          }
        })
    );
  }
});