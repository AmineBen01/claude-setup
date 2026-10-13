import type { MetadataRoute } from "next";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "Et si on parlait des apps ?",
    short_name: "Apps ?",
    description: "Saisie des cartes du stand ontecoute.ch × Action Innocence.",
    lang: "fr-CH",
    start_url: "/",
    scope: "/",
    display: "standalone",
    background_color: "#FFF8E7",
    theme_color: "#5B0000",
    icons: [
      { src: "/icons/icon-192.png", sizes: "192x192", type: "image/png", purpose: "any" },
      { src: "/icons/icon-512.png", sizes: "512x512", type: "image/png", purpose: "any" },
      { src: "/icons/maskable-512.png", sizes: "512x512", type: "image/png", purpose: "maskable" },
    ],
  };
}
