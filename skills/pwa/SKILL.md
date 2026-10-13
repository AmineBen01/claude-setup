---
name: pwa
description: Rendre un site Next.js installable sur téléphone (PWA) — manifeste, icônes, bandeau d'installation (bouton sur Android, instructions sur iPhone/iPad), affichage correct sous l'encoche et la barre d'accueil en mode installé, page « Pas de connexion ». À utiliser quand l'utilisateur veut « installer le site comme une app », « ajouter à l'écran d'accueil », une PWA, une icône d'app, ou un mode hors ligne.
---

# PWA : installer le site sur téléphone

Recette éprouvée sur `ciao`. Modèles prêts dans `references/modeles/` : les adapter
(couleurs, textes, nom), ne pas les recopier aveuglément.

## 1. Ce qu'il faut dire avant les questions (faits qui changent la donne)

- **Android/Chrome** : un vrai bouton « Installer » est possible (`beforeinstallprompt`).
- **iPhone/iPad** : Apple n'autorise aucun bouton ; seulement des instructions
  (Partager → « Sur l'écran d'accueil »). Safari ne sait pas si le site est déjà installé.
- **Mode installé** : plus de barre d'adresse, de bouton retour ni de rechargement →
  chaque écran doit garder un moyen de revenir, et une page hors ligne est utile.
- **Orientation** : un blocage portrait n'est respecté que sur Android.
- **Icône en mode sombre (iOS)** : l'iPhone l'assombrit lui-même ; un site n'y peut rien.
- **iOS mémorise l'icône à l'installation** : changer d'icône impose de réinstaller.

## 2. Questions de cadrage (règle globale, avec recommandation)

- Où et sur quels écrans apparaît le bandeau ? (Recommandé : sous l'en-tête, pas sur les
  écrans montrés au public.)
- Peut-on le fermer ? (Recommandé : croix, retour 7 jours après tant que non installé.)
- Quelle icône ? Proposer 2-3 variantes rendues en image (`ImageResponse` via
  `scripts/generate-icons.tsx`) et les montrer avec SendUserFile.
- Nom sous l'icône : 12 caractères maximum (sinon coupé sur iPhone).
- Barre d'état sur iPhone : couleur de l'en-tête en continuité (`black-translucent`) ou
  barre système normale.
- Page hors ligne : oui (recommandé) ou non.

## 3. Construction

1. **Manifeste** `app/manifest.ts` (modèle `manifest.ts`) : `name`, `short_name`,
   `start_url`, `display: "standalone"`, couleurs, icônes 192/512 `any` + 512
   `maskable`.
2. **Icônes** (modèle `generate-icons.tsx`, lancé par `pnpm tsx scripts/generate-icons.tsx`) :
   `public/icons/icon-192.png`, `icon-512.png` (coins arrondis), `maskable-512.png`
   (contenu dans les 60 % centraux, fond plein), `app/apple-icon.png` 180 px (fond plein,
   l'iPhone arrondit), `app/icon.png` (favicon) ; supprimer `app/favicon.ico`.
   Regarder les PNG produits avant de continuer.
3. **Layout** : `metadata.appleWebApp = { capable: true, title, statusBarStyle }`,
   `metadata.applicationName`, `viewport = { themeColor, viewportFit: "cover" }`.
4. **Encoche et barres** :
   - utilitaire CSS `px-safe` (`padding-inline: max(gutter, env(safe-area-inset-*))`) sur
     l'en-tête, le contenu et les barres fixes ;
   - `pt-[env(safe-area-inset-top)]` sur l'en-tête collant (si `black-translucent`) ;
   - `pb-[env(safe-area-inset-bottom)]` sur les barres fixées en bas ;
   - fenêtres positionnées en haut : `top-[calc(env(safe-area-inset-top)+1.5rem)]`.
5. **Bandeau** : modèles `install-prompt.ts` (écoute `beforeinstallprompt` dès le
   chargement du module, avant l'affichage du bandeau) et `install-banner.tsx`
   (masqué en mode installé, après `appinstalled`, et pendant 7 jours après la croix).
   Le placer seulement sur les écrans décidés.
6. **Hors ligne** : `public/sw.js` (ne garde que `offline.html`, tout le reste passe par le
   réseau → chaque mise en ligne arrive tout de suite dans l'app installée),
   `public/offline.html` autonome (styles en ligne, encoche gérée),
   `components/service-worker.tsx` (enregistrement en production seulement).

## 4. Vérifier

Avec `verifier` (profil `playwright-iphone`) :
- le manifeste, les icônes, `sw.js` et `offline.html` répondent `200` ;
- capture de l'écran avec le bandeau (iPhone : instructions) ;
- les balises `apple-mobile-web-app-*` et `viewport-fit=cover` sont dans la page.

Non vérifiable sans appareil réel, à demander à l'utilisateur :
installation réelle (iPhone + Android), rendu sous l'encoche en mode installé, page hors
ligne en mode avion, téléchargement de fichiers dans l'app installée sur iPhone.
