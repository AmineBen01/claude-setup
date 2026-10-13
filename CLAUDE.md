# Mes consignes, pour tous les projets

Ces règles valent partout. Le CLAUDE.md d'un projet les complète ; s'il dit autre chose
sur un point précis, c'est lui qui l'emporte.

## Qui je suis

Amine (GitHub `AmineBen01`). Je développe seul, surtout des sites et apps web en Next.js,
utilisés sur téléphone.

Quand plusieurs options se valent, recommande celle qui me demande **le moins d'effort
répété** : une mise en place unique que tu fais toi-même vaut mieux qu'un geste à refaire
chaque semaine.

## Nouvelle fonctionnalité ou changement : poser des questions jusqu'à accord

Quand je demande une nouvelle fonctionnalité, ou un changement à une fonctionnalité
existante — simple ou complexe — pose des questions **avant d'écrire du code**, tour
après tour, jusqu'à ce que ce qu'il faut construire soit parfaitement clair et
explicitement validé par nous deux. Pas après la première réponse, et pas en comblant
les trous avec un choix par défaut raisonnable.

- **Utilise AskUserQuestion** : quelques questions ciblées par tour, autant de tours que
  nécessaire.
- **Langage simple.** Demande ce que l'utilisateur verra et fera, pas quelles tables ou
  quels composants. Ne passe au technique que quand le choix l'est vraiment, et
  explique-le simplement même alors.
- **Recommande.** Mets en premier l'option que tu choisirais, avec la raison en une
  ligne. Montre une petite maquette quand la question porte sur une mise en page.
- **Apporte ce que tu as trouvé.** Si le code, la doc ou les données changent la
  question, dis-le avant de la poser.
- **Suis mes doutes.** Quand je réponds « je ne sais pas » ou « discutons-en », explique
  le compromis avec un exemple concret avant/après, propose, puis redemande.
- **Les changements de comportement comptent aussi.** Un correctif qui change ce que
  l'utilisateur voit ou vit passe par la même boucle.
- **Demande dès le cadrage ce dont tu auras besoin plus tard**, par exemple
  l'autorisation d'envoyer un secret à Vercel, plutôt que de bloquer à la fin.
- Seulement quand tout est tranché : écris le plan avec une liste **Décisions
  validées**, attends mon feu vert, puis construis.

Exceptions : la correction d'un bug évident qui ne change pas le comportement voulu, et
une tâche que j'ai déjà entièrement spécifiée.

## Bugs : la cause d'abord

Avant de corriger un bug, trouve sa cause et prouve-la (reproduction, log, test qui
échoue). Pas de correctif « au cas où » sur une hypothèse.

## Vérification : par le vrai chemin, en autonomie, une seule fois

C'est à toi de prouver que ce que tu as construit marche, sans me demander de tester à
ta place. **Aucune annonce de réussite sans preuve.**

- **Utilise la skill `verifier`** à la fin de chaque fonctionnalité (sauf tout petit
  changement) : tests, puis le vrai parcours dans un navigateur que tu pilotes (Playwright,
  tailles iPhone et Android), en regardant les captures.
- **Une seule passe, à la fin.** Typecheck, lint, tests et build une fois, pas après
  chaque fichier. Ne relance pas une commande qui vient de passer.
- **Un contrôle de bout en bout** qui passe par le vrai chemin vaut mieux que dix `grep`
  ciblés.
- **Ne revérifie pas ce qu'un outil garantit déjà.** `tsc` qui passe veut dire que les
  types collent ; un `Edit` réussi veut dire que la modification est appliquée — ne
  relis pas le fichier pour le confirmer.
- **Ne teste pas une mécanique qui vient avec ses propres garanties** (garde de
  migration, `on conflict`…), sauf si tu viens de la modifier.
- **Vérifie le comportement que je remarquerai**, pas la plomberie interne.
- Pas de script jetable pour rejouer de la logique déjà couverte par les tests.
- **Ne touche jamais aux données de production pour tester** : en local, la base est une
  copie de dev (branche Neon « dev ») ; en ligne, tu ne fais que regarder.
- Ne me demande que ce qui exige vraiment un appareil réel (installer l'app, mode avion…),
  et dis clairement ce qui n'est pas vérifié.

## GitHub, Neon et Vercel : c'est toi qui gères

Tu crées les repos (GitHub privé), les bases (Neon, région Francfort) et les projets
Vercel, tu règles leurs variables d'environnement et tu mets en ligne. Je ne veux pas
d'étape « à toi d'importer dans Vercel ».

## Livraison : jusqu'au bout

Quand une fonctionnalité validée est construite et vérifiée, **utilise la skill
`mise-en-ligne`** : commit sur `main` (pas de branche), push, attente que Vercel soit
prêt, contrôle du site en ligne, puis l'adresse et ce que je dois tester sur téléphone.

Exception connue : `ai-job-search`, jamais de push (fork d'un repo public).

## Mes skills

- `nouveau-projet` : d'une idée à une adresse en ligne (cadrage, puis tout d'un coup).
- `verifier` : la preuve que ça marche, par le vrai chemin.
- `mise-en-ligne` : commit, push, Vercel, contrôle en ligne.
- `pwa` : rendre un site installable sur téléphone.
- Sur appel seulement : `/transitions-dev`, `/transitions-polish`,
  `/transitions-ui-generation` (animations), `/anatomy` (illustrations isométriques).
