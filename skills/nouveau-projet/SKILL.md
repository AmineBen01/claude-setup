---
name: nouveau-projet
description: Lancer un nouveau projet de A à Z jusqu'à une adresse en ligne — site, outil web ou app des stores (iPhone/Android) — cadrage par questions jusqu'à accord, plan validé, puis tout d'un coup depuis le starter (~/Projects/starter, scripts/new-app.mjs) - Next.js + shadcn, Expo pour une app, Neon + Drizzle (branche dev pour les tests), comptes, paiements, site et blog, branchement à HQ, GitHub privé, Vercel avec ses variables, CLAUDE.md du projet, première mise en ligne. À utiliser quand l'utilisateur veut créer, démarrer ou « construire » un nouveau site, outil ou app, même s'il ne dit pas « nouveau projet ».
---

# Nouveau projet

Deux temps : d'abord on se met d'accord, ensuite je fais tout d'un coup, jusqu'à une
adresse en ligne. L'utilisateur n'a aucune étape technique à faire.

**Tout part du starter** (`~/Projects/starter`, GitHub `AmineBen01/starter`, décidé le
22 octobre 2026) : ce dont Ironmile a eu besoin avant sa première fonctionnalité, rendu générique
et prouvé. Lire son `README.md` (les modules, ce qui n'est pas encore écrit) avant le cadrage.
**Une leçon qui vaut pour toutes les apps retourne dans le starter dans la même session**
(`pnpm check:modules` passe), et le dernier message le dit.

Lire `references/pieges.md` **avant d'écrire du code** : tous les pièges déjà rencontrés.
Lire `references/design.md` **avant toute interface** : le style que je veux.

## 1. Cadrage (règle globale : questions jusqu'à accord)

Lire d'abord ce qui existe (doc, PDF, maquettes dans le dossier) et apporter ce qu'on y
trouve. Puis, par tours d'AskUserQuestion, en langage simple, avec une recommandation :

- **Site / outil web, ou app des stores ?** (une app qu'on installe depuis l'App Store, avec son
  site). C'est le `--kind web|store` du starter.
- **Les modules** (README du starter) : comptes, paiements (prix, essai, ce qui reste gratuit),
  notifications, site de lancement et blog (HQ), tableau de bord web, branchement à HQ. Les
  proposer selon ce qui a été dit, avec la valeur par défaut recommandée.
- **Qui** l'utilise, sur quel appareil (téléphone, tablette, ordinateur), où (en
  classe, dans la rue…), avec quelle connexion.
- **Ce qu'ils font et voient**, écran par écran ; les cas limites (erreur, vide, réseau).
- **Données à garder ?** Si oui : base Neon + Drizzle. Si non : pas de base.
- **Accès** : public, ou code d'accès partagé (variable d'environnement), et pour quelles
  actions (lire, écrire, modifier, supprimer).
- **Nom** du projet : il donne le repo, l'adresse `<nom>.vercel.app` et, pour une app, le bundle
  `app.<nom>`. Un domaine à soi est une dépense : demander.
- **Installation sur téléphone** souhaitée ? Si oui, skill `pwa` dans le plan.
- **Outil ou app grand public ?** Un outil suit `references/design.md` tel quel ; une app
  grand public y ajoute un système d'identité (voir « Outil ou app grand public » dans
  `references/design.md`).
- **Identité visuelle** : si la marque existe, ses couleurs, sa police et sa **palette
  sombre** ; sinon, l'étape « Identité » ci-dessous, avant toute interface.
- **Échéance** et première version testable.
- **Autorisations dont j'aurai besoin** : envoyer les secrets à Vercel, créer repo, base
  et projet Vercel ; pour une app : projet Expo, app dans App Store Connect, RevenueCat ; pour
  HQ : une modification du repo `headquarters`. Les demander maintenant, pas à la fin.
- **Dépenses** : tout ce qui coûte (domaine, plan payant, clé d'API) se demande à chaque fois.

Puis le plan avec la liste **Décisions validées** ; attendre le feu vert.

## 1 bis. Identité (marque à créer, ou app grand public)

Fait pour Ironmile le 20 octobre 2026 ; Amine : « c'est le niveau de travail et d'attention au
détail que j'attends ». Toujours avec la skill `frontend-design`, en planches HTML rendues par
Chrome sans fenêtre et ouvertes dans Aperçu :

1. **La marque : 3 directions** tirées du monde du sujet (jamais les looks génériques : crème
   et serif, néon sur noir, dégradés, éclairs). Chaque planche : l'icône en grand et sur un
   écran d'accueil, le mot-symbole, la couleur d'action en clair et en sombre sur un vrai
   écran, l'en-tête de la boutique. **Se critiquer et redessiner avant de montrer.**
2. **Variantes et mélanges des favorites**, testées à 60 et 29 px, en mode sombre, les
   mots-symboles côte à côte ; puis le choix.
3. **App grand public : 3 directions d'interface** sur les mêmes écrans principaux, avec du vrai
   contenu ; le choix peut se faire écran par écran ; une planche combinée pour vérifier que
   l'ensemble tient ; puis seulement le code.
4. **Tout dans le repo** : `brand/README.md` (les règles), les sources SVG et un script qui
   génère toutes les icônes (iOS : un fichier Icon Composer avec ses variantes sombre et
   teintée, vérifiées avec `ictool` ; Android ; favicon ; site).

## 2. Socle (après le feu vert)

Lire d'abord `references/pieges.md` (sections du web, et « App native », « Maestro », « App Store
et RevenueCat » pour une app).

1. **Base Neon d'abord** (MCP Neon) : projet `<nom>`, région `aws-eu-central-1`, Postgres 17 ;
   branche principale = production ; créer une branche `dev`. Noter l'id de l'endpoint de `dev`
   (`ep-…`).
2. **Le projet, depuis le starter** (dans `~/Projects/starter`, à jour avec `git pull`) :
   `node scripts/new-app.mjs --name "<Nom>" --kind web|store [--with …] [--without …]
   [--domain …] --dev-endpoint <ep-dev>` crée `~/Projects/<nom>`, avec ses modules, renommé, et
   son `CLAUDE.md`. Puis dans le projet : `git init -b main`, `pnpm install`.
3. **Base** : `apps/web/.env.local` → chaîne de la branche **dev**, `BETTER_AUTH_SECRET`
   (`openssl rand -hex 32`), `BETTER_AUTH_URL` et `APP_URL` = `http://localhost:3010`.
   `pnpm db:generate` (les migrations naissent dans le projet : elles dépendent des modules),
   puis `pnpm db:migrate` sur dev **et** sur production (chaîne passée sur la commande).
   `pnpm test` doit passer.
4. **Ce que l'app dit d'elle** : `apps/web/lib/product/app.ts` (la phrase, les plateformes),
   `lib/product/facts.ts` (ses faits, ses règles), chaque `[FILL: …]` (pages légales, blog, bio,
   fiche du store : le test `legal.test.ts` échoue tant qu'il en reste), la section « Project » du
   `CLAUDE.md`, `docs/decisions.md` avec les **Décisions validées**.
5. **L'identité** (étape 1 bis faite) : `brand/mark-*.svg` puis `node scripts/brand-assets.mjs`
   (toutes les icônes), `--primary` dans `apps/web/app/globals.css` et `action` dans
   `apps/mobile/src/lib/theme.ts` (clair et sombre), police de marque (`--font-display-face` dans
   `app/layout.tsx`, `font.display` côté app), `brand/README.md`.
6. **Interface web** (skill `frontend-design` et `references/design.md`) : le starter a déjà le
   thème (next-themes, Clair / Sombre / Auto dans l'en-tête et les réglages), le cadre du tableau
   de bord (barre latérale du modèle `references/modeles/sidebar-top.tsx`, onglets en bas sur
   téléphone) et les composants shadcn de HQ ; ajouter seulement ce que le projet demande, et des
   pages pensées aussi pour 1440 px.
7. **GitHub** : `gh repo create AmineBen01/<nom> --private --source . --push`. Module hq : secret
   `FACTS_TOKEN` (`security find-generic-password -s hq-facts-token -w | gh secret set
   FACTS_TOKEN`).
8. **Vercel** (équipe sur Pro) : `vercel link --yes --project <nom>` depuis `apps/web`, **Root
   Directory = `apps/web`** sur le projet, `vercel git connect --yes`, région `fra1`
   (`vercel.json`). Variables de production sans les afficher (`vercel env add NOM production <
   <(commande)`) : `DATABASE_URL` (production), et selon les modules `BETTER_AUTH_SECRET`,
   `BETTER_AUTH_URL`, `APP_URL`, `RESEND_API_KEY`, `EMAIL_FROM`, `CRON_SECRET`,
   `REVENUECAT_SECRET_KEY`, `REVENUECAT_WEBHOOK_SECRET`. Crons : `vercel.json` (Pro), jamais
   GitHub Actions. Première mise en ligne par un push (`pnpm build` d'abord).
9. **HQ** (module hq) : dans `~/Projects/headquarters`, l'app commence dans `lib/products.ts`
   (suivre son `CLAUDE.md`) ; `db/hq-reader.sql` appliqué aux deux branches, mot de passe posé, la
   chaîne de lecture donnée à HQ ; demandes approuvées et faits suivent alors l'app.
10. **App des stores** (module mobile) : projet Expo (`npx eas-cli init` dans `apps/mobile`, compte
    `amineben00`), `npx expo prebuild`, `pnpm ios` sur le simulateur principal, flow
    `m0-account.yaml` passé une fois. Paiements : RevenueCat (app, produits, clé Test Store dans
    `apps/mobile/.env.local`). La suite (App Store Connect, TestFlight, fiche, revue, lancement) :
    `mise-en-ligne`, section « App des stores ».
11. **Mémoire du projet** : noter les ids (projet Neon, branches, projet Vercel, adresse, projet
    Expo, app App Store Connect).

Un site sans aucune donnée (rare) part aussi du starter : retirer `db/` et le dire.

## 3. Construire, vérifier, livrer

Construire les fonctionnalités du plan, puis `verifier` (section 2 bis pour une app), puis
`mise-en-ligne` (section « App des stores » pour une app).
Rendre compte avec l'adresse et seulement ce que l'utilisateur doit tester sur un vrai
appareil.
