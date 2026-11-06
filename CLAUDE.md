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

## La file de Claude : Apex

Décidé le 4 novembre 2026, « HQ décide, Apex planifie » ; une file par projet depuis le 6 novembre.
**Apex** (https://apex.amineben.ch, mon planificateur, `~/Projects/apex`) est ta **seule file de
travail**. Tâches et idées n'y font plus qu'une : chaque projet de code (Qiyam, Ironmile, HQ, Apex) a
sa **file**, ses choses à faire ouvertes (triées par carré, puis par l'ordre que j'ai glissé : une
indication, pas une consigne). Les demandes du growth lead que j'ai approuvées dans HQ y arrivent toutes seules
(« from growth lead »). « Someday » (nouvelles apps, marketing) n'en fait pas partie.

Au début d'une session de travail sur `qiyam-app`, `qiyam-website`, `ironmile`, `headquarters` ou
`apex` :
1. lis la file de ce repo (`~/Projects/apex/docs/claude-api.md`, jeton dans le trousseau :
   `apex-claude-token`) ;
2. annonce-la-moi et traite-la dans l'ordre (questions d'abord, comme pour toute fonctionnalité) ;
   saute celles marquées `held` (« HELD until… » dans les notes) et dis-le ;
3. marque chacune « done » avec une note d'une ligne (commit, ce qui a changé) une fois livrée. Apex
   prévient HQ tout seul.

N'interroge plus les demandes de HQ directement.

## Design : sur mesure, jamais un modèle

Il n'y a plus de look maison : ni Stripe, Linear ou Vercel par défaut, ni police, couleur ou mise en
page imposées. **Avant toute interface, charge la skill `frontend-design` et suis
`~/.claude/skills/nouveau-projet/references/design.md`.** En bref :

- **Nouveau projet, refonte ou grand nouvel écran**, outils internes compris : la carte des tâches
  que je valide (ce qu'on comprend en 5 secondes, la prochaine action), puis 2 ou 3 références du
  domaine, puis **3 directions artistiques sur planches** avec le vrai contenu, le choix écran par
  écran, une planche combinée, et seulement alors le code ; à la fin, un critique indépendant.
- **Petit ajout** : suivre le `brand/README.md` du projet, sans planches.
- **Ce qui reste obligatoire** : mobile d'abord, 44 px tactiles sur téléphone, clair et sombre qui
  suivent l'appareil avec un choix Clair / Sombre / Auto, la largeur des grands écrans mise à profit,
  et jamais enfantin.
- **Le but** : un design qu'on reconnaît sans le logo et une interface où l'on voit tout de suite
  quoi faire. `verifier` contrôle le clair **et** le sombre, sur iPhone, Android et 1440 px, avec une
  console sans erreur d'hydratation.
- **Projets existants** : leur look ne change pas tant que je ne demande pas leur refonte.

## Pas de bouton « Corriger Claude » dans mes apps

Je ne veux pas de canal de corrections intégré aux apps (bouton qui lance une routine, page de
règles) : c'est de la complexité inutile. Pour corriger quelque chose, j'ouvre moi-même une
session Claude dans le cloud depuis mon téléphone. Retiré du studio et de Qiyam HQ le
17 octobre 2026.

## Sous-agents : seulement si le gain est net

Utilise des sous-agents (outil Agent) **uniquement s'ils améliorent nettement la vitesse et la
qualité du résultat**. Une charge grosse ou complexe ne suffit pas à les justifier : dans le
doute, fais le travail toi-même. Quand tu en utilises, tu es le chef d'orchestre : tu découpes le
travail, tu coordonnes et tu garantis la qualité du résultat.

- **Modèle et effort** : aucun choix imposé. Pour chaque tâche, choisis le modèle et l'effort
  qui te semblent les meilleurs, selon ton jugement.
- **Parallélise** ce qui est indépendant : plusieurs agents dans un même message.
- **Brief complet** : l'agent ne sait que ce que tu lui écris. Donne le but, les fichiers, ce
  qui est déjà tranché ou écarté, le périmètre exact et ce qu'il doit te rendre.
- **Garde la main** : le cadrage avec moi (questions jusqu'à accord), les décisions, la
  cohérence entre les morceaux et la vérification finale (`verifier`) restent chez toi. Relis
  ce que les agents rendent avant de l'annoncer ; ne refais pas toi-même un travail confié.
- **Relecture indépendante** pour les grosses fonctionnalités : un agent qui relit le code
  sans ta conclusion, pour un regard non biaisé.
- **Pas d'agent pour une petite tâche** (quelques lectures ou une modification ciblée) : fais-la
  directement, c'est plus rapide et moins cher.
- Pour une mission vraiment énorme (dizaines d'agents), propose-moi un workflow et son coût
  avant de le lancer.

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
- `aligner-carriere` : garder vrais mon site, mes CV, la routine de candidatures et mon LinkedIn
  quand mes projets avancent (routine du lundi ; petit corrigé, gros demandé dans Job HQ).
- `pwa` : rendre un site installable sur téléphone.
- Sur appel seulement : `/transitions-dev`, `/transitions-polish`,
  `/transitions-ui-generation` (animations), `/anatomy` (illustrations isométriques).
