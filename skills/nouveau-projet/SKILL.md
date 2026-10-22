---
name: nouveau-projet
description: Lancer un nouveau projet web de A à Z jusqu'à une adresse en ligne — cadrage par questions jusqu'à accord, plan validé, puis tout d'un coup - Next.js + shadcn adapté au tactile, pnpm, GitHub privé, base Neon + Drizzle si le projet stocke des données (branche dev pour les tests), Vercel avec ses variables, CLAUDE.md du projet, première mise en ligne. À utiliser quand l'utilisateur veut créer, démarrer ou « construire » un nouveau site, outil ou app web, même s'il ne dit pas « nouveau projet ».
---

# Nouveau projet

Deux temps : d'abord on se met d'accord, ensuite je fais tout d'un coup, jusqu'à une
adresse en ligne. L'utilisateur n'a aucune étape technique à faire.

Lire `references/pieges.md` **avant d'écrire du code** : tous les pièges déjà rencontrés.
Lire `references/design.md` **avant toute interface** : le style que je veux.

## 1. Cadrage (règle globale : questions jusqu'à accord)

Lire d'abord ce qui existe (doc, PDF, maquettes dans le dossier) et apporter ce qu'on y
trouve. Puis, par tours d'AskUserQuestion, en langage simple, avec une recommandation :

- **Qui** l'utilise, sur quel appareil (téléphone, tablette, ordinateur), où (en
  classe, dans la rue…), avec quelle connexion.
- **Ce qu'ils font et voient**, écran par écran ; les cas limites (erreur, vide, réseau).
- **Données à garder ?** Si oui : base Neon + Drizzle. Si non : pas de base.
- **Accès** : public, ou code d'accès partagé (variable d'environnement), et pour quelles
  actions (lire, écrire, modifier, supprimer).
- **Nom** du projet : il donne le repo et l'adresse `<nom>.vercel.app`.
- **Installation sur téléphone** souhaitée ? Si oui, skill `pwa` dans le plan.
- **Outil ou app grand public ?** Un outil suit `references/design.md` tel quel ; une app
  grand public y ajoute un système d'identité (voir « Outil ou app grand public » dans
  `references/design.md`).
- **Identité visuelle** : si la marque existe, ses couleurs, sa police et sa **palette
  sombre** ; sinon, l'étape « Identité » ci-dessous, avant toute interface.
- **Échéance** et première version testable.
- **Autorisations dont j'aurai besoin** : envoyer les secrets à Vercel, créer repo, base
  et projet Vercel. Les demander maintenant, pas à la fin.

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

1. **Next.js** : générer dans le scratchpad (le dossier du projet n'est pas vide),
   `pnpm create next-app@latest <tmp> --ts --tailwind --eslint --app --no-src-dir
   --import-alias "@/*" --use-pnpm --turbopack --yes`, puis rapatrier sans
   `node_modules/.next/.git`. Ranger les documents de départ dans `docs/`.
   Renommer le paquet, `git init -b main`, `pnpm install`.
2. **CLAUDE.md du projet** : `@AGENTS.md` en première ligne, puis les sections
   « Projet » (but, utilisateurs, échéance), « Commandes », « Vérifier » (port, parcours
   clés, base dev), « Mise en ligne » (projet Vercel, adresse, variables, migrations),
   « Pièges » propres au projet. Ne pas recopier les règles globales.
3. **shadcn** : `pnpm dlx shadcn@latest init -y -d`, ajouter seulement les composants
   utiles, agrandir les tailles pour le tactile (voir pièges). Couleurs et police du
   projet en variables CSS dans `app/globals.css`.
4. **Base (si données)** via le MCP Neon :
   - projet `<nom>`, région `aws-eu-central-1`, Postgres 17 ;
   - branche `main` = production ; créer une branche `dev` ;
   - `.env.local` → chaîne de la branche **dev** ; la chaîne de `main` va seulement
     dans Vercel ;
   - Drizzle : `db/schema.ts`, `db/index.ts`, `drizzle.config.ts`, `db/seed.ts`,
     scripts `db:generate`, `db:migrate`, `db:seed` ; migrer et seeder dev **et** main.
5. **Interface (toute app avec un écran)**, avec la skill `frontend-design` et le style de
   `references/design.md` (jetons de couleur, Geist, tailles de boutons, statuts) :
   - `next-themes` avec `defaultTheme="system"`, les couleurs sombres, un choix
     Clair / Sombre / Auto dans l'en-tête et dans les réglages, `themeColor` par schéma ;
   - le cadre du tableau de bord : `sidebar` shadcn (repliable en icônes, compteurs sur les
     entrées) à partir de `md`, en-tête et onglets en bas en dessous ; la barre latérale ne
     s'ouvre jamais en panneau mobile, et son encart est une `<div>` parce que chaque page
     rend son propre `<main>` ;
   - **le haut de la barre latérale vient du modèle** `references/modeles/sidebar-top.tsx`
     (bouton de repli dans la barre, logo carré qui devient le bouton d'ouverture au survol) et
     `SidebarMenu` en `gap-0.5` : voir « Barre latérale » dans `references/design.md` ;
   - des pages pensées aussi pour 1440 px : colonne latérale, grilles, scène avec panneau.
6. **Tests** : `vitest` pour la logique pure (règles métier, calculs), script `test`.
7. **GitHub** : `gh repo create AmineBen01/<nom> --private --source . --push`.
8. **Vercel** :
   - `vercel link --yes --project <nom>` (crée le projet) ;
   - variables de production sans les afficher :
     `vercel env add NOM production < <(commande)` ;
   - `vercel.json` avec `"regions": ["fra1"]` si base à Francfort ;
   - `vercel git connect --yes` (chaque push redéploie) ;
   - première mise en ligne : `vercel deploy --prod --yes`.
9. **Mémoire du projet** : noter les ids (projet Neon, branches, projet Vercel, adresse).

## 3. Construire, vérifier, livrer

Construire les fonctionnalités du plan, puis `verifier`, puis `mise-en-ligne`.
Rendre compte avec l'adresse et seulement ce que l'utilisateur doit tester sur un vrai
appareil.
