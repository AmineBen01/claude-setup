---
name: verifier
description: Prouver, en autonomie et par le vrai chemin, qu'une fonctionnalité d'un site ou d'une app web marche avant de la livrer — tests, puis parcours réel dans un navigateur piloté (Playwright, iPhone/Safari et Android), captures regardées, effets en base contrôlés, relecture pour les grosses fonctionnalités. À utiliser à la fin de chaque fonctionnalité construite (sauf tout petit changement), avant `mise-en-ligne`, ou quand l'utilisateur demande « vérifie », « teste », « est-ce que ça marche ».
---

# Vérifier : la preuve que ça marche

But : que l'utilisateur n'ait jamais à découvrir lui-même un bug que j'aurais pu voir.
Aucune annonce de réussite sans preuve. Une seule passe, à la fin, proportionnée au risque.

**Périmètre** : sites et apps web. Pour un autre type de projet (app iOS, Expo, scripts),
suivre la section « Vérifier » du CLAUDE.md du projet ; à défaut, la vérification
proportionnée habituelle (tests, puis le contrôle le plus proche du vrai usage).

**Tout petit changement** (texte, couleur, marge) : une capture de l'écran concerné suffit.

## 0. Préparer

- Lire la section « Vérifier » du CLAUDE.md du projet : elle a le dernier mot (port,
  commandes, parcours clés, interdits comme « pas de build pendant `pnpm dev` »).
- **Base de données : jamais la production.** Vérifier que `DATABASE_URL` de `.env.local`
  pointe sur la branche Neon « dev » (l'hôte contient l'id de l'endpoint de la branche dev,
  différent de celui de `main`). Si le projet n'a pas de base de dev, ne tester aucune
  écriture : le dire, et proposer d'en créer une.
- Lister les parcours à prouver, du point de vue de l'utilisateur, à partir des
  **Décisions validées** du plan : ce qu'il fait, ce qu'il doit voir. Inclure les cas
  limites décidés (erreur réseau, champ vide, minimum non atteint…).

## 1. Contrôles statiques (une fois)

Dans cet ordre, en s'arrêtant au premier échec pour corriger :
`pnpm test` (s'il existe) → `pnpm lint` → `pnpm build`.
Le build vérifie aussi les types et le prérendu (erreurs `<Suspense>` de Next 16).
Après un changement de `globals.css` ou de thème : vérifier que le CSS produit contient les
nouvelles variables (`grep … .next/static/chunks/*.css`) — un cache de build a déjà resservi
un vieux CSS.

## 2. Le vrai parcours, dans le navigateur

Lancer le build de production en local : `pnpm start -p <port libre>` en arrière-plan
(ou le serveur indiqué par le CLAUDE.md du projet), attendre qu'il réponde.

Deux profils Playwright MCP sont configurés :
- `playwright-iphone` : WebKit (moteur de Safari), iPhone 15 — **profil principal**,
  parcours complets. Il attrape les bugs propres à Safari (champs date, `100vh`…).
- `playwright-android` : Chromium, Pixel 7 — mise en page et parcours principal.

Chaque écran se regarde en **clair et en sombre** (`browser_emulate_media` avec
`colorScheme`, ou `colorScheme` dans le contexte en script), à trois tailles :
iPhone 390×844, Android 412×915 et **ordinateur 1440×900** (`browser_resize`).

Pour chaque parcours :
1. Naviguer, puis agir comme l'utilisateur : taper, remplir, choisir, valider.
   Préférer l'instantané d'accessibilité (`browser_snapshot`) pour trouver les éléments ;
   il coûte moins cher qu'une capture.
2. **Regarder les captures** (`browser_take_screenshot`) aux moments clés : écran
   initial, après chaque action importante, états d'erreur. Chercher : débordements,
   textes coupés, chevauchements, éléments sous l'encoche ou sous la barre du bas,
   zones tactiles trop petites, contraste.
3. Lire la console (`browser_console_messages`) et les requêtes réseau en échec : zéro
   erreur attendue. **Échec** sur toute erreur de console : hydratation, avertissements
   Base UI (`nativeButton`), erreurs non rattrapées.
4. Vérifier les effets réels : en base (lecture SQL sur la branche dev via le MCP Neon),
   fichiers produits (ouvrir un export), cookies posés…
5. Rechargement en plein milieu si l'état doit survivre ; double clic sur une action
   qui écrit (pas de doublon).

**Fenêtres et panneaux qui contiennent un champ** : les ouvrir au doigt (`locator.tap()`) ; le
clavier ne doit pas s'ouvrir tout seul (`document.activeElement` n'est pas le champ).

**Barre latérale (ordinateur)** : capture repliée et dépliée, survol d'une entrée voisine de
l'entrée active. Le logo reste carré une fois replié, le bouton de repli est dans la barre et pas
dans l'en-tête, deux fonds gris ne se touchent jamais.

**Ce qui s'affiche ne prouve rien** : après chaque action qui écrit, relire la base. Sur
ciao, une correction s'affichait à l'écran alors que le serveur l'avait refusée.

### Astuces Playwright MCP (apprises sur un vrai projet)

- Captures et instantanés doivent rester dans le projet : `filename: ".playwright-mcp/…"`
  (ignoré par git globalement, `~/.config/git/ignore`). Regarder chaque capture avec Read.
- Un bouton dont le nom accessible change (compteur, état) invalide sa référence : cibler
  par sélecteur, ex. `button[aria-label^="TikTok"]`, `button:has-text("Voir le résultat")`.
- Les écrans rendus seulement côté navigateur (lecture de `localStorage`) arrivent après
  un squelette, surtout au premier lancement d'un navigateur : attendre un élément
  (`browser_wait_for`) avant de cliquer.
- Pour enchaîner un parcours ou simuler le doigt (`locator.tap()`, focus, ordre d'une
  liste, export téléchargé via `page.request`), `browser_run_code_unsafe` avec une
  fonction `async (page) => { … }` qui renvoie un objet de résultats.
- **Cookies `Secure` en local** : WebKit les refuse sur `http://localhost` (Chromium les
  accepte). Si un parcours dépend d'un cookie et échoue seulement en WebKit, vérifier
  l'en-tête `Set-Cookie` (`browser_network_request`) et la présence du cookie dans la
  requête suivante. Le code doit marquer ses cookies `secure` selon l'hébergement
  (`process.env.VERCEL === "1"`), pas selon `NODE_ENV`.

Si Playwright MCP n'est pas disponible dans la session : utiliser le paquet `playwright`
en script (mêmes appareils : `devices["iPhone 15"]` sur `webkit`, `devices["Pixel 7"]`
sur `chromium`), et le signaler.

## 3. Relecture (grosses fonctionnalités seulement)

Nouvel écran, données, sécurité, argent, authentification :
- `/code-review` sur le diff ;
- interface : relire les composants touchés avec `references/regles-interface.md` ;
- performance : `references/perf-critique.md` (requêtes en cascade, code envoyé au
  navigateur).

Corriger ce qui est réel, puis ne relancer que les contrôles touchés par la correction.

## 4. Ranger et rendre compte

- Arrêter le serveur lancé (par port ou PID : `lsof -t -iTCP:<port> -sTCP:LISTEN`), fermer
  les navigateurs.
- Données de test : elles sont sur la branche dev ; les laisser ou les nettoyer par id,
  jamais de suppression en masse.
- Rendre compte en quelques lignes : ce qui est **prouvé** (avec 1 ou 2 captures
  envoyées à l'utilisateur si l'écran compte), ce qui a été corrigé en route, et ce qui
  **n'est pas vérifiable sans appareil réel** (installation PWA, mode avion, réglages du
  téléphone). Ne jamais présenter comme vérifié ce qui ne l'a pas été.

Ensuite : `mise-en-ligne`.
