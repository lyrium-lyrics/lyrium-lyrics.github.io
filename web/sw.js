self.addEventListener("install", (event) => {
    event.waitUntil(
        caches.open("flutter-app-cache").then((cache) => {
            return cache.addAll([
                "/",
                "/index.html",
                "/main.dart.wasm",
                "/main.dart.mjs",
                "/skwasm.js",
                "/drift_worker.js",
            ]);
        })
    );
});

self.addEventListener("fetch", (event) => {
    event.respondWith(
        caches.match(event.request).then((cachedResponse) => {
            if (cachedResponse) {
                return cachedResponse;
            }
            return fetch(event.request);
        })
    );
});
