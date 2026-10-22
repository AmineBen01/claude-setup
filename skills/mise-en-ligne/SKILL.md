---
name: mise-en-ligne
description: Livrer jusqu'au bout une fonctionnalité vérifiée d'un projet web ou d'une app des stores — commit sur main, push GitHub, attente du déploiement Vercel (et migration de la base de production si le schéma a changé), contrôle en lecture seule du site en ligne ; pour une app Expo, le build TestFlight, la fiche App Store, la soumission à la revue et le jour du lancement. Puis l'adresse et la courte liste de tests à faire sur téléphone. À utiliser après `verifier`, ou quand l'utilisateur dit « mets en ligne », « déploie », « pousse », « livre », « TestFlight », « soumets ».
---

# Mise en ligne

Règle de l'utilisateur : je livre jusqu'au bout, il n'a rien à faire dans Vercel.
Prérequis : `verifier` est passé (sauf tout petit changement).

**Exceptions** : si le CLAUDE.md ou la mémoire du projet interdit le push (ex. `ai-job-search`),
s'arrêter au commit et le dire. Un projet non web n'a pas d'étape Vercel.

## 1. Commit

- `git status` : relire ce qui part. Aucun `.env*`, aucune clé, aucun fichier lourd
  inattendu. Si des modifications **sans rapport avec ce travail** traînent (travail en
  cours de l'utilisateur), ne committer que mes fichiers et le signaler.
- Sinon `git add -A`, puis un message (dans la langue des commits existants du repo) qui dit ce que l'utilisateur gagne
  (titre court, puis 1 à 3 lignes), terminé par les lignes d'attribution en vigueur.
- Directement sur `main`, pas de branche.

## 2. Base de production (seulement si le schéma a changé)

Avant de pousser le code qui en dépend :
- les migrations doivent être additives (ajouter une colonne nullable, une table) pour
  que l'ancienne version du site continue de marcher pendant le déploiement ;
- appliquer la migration sur la branche `main` de Neon : récupérer sa chaîne de
  connexion via le MCP Neon (`get_connection_string`, branche main) et lancer
  `pnpm db:migrate` avec `DATABASE_URL` passée en variable de la commande, **sans
  l'afficher** ;
- **jamais** de valeur de production prise dans `.env.local`, qui pointe sur la base dev.

## 3. Push et déploiement

- Noter l'URL du dernier déploiement : `vercel ls 2>&1 | grep -m1 https://`
  (le CLI écrit son tableau sur stderr).
- Pas de remote : `gh repo create AmineBen01/<nom> --private --source . --push`.
  Sinon `git push`.
- Projet relié à GitHub dans Vercel (cas normal) : attendre que `vercel ls` affiche un
  nouveau déploiement en tête, puis `vercel inspect <url> --wait --timeout 6m`.
  Projet non relié : `vercel deploy --prod --yes` (bloquant).
- **Échec du build** : `vercel inspect <url> --logs 2>&1 | tail -80`, trouver la cause,
  corriger, revérifier ce qui est touché, recommencer. Ne jamais annoncer une mise en
  ligne qui a échoué.
- **Nouvelle variable d'environnement** : `vercel env add NOM production < <(commande qui
  écrit la valeur)` (la valeur ne doit jamais apparaître à l'écran), puis redéployer.

Projet pas encore relié à Vercel sur ce Mac (pas de `.vercel/project.json`) :
`vercel project ls 2>&1` pour retrouver son projet existant, puis
`vercel link --yes --project <nom exact>`. **Attention, `vercel link --project` crée le
projet s'il n'existe pas** : en cas de doute sur le nom, demander.

## 4. Contrôle en ligne (lecture seule)

Sur l'adresse de production (alias stable affiché par `vercel inspect`) :
- avec `playwright-iphone` : la page touchée s'affiche, zéro erreur console, une capture
  regardée ;
- les routes non HTML touchées (export, manifeste, API en lecture) répondent `200` ;
- **aucune écriture** : pas de formulaire envoyé, pas de session créée en production.

## 4 bis. Aligner (une app qui a une liste de faits)

Dans `ironmile`, `qiyam-app` ou toute app faite depuis le starter, si le changement se remarque (ce que l'utilisateur voit ou ce que
fait l'app) : la liste de faits est à jour dans le commit, puis **utiliser la skill `aligner`**
(site, fiches des stores, notes de HQ). Ses corrections et ses demandes vont dans le compte rendu.

## 4 ter. App des stores (Expo) : du build au lancement

Le serveur part comme d'habitude (étapes 1 à 4) : **il part toujours avant l'app**, et ses
réponses ne font que grandir (piège). Ce qui suit vaut pour un projet fait depuis le starter
(`~/Projects/starter`, scripts dans `scripts/`) ; Ironmile est l'exemple complet.

**Un nouveau build pour le téléphone** (changement dans `apps/mobile`) :
- commit d'abord (le numéro de build = nombre de commits), puis `scripts/release-ios.sh` depuis
  la racine : archive, signature, envoi ; le build arrive dans TestFlight (groupe interne) en 5 à
  15 minutes. Jamais d'archive sans le script (l'app viserait localhost).
- Ensuite le build de dev est cassé sur ce Mac : `npx expo prebuild --clean --platform ios` avant
  le prochain `pnpm ios`.
- Dire à Amine quoi tester sur son iPhone une fois le build dans TestFlight.

**La première fois (une app pas encore sur l'App Store)**, dans l'ordre, en demandant à Amine ce
qui exige son compte :
1. App Store Connect, interface web (Amine ou moi avec lui) : l'app (nom, bundle id, SKU), puis
   catégories, classement d'âge (16+, comme les conditions), étiquettes de confidentialité,
   déclaration de dispositif médical. Noter l'id de l'app dans `scripts/store.json`.
2. Module payments : les abonnements et leur groupe dans App Store Connect, l'app et les produits
   dans RevenueCat (clés `EXPO_PUBLIC_REVENUECAT_*` pour l'app, `REVENUECAT_SECRET_KEY` et
   `REVENUECAT_WEBHOOK_SECRET` dans Vercel, webhook vers `/api/webhooks/revenuecat`).
3. La fiche : `docs/store/listing.md` (chaque phrase adossée à `facts.ts`), captures réelles du
   simulateur dans `store/screenshots/raw/`, `node scripts/store-shots.mjs`, puis
   `node scripts/asc-listing.mjs` (lecture) et `--write`.
4. La revue : `node scripts/asc-submit.mjs` vérifie (contact, compte de démo saisis par Amine,
   build traité, abonnements) ; `--submit` soumet avec une sortie **manuelle**. **Les premiers
   abonnements passent par l'interface web** (piège « App Store et RevenueCat »).
5. Approuvée : Amine choisit le jour. Ce jour-là : « Release » dans App Store Connect,
   `APP_STORE_URL` et `APP_STORE_ID` dans `apps/web/lib/launch.ts` (le site et le blog passent de la
   liste d'attente à l'App Store), puis l'e-mail à la liste d'attente.

**Pas encore écrit** (à faire depuis la vraie première fois d'Ironmile, et à reporter ici et dans
le starter) : la sortie **Google Play** (script et fiche) ; **Se connecter avec Apple et Google**.

## 5. Rendre compte

Court, dans la langue de la conversation :
- l'adresse ;
- ce qui a changé pour l'utilisateur ;
- ce qui est vérifié (local + en ligne) ;
- seulement ce qu'il doit tester lui-même sur un vrai téléphone, s'il y en a.
