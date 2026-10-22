---
name: mise-en-ligne
description: Livrer jusqu'au bout une fonctionnalité vérifiée d'un projet web — commit sur main, push GitHub, attente du déploiement Vercel (et migration de la base de production si le schéma a changé), contrôle en lecture seule du site en ligne, puis l'adresse et la courte liste de tests à faire sur téléphone. À utiliser après `verifier`, ou quand l'utilisateur dit « mets en ligne », « déploie », « pousse », « livre ».
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

Dans `ironmile` ou `qiyam-app`, si le changement se remarque (ce que l'utilisateur voit ou ce que
fait l'app) : la liste de faits est à jour dans le commit, puis **utiliser la skill `aligner`**
(site, fiches des stores, notes de HQ). Ses corrections et ses demandes vont dans le compte rendu.

## 5. Rendre compte

Court, dans la langue de la conversation :
- l'adresse ;
- ce qui a changé pour l'utilisateur ;
- ce qui est vérifié (local + en ligne) ;
- seulement ce qu'il doit tester lui-même sur un vrai téléphone, s'il y en a.
