# Performance : les deux points critiques à relire

Résumé maison des deux catégories « CRITICAL » de vercel-labs/agent-skills
(react-best-practices). Le reste (re-renders, micro-optimisations) est en grande partie
géré par le React Compiler activé dans mes projets Next 16 : ne pas le chasser.

## 1. Pas de requêtes en cascade (waterfalls)

- Des lectures indépendantes partent ensemble : `Promise.all([...])`, pas des `await`
  successifs.
- Un composant serveur ne doit pas attendre une donnée dont il n'a pas besoin pour
  commencer : lancer la promesse tôt, l'attendre là où elle sert.
- Dans une boucle (une requête par élément), regrouper en une seule requête (`in (...)`,
  jointure) ou paralléliser.
- Une vérification bon marché (paramètre absent, droit refusé) passe **avant** un `await`
  coûteux.
- Le contenu lent est enveloppé dans `<Suspense>` pour que le reste de la page s'affiche
  sans l'attendre.

## 2. Pas de code inutile envoyé au navigateur (bundle)

- `"use client"` le plus bas possible dans l'arbre : une page entière cliente embarque
  tout ce qu'elle importe.
- Une grosse bibliothèque utilisée rarement (graphiques, éditeur, export) se charge à la
  demande : `import()` / `next/dynamic`.
- Importer le module précis plutôt qu'un fichier « barrel » qui réexporte tout.
- Les scripts tiers (analytics…) se chargent après l'interactivité.
- Rien de serveur (clé, client de base de données) ne doit pouvoir être importé côté
  client : `import "server-only"` dans ces modules.
