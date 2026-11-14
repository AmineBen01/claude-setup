---
name: nouveau-projet
description: Lancer un nouveau projet de A à Z jusqu'à une adresse en ligne — site, outil web ou app des stores (iPhone/Android) — cadrage par l'intention (questions jusqu'à ce qu'elle soit claire), plan validé, puis tout d'un coup depuis le starter (~/Projects/starter, scripts/new-app.mjs) - Next.js + shadcn, Expo pour une app, Neon + Drizzle (branche dev pour les tests), comptes, paiements, site et blog, branchement à HQ, GitHub privé, Vercel avec ses variables, CLAUDE.md du projet, première mise en ligne. À utiliser quand l'utilisateur veut créer, démarrer ou « construire » un nouveau site, outil ou app, même s'il ne dit pas « nouveau projet ».
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
Lire `references/design.md` **avant toute interface** : comment concevoir un design sur mesure ; il
n'y a plus de look maison.
Lire `references/apprentissage.md` **avant toute app ou module pour apprendre** (cours, révisions,
quiz) : les principes choisis par Amine, tirés de Briefing.

## 1. Cadrage (règle globale : l'intention d'abord, puis je décide)

Lire d'abord ce qui existe (doc, PDF, maquettes dans le dossier) et apporter ce qu'on y
trouve. Puis, par tours d'AskUserQuestion, en langage simple, **demander l'intention** jusqu'à ce
qu'elle soit limpide :

- **Pourquoi** ce projet : le problème ou l'envie, ce qui doit changer une fois en ligne, à quoi on
  saura que c'est réussi. Pour moi ou pour des utilisateurs (et lesquels) ?
- **Qui** l'utilise, sur quel appareil (téléphone, tablette, ordinateur), où (en
  classe, dans la rue…), avec quelle connexion.
- **Ce qu'ils doivent pouvoir faire**, du point de vue de l'utilisateur ; ce qui compte le plus.
- **Ce qui est à Amine seul** : le nom (il donne le repo, l'adresse `<nom>.vercel.app` et, pour une
  app, le bundle `app.<nom>`), le prix et ce qui reste gratuit s'il y a des paiements, l'échéance,
  ce que la marque impose si elle existe, et **jusqu'à quand le projet servira** (une date, un
  événement, ou « durable ») : elle entre dans sa ligne de la carte (`fin d'usage : AAAA-MM-JJ`).
- **Dépenses** : tout ce qui coûte (domaine, plan payant, clé d'API) se demande à chaque fois.
- **Autorisations dont j'aurai besoin** : envoyer les secrets à Vercel, créer repo, base
  et projet Vercel ; pour une app : projet Expo, app dans App Store Connect, RevenueCat ; pour
  HQ et Studio : une modification des repos `headquarters` et `studio`. Les demander maintenant, pas à la fin.

**Je décide ensuite, et je l'écris dans le plan avec la raison** (sans en faire des questions) :
site / outil web ou app des stores (`--kind web|store` du starter), les modules du README du
starter (comptes, paiements, notifications, site et blog, tableau de bord, branchement à HQ), base
Neon + Drizzle ou pas, l'accès (public, code partagé, et pour quelles actions), l'installation sur
téléphone (skill `pwa`), les écrans et leurs cas limites (erreur, vide, réseau), et **la carte des
tâches** (pour chaque écran, ce qu'on comprend en 5 secondes et la prochaine action,
`references/design.md`), proposée ici avant tout visuel. Rien de plus que ce que le besoin demande.
L'identité visuelle passe dans tous les cas par l'étape « Identité et design » ci-dessous, outils
internes compris.

Puis le plan : l'intention comprise, puis la liste **Décisions validées** ; attendre le feu vert.

## 1 bis. Identité et design (tout projet avec un écran)

Fait pour Ironmile le 20 octobre 2026 ; Amine : « c'est le niveau de travail et d'attention au
détail que j'attends ». Étendu aux sites et aux outils le 1er novembre 2026 : la démarche complète
est dans `references/design.md` (références du domaine, directions, planche combinée). Toujours avec
la skill `frontend-design`, en planches HTML rendues par Chrome sans fenêtre et ouvertes dans
Aperçu :

1. **La marque : 3 directions** tirées du monde du sujet (jamais les looks génériques : crème
   et serif, néon sur noir, dégradés, éclairs). Chaque planche : l'icône en grand et sur un
   écran d'accueil, le mot-symbole, la couleur d'action en clair et en sombre sur un vrai
   écran, l'en-tête de la boutique. **Se critiquer et redessiner avant de montrer.**
2. **Variantes et mélanges des favorites**, testées à 60 et 29 px, en mode sombre, les
   mots-symboles côte à côte ; puis le choix.
3. **3 directions d'interface** sur les mêmes écrans principaux, avec du vrai contenu, sur téléphone
   et 1440 px, précédées de 2 ou 3 références du domaine ; le choix peut se faire écran par écran ;
   une planche combinée pour vérifier que l'ensemble tient ; puis seulement le code.
4. **Tout dans le repo** : `brand/README.md` (les règles du système choisi), les planches
   retenues, les sources SVG et un script qui génère toutes les icônes (iOS : un fichier Icon Composer avec ses variantes sombre et
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
3. **Base** : `apps/web/.env.local` → ce que `apps/web/.env.example` liste sans `#` (la liste des
   variables de l'app, écrite depuis `lib/env-schema.ts` ; le build et le serveur s'arrêtent sur une
   variable absente en la nommant) : chaîne de la branche **dev**, `BETTER_AUTH_SECRET` et, module
   site, `IP_HASH_SALT` (`openssl rand -hex 32` chacun), `BETTER_AUTH_URL` et `APP_URL` =
   `http://localhost:3010`.
   `pnpm db:generate` (les migrations naissent dans le projet : elles dépendent des modules),
   puis `pnpm db:migrate` sur dev **et** sur production (chaîne passée sur la commande).
   `pnpm test` doit passer.
4. **Ce que l'app dit d'elle** : `apps/web/lib/product/app.ts` (la phrase, les plateformes),
   `lib/product/facts.ts` (ses faits, ses règles), chaque `[FILL: …]` (pages légales, blog, bio,
   fiche du store : le test `legal.test.ts` échoue tant qu'il en reste), la section « Project » du
   `CLAUDE.md`, `docs/decisions.md` avec les **Décisions validées**. **Sa ligne dans la carte des
   projets** du CLAUDE.md global (« Mes projets »), avec ce qu'elle lit ou envoie à d'autres projets
   (HQ, Apex…) et sa fin d'usage si elle est limitée : avant le premier push.
5. **L'identité** (étape 1 bis faite) : `brand/mark-*.svg` puis `node scripts/brand-assets.mjs`
   (toutes les icônes), toutes les valeurs dans `apps/web/app/globals.css` et `app/layout.tsx`, et
   `apps/mobile/src/lib/theme.ts` pour une app (clair et sombre), `brand/README.md`. **Le starter
   est une base nue : `pnpm build` échoue** tant que `apps/web/design-direction.json` n'indique pas
   la direction choisie et que le marqueur de base nue reste dans `globals.css`. Ne jamais contourner
   ce contrôle pour mettre en ligne.
6. **Interface web** (skill `frontend-design` et `references/design.md`) : le starter apporte des
   fonctions, pas un look : thème Clair / Sombre / Auto, écrans de comptes, site, blog, cadre du
   tableau de bord, composants shadcn. **Tout se restyle et se recompose selon la direction choisie**,
   y compris la navigation, le tableau de bord et les pages d'arrivée, à partir de la carte des tâches.
   **Pour une app, la barre d'onglets aussi** : icônes dessinées depuis la marque (`brand/tabs/*.svg`,
   `node scripts/tab-icons.mjs`), police des libellés et couleur de l'onglet actif ; le build refuse
   les icônes système.
7. **GitHub** : `gh repo create AmineBen01/<nom> --private --source . --push`. Module hq : secret
   `FACTS_TOKEN` (`security find-generic-password -s hq-facts-token -w | gh secret set
   FACTS_TOKEN`).
8. **Vercel** (équipe sur Pro) : `vercel link --yes --project <nom>` depuis `apps/web`, **Root
   Directory = `apps/web`** sur le projet, `vercel git connect --yes`, région `fra1`
   (`vercel.json`). Variables de production sans les afficher (`vercel env add NOM production <
   <(commande)`) : `DATABASE_URL` (production), et selon les modules `BETTER_AUTH_SECRET`,
   `BETTER_AUTH_URL` et `APP_URL` (**le domaine public**, jamais `*.vercel.app` : piège « Better
   Auth »), `RESEND_API_KEY`, `EMAIL_FROM`, `IP_HASH_SALT` (module site, sa propre valeur), `CRON_SECRET`,
   `REVENUECAT_SECRET_KEY`, `REVENUECAT_WEBHOOK_SECRET` (`.env.example` : tout ce qui est sans `#` ou
   marqué « Required in production », sinon le build de production s'arrête), et si la connexion Google est voulue
   `AUTH_GOOGLE_ID` et `AUTH_GOOGLE_SECRET` (piège « Better Auth »), plus `AUTH_ALLOWED_EMAIL`
   (adresses séparées par des virgules) pour un outil privé à une personne. Un secret que je génère et que j'aurai à
   réutiliser depuis le Mac (`CRON_SECRET` pour appeler une route de maintenance…) va **d'abord dans
   le trousseau** (`security add-generic-password -a <nom> -s <nom>-cron-secret -w "$(openssl rand
   -hex 32)"`), puis dans Vercel depuis le trousseau : Vercel ne le rend jamais (piège « Vercel »).
   Crons : `vercel.json` (Pro), jamais GitHub Actions. Première mise en ligne par un push
   (`pnpm build` d'abord).
9. **HQ et Studio** (module hq) : l'app commence dans `lib/products.ts` de `~/Projects/headquarters`
   (ses chiffres, suivre son `CLAUDE.md`) et de `~/Projects/studio` (ses posts, son blog et ses
   faits, depuis le 12 novembre 2026, suivre son `CLAUDE.md`) ; `db/hq-reader.sql` appliqué aux deux
   branches, mot de passe posé, la chaîne de lecture donnée à HQ ; demandes approuvées et faits
   suivent alors l'app.
10. **App des stores** (module mobile) : projet Expo (`npx eas-cli init` dans `apps/mobile`, compte
    `amineben00`), `npx expo prebuild`, `pnpm ios` sur le simulateur principal, flow
    `m0-account.yaml` passé une fois. Paiements : RevenueCat (app, produits, clé Test Store dans
    `apps/mobile/.env.local`). La suite (App Store Connect, TestFlight, fiche, revue, lancement) :
    `mise-en-ligne`, section « App des stores ».
11. **Mémoire du projet** : noter les ids (projet Neon, branches, projet Vercel, adresse, projet
    Expo, app App Store Connect).

Un site sans aucune donnée (rare) part aussi du starter : retirer `db/` et le dire.

## 3. Construire, vérifier, livrer

Construire les fonctionnalités du plan, puis `verifier` (section 2 bis pour une app, section
« Critique » pour le design), puis
`mise-en-ligne` (section « App des stores » pour une app).
Rendre compte avec l'adresse et seulement ce que l'utilisateur doit tester sur un vrai
appareil.
