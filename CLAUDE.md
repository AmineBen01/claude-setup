# Mes consignes, pour tous les projets

Ces règles valent partout. Le CLAUDE.md d'un projet les complète ; s'il dit autre chose
sur un point précis, c'est lui qui l'emporte.

## Qui je suis

Amine (GitHub `AmineBen01`). Je développe seul, surtout des sites et apps web en Next.js,
utilisés sur téléphone.

Quand plusieurs options se valent, recommande celle qui me demande **le moins d'effort
répété** : une mise en place unique que tu fais toi-même vaut mieux qu'un geste à refaire
chaque semaine.

## Mes captures d'écran

Quand je parle d'une capture d'écran (« je t'ai mis une capture », « regarde le screenshot »),
elle est sur le Mac dans
`~/Library/Mobile Documents/com~apple~CloudDocs/Capture d'écran/`, nommée
`Screenshot AAAA-MM-JJ at HH.MM.SS.png`. Ce sont en général la ou les dernières : liste le
dossier par date (`ls -t`), prends celles qui correspondent au moment de mon message, et
ouvre-les avec Read. Dans une session cloud ce dossier n'existe pas : dis-le et demande-moi
de coller l'image.

## Me montrer une image

Je travaille dans Ghostty : je ne vois pas les images dans le terminal. Chaque fois que tu veux
me montrer une image (icône, capture, maquette, graphique), ouvre-la dans Aperçu sur le Mac avec
`open <fichier>` (plusieurs fichiers d'un coup si tu compares des variantes), puis dis-moi dans
quel ordre elles sont. Dans une session cloud, donne plutôt le lien ou le chemin.

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

Dans une routine (exécution dans le cloud, sans moi), suis son prompt : pas de questions ni
de mise en ligne qu'il ne prévoit pas.

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

Mon équipe Vercel est sur le plan **Pro** depuis le 20 octobre 2026 (je compte le garder) :
usage commercial permis, crons Vercel sans la limite d'un par jour du plan Hobby. Ne contourne
plus ces limites (GitHub Actions pour les crons, etc.) dans un nouveau projet.

## Le starter : chaque nouvelle app en part

Tout nouveau projet (site, outil web, app des stores) part de `~/Projects/starter` (GitHub
`AmineBen01/starter`), via la skill `nouveau-projet` : comptes, paiements, site, blog, HQ, scripts
de sortie iOS, déjà faits et prouvés. **Quand un projet m'apprend quelque chose qui vaut pour
toutes les apps** (un piège, un correctif, une meilleure façon de faire), **tu le reportes dans le
starter dans la même session** (`pnpm check:modules` doit passer) et dans
`nouveau-projet/references/pieges.md`, et tu me le dis dans ton dernier message. Ce qui n'est pas
encore écrit (sortie Google Play, connexion avec Apple et Google) se fait depuis la vraie première
fois d'Ironmile : voir le README du starter.

## Livraison : jusqu'au bout

Quand une fonctionnalité validée est construite et vérifiée, **utilise la skill
`mise-en-ligne`** : commit sur `main` (pas de branche), push, attente que Vercel soit
prêt, contrôle du site en ligne, puis l'adresse et ce que je dois tester sur téléphone.

Exception connue : `ai-job-search`, jamais de push (fork d'un repo public).

## Les demandes de Claude dans HQ

HQ (https://hq.amineben.ch, `~/Projects/headquarters`) réunit les chiffres et les posts de mes
apps ; le « growth lead » y dépose des demandes de fonctionnalités et de correctifs, que
j'approuve. Au début d'une session de travail sur `headquarters`, `ironmile`, `qiyam-app` ou
`qiyam-website`, regarde les demandes **approuvées** pour ce repo
(`~/Projects/headquarters/docs/lead-api.md`, jeton dans le trousseau : `hq-lead-token`),
annonce-les-moi et traite-les en premier, puis marque chacune « faite » une fois livrée.

## Design par défaut

Toute app avec un écran, sauf avis contraire :
- **Charge la skill `frontend-design` avant d'écrire la moindre interface**, nouvelle ou
  remaniée, **et suis mon style : `~/.claude/skills/nouveau-projet/references/design.md`**.
  En bref : un outil précis et sobre (Linear, Vercel, Notion), Geist, surfaces neutres, une
  seule couleur d'action, le contenu porte la couleur ; des listes à filets plutôt que des
  cartes, statuts en point + mot, coins de 6 à 8 px, pas d'ombres ni de blocs de couleur
  pleine, boutons de 44 px sur téléphone et 36 px sur ordinateur. Jamais de pilules ni de
  look « mignon » : je l'ai jugé enfantin.
- **Mode sombre** qui suit l'appareil, avec un choix Clair / Sombre / Auto dans l'en-tête et
  dans les réglages : `next-themes` (`attribute="class"`, `defaultTheme="system"`), des
  gris neutres sans teinte (charbon doux en sombre, voir `design.md`), la marque seulement
  sur l'action et les données, `themeColor` par schéma de couleurs.
- **App grand public** (qu'on ouvre pour soi, comme Ironmile) : la même base sobre **plus un
  système d'identité** (police de marque pour titres et chiffres, composant signature, motif,
  voix, une seule surface de couleur de marque, un seul mouvement orchestré), décidé sur planches
  avant de coder. Voir « Outil ou app grand public » dans `design.md` et l'étape « Identité »
  de `nouveau-projet`. Sans le logo, on doit reconnaître l'app sur une capture.
- **Un tableau de bord shadcn professionnel** : barre latérale repliable sur l'ordinateur (à la
  ChatGPT : bouton de repli dans la barre, logo carré qui devient le bouton d'ouverture au
  survol, interstice entre les entrées ; modèle dans `nouveau-projet`), en-tête et onglets en
  bas sur le téléphone ; cartes, tableaux et graphiques là où les
  données le méritent, dans l'identité de la marque.
- **La largeur des grands écrans sert** : une colonne principale et une colonne latérale,
  des grilles, une scène avec un panneau à partir de `lg`. Jamais une colonne étroite seule
  au milieu d'un écran de 1440 px. Toujours **mobile d'abord** : le téléphone, puis
  l'élargissement.
- `verifier` contrôle le clair **et** le sombre, sur iPhone, Android et 1440 px, avec une
  console sans erreur d'hydratation.

## Pas de bouton « Corriger Claude » dans mes apps

Je ne veux pas de canal de corrections intégré aux apps (bouton qui lance une routine, page de
règles) : c'est de la complexité inutile. Pour corriger quelque chose, j'ouvre moi-même une
session Claude dans le cloud depuis mon téléphone. Retiré du studio et de Qiyam HQ le
17 octobre 2026.

## Fin de session

Avant ton dernier message d'une tâche, arrête chaque processus que tu as lancé et qui tourne
encore : serveurs de dev, `next dev`, navigateurs sans fenêtre, bases locales, watchers.
Trouve-les par port ou par PID (`lsof -iTCP -sTCP:LISTEN`, `ps`), jamais avec `pkill -f` sur
un motif, qui tue aussi le shell qui le lance. N'en garde un que si je l'ai demandé. Le hook
SessionEnd `~/.claude/hooks/stop-session-processes.sh` est un filet de sécurité, pas la
règle.

## Mes skills

- `nouveau-projet` : d'une idée à une adresse en ligne, site ou app des stores (cadrage, puis tout
  d'un coup, depuis le starter).
- `verifier` : la preuve que ça marche, par le vrai chemin (navigateur, ou simulateur pour une app).
- `mise-en-ligne` : commit, push, Vercel, contrôle en ligne ; pour une app, TestFlight, fiche, revue
  et lancement.
- `aligner` : après un changement visible dans une app, remettre d'accord avec ses faits le site,
  les fiches des stores et les notes de HQ (appelée par `mise-en-ligne`).
- `pwa` : rendre un site installable sur téléphone.
- Sur appel seulement : `/transitions-dev`, `/transitions-polish`,
  `/transitions-ui-generation` (animations), `/anatomy` (illustrations isométriques).
