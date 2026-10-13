"use client";

import { useEffect } from "react";

/** Enregistre public/sw.js : il ne sert que la page « Pas de connexion » quand le réseau manque. */
export function ServiceWorker() {
  useEffect(() => {
    if (process.env.NODE_ENV !== "production" || !("serviceWorker" in navigator)) return;
    navigator.serviceWorker.register("/sw.js", { scope: "/", updateViaCache: "none" }).catch(() => {
      // Sans service worker, l'app fonctionne normalement (seule la page hors ligne manque).
    });
  }, []);
  return null;
}
