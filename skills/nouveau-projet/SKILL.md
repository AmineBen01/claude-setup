---
name: nouveau-projet
description: Lancer un nouveau projet web de A à Z jusqu'à une adresse en ligne — cadrage par questions jusqu'à accord, plan validé, puis tout d'un coup - Next.js + shadcn adapté au tactile, pnpm, GitHub privé, base Neon + Drizzle si le projet stocke des données (branche dev pour les tests), Vercel avec ses variables, CLAUDE.md du projet, première mise en ligne. À utiliser quand l'utilisateur veut créer, démarrer ou « construire » un nouveau site, outil ou app web, même s'il ne dit pas « nouveau projet ».
---

# Nouveau projet

Deux temps : d'abord on se met d'accord, ensuite je fais tout d'un coup, jusqu'à une
adresse en ligne. L'utilisateur n'a aucune étape technique à faire.

Lire `references/pieges.md` **avant d'écrire du code** : tous les pièges déjà rencontrés.

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
- **Échéance** et première version testable.
- **Autorisations dont j'aurai besoin** : envoyer les secrets à Vercel, créer repo, base
  et projet Vercel. Les demander maintenant, pas à la fin.

Puis le plan avec la liste **Décisions validées** ; attendre le feu vert.

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
5. **Tests** : `vitest` pour la logique pure (règles métier, calculs), script `test`.
6. **GitHub** : `gh repo create AmineBen01/<nom> --private --source . --push`.
7. **Vercel** :
   - `vercel link --yes --project <nom>` (crée le projet) ;
   - variables de production sans les afficher :
     `vercel env add NOM production < <(commande)` ;
   - `vercel.json` avec `"regions": ["fra1"]` si base à Francfort ;
   - `vercel git connect --yes` (chaque push redéploie) ;
   - première mise en ligne : `vercel deploy --prod --yes`.
8. **Mémoire du projet** : noter les ids (projet Neon, branches, projet Vercel, adresse).

## 3. Construire, vérifier, livrer

Construire les fonctionnalités du plan, puis `verifier`, puis `mise-en-ligne`.
Rendre compte avec l'adresse et seulement ce que l'utilisateur doit tester sur un vrai
appareil.
