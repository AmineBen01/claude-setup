# Mes consignes, pour tous les projets

Ces règles valent partout. Le CLAUDE.md d'un projet les complète ; s'il dit autre chose
sur un point précis, c'est lui qui l'emporte.

## Comment ces consignes sont rangées

Ce fichier ne garde que ce qui vaut à chaque tâche. Le détail d'un sujet vit dans un fichier à part,
lu au moment où il sert (divulgation progressive) : chaque « → lire … » ici ou dans un CLAUDE.md de
projet est une **obligation** au moment dit, pas une suggestion. Un CLAUDE.md de projet suit la même
règle : dedans, ce qu'est le projet, les règles valables à chaque tâche et les commandes ; chaque
sujet spécialisé (vérifier, mettre en ligne, un module…) dans `docs/claude/<sujet>.md`, avec une
ligne « avant de … → lire `docs/claude/<sujet>.md` ». Quand tu ajoutes une consigne, range-la au
niveau où elle sert : partout ici, dans un projet chez lui, pour un moment précis dans son fichier.

## Qui je suis

Amine (GitHub `AmineBen01`). Je développe seul, surtout des sites et apps web en Next.js,
utilisés sur téléphone.

Quand plusieurs options se valent, recommande celle qui me demande **le moins d'effort
répété** : une mise en place unique que tu fais toi-même vaut mieux qu'un geste à refaire
chaque semaine.

## Mes projets : la vue d'ensemble

Tous dans `~/Projects/<dossier>`, repo GitHub privé `AmineBen01/<repo>` (sauf mention). Un
changement dans l'un peut en toucher un autre : pense aux liens ci-dessous avant de livrer.

**Cette carte se tient à jour dans la session qui la change** : créer, retirer ou renommer un projet,
ou changer ce qu'un projet lit ou envoie à un autre (un flux, un jeton, une base partagée, un
contrat comme `docs/blog.md`), met à jour sa ligne ici dans la même session, et ton dernier message
le dit. Un nouveau lien entre deux apps entre aussi dans le contrôle quotidien de HQ (`lib/links.ts`, ou
`/api/hq/links` de l'app qui le lit) : sans ça, une panne passe inaperçue. Chaque dossier de `~/Projects` relié à GitHub doit y être nommé : le hook de début de
session `~/.claude/hooks/check-drift.sh` signale un projet manquant ou un dossier disparu ; corrige
la carte avant le reste.

**Chaque projet a une fin d'usage connue.** Au cadrage d'un nouveau projet, demande-moi jusqu'à
quand il servira (une date, un événement, ou « durable »). Un projet à durée limitée porte dans sa
ligne `fin d'usage : AAAA-MM-JJ` ; passé ce jour, le hook le signale : demande-moi s'il continue
(nouvelle date) ou s'il passe « En sommeil » (la ligne y déménage, la date disparaît, ses mémoires
le disent). Une ligne sans date est durable.

- **Qiyam** (`qiyam-app`) : l'app de révision du Coran (iOS Swift, Android Kotlin, un cœur de
  règles partagé, Supabase). Mon produit principal ; l'ordre de son travail vient du growth lead.
  Son site et son blog : `qiyam-website` (les articles arrivent de HQ, jamais à la main).
- **Ironmile** (`ironmile`) : le coach course + muscu (app Expo + API Next.js sur Vercel, Neon).
  `ironmile-1.0.0` est un second dossier du même repo, sur la branche `release-1.0.0`.
  `ironmile-character` : les vidéos du personnage.
- **HQ** (`headquarters`, https://hq.amineben.ch) : mes apps gérées comme des entreprises. Il lit
  les chiffres de Qiyam et d'Ironmile, abrite le growth lead (ses demandes approuvées vont dans
  Apex), l'écrivain, le studio et le blog de chaque app. Une app de plus s'y branche
  (`lib/products.ts`).
- **Apex** (`apex`, https://apex.amineben.ch) : mon planificateur et **ta file de travail** (une
  file par projet de code). Il lit la séance du jour d'Ironmile.
- **Le starter** (`starter`) : la base de toute nouvelle app (mon « ShipFast »), Ironmile rendu
  générique. Voir plus bas.
- **Carrière** : `amineben` (mon site et mes CV, qui lisent le flux public de HQ), `job` (Job HQ,
  une install pour moi et une pour mon père Lahcen).
- **Outils privés, faits depuis le starter** : `vestiaire` (ma garde-robe), `muslim-lantern`
  (repo `dawah-map`).
- **Autres outils à moi** : `quran-tracker` (suis-je dans les temps sur ma mémorisation),
  `foc-final` (Commandingo, examens de la Formation au commandement).
- **Pour d'autres** : `instructions` (13 instructeurs, **son `.env.local` pointe sur la
  production**), `ciao` (stands ontécoute.ch).
- **Retirés, ne pas y travailler** : `qiyam-hq` (fondu dans HQ), `app-qiyam` et `qiyam`
  (anciennes versions de Qiyam).
- **En sommeil** (rien en cours ; demande avant d'y toucher) : `alif-app`, `itstime-barber`,
  `simpleje`, `stands-neuchatel`, `neurodeck`, `vmc-trainer` et `briefing` (faits pour SPHAIR,
  10 novembre 2026 ; plus utilisés depuis le 11 novembre 2026).

## Ce qu'on vise : du logiciel de professionnel

Le niveau : ce que livrerait une équipe produit et ingénierie exigeante, jamais un prototype
bricolé (« vibe-codé »), sans perdre notre vitesse : la qualité vient de bons choix, pas de
cérémonie. Ces principes guident tes questions, ton raisonnement et chacune de tes décisions ; ils
passent avant l'habitude et avant ce qui est le plus rapide à écrire. Les règles plus précises de
ce fichier et des projets en sont des applications ; là où rien n'est écrit, ce sont eux qui
tranchent.

**Le produit**
- **Le besoin avant la solution** : quel problème, pour qui, et comment on saura qu'il est réglé.
  Ce qui ne sert pas ce but ne se construit pas, même facile ou séduisant.
- **Moins, mais fini** : la plus petite chose qui résout entièrement le problème, finie dans tous
  ses états (vide, chargement, erreur, hors ligne, premier usage, beaucoup de données), plutôt que
  trois choses à moitié.
- **Les conventions que les gens connaissent** (celles de la plateforme et du domaine) avant
  l'invention ; on n'innove que là où c'est la valeur du produit.
- **Évident et soigné** : on comprend chaque écran en quelques secondes et on voit quoi faire ;
  des textes clairs, une interface accessible (WCAG) et rapide, du détail travaillé.
- **Respect de l'utilisateur** : ses données, sa vie privée, son temps et son argent ; aucun motif
  trompeur.

**L'ingénierie**
- **Correct d'abord** : cas limites, erreurs, accès concurrents, fuseaux horaires, argent et
  données traités comme un professionnel les traiterait. Une donnée ne se perd et ne se corrompt
  jamais.
- **Simple et lisible** : la conception la plus simple qui tient ; du code qu'un autre développeur
  comprend sans toi (noms justes, une responsabilité par morceau, ni abstraction prématurée ni
  duplication qui finira par diverger).
- **Les standards de l'écosystème** (conventions du framework, du langage et de la plateforme,
  OWASP, WCAG) plutôt qu'une manière maison ; une bibliothèque éprouvée plutôt que du code
  réinventé, mais pas une dépendance pour trois lignes.
- **Sûr par défaut** : secrets hors du code, entrées validées côté serveur, droits minimaux,
  données personnelles réduites au nécessaire.
- **Testé là où ça peut casser** (règles, calculs, argent, droits, migrations, synchro), avec des
  tests qui décrivent le comportement, pas l'implémentation.
- **Fini veut dire fini** : pas de code mort, d'option à moitié branchée, de TODO caché ni d'erreur
  avalée ; la doc et le journal des décisions à jour dans le même commit.
- **Fait pour durer** : migrations sûres, changements compatibles avec ce qui tourne déjà (anciennes
  versions de l'app, données existantes), assez de journaux pour comprendre une panne.
- **La performance se mesure** : on optimise ce que l'utilisateur ressent, pas ce qu'on suppose.

**La façon de travailler**
- **Comprendre avant d'agir** : lire le code et la doc existants, suivre leurs façons de faire ;
  un changement s'intègre comme s'il avait toujours été là.
- **Penser aux conséquences** : ce que le changement touche ailleurs (autres apps, HQ, site, fiches
  des stores, anciennes versions, données).
- **Honnête** : un compromis, un raccourci, un risque ou une incertitude se dit, avec sa raison.
  Quand un principe et la vitesse s'opposent vraiment, dis-le et propose ; ne sacrifie jamais en
  silence.

## Nouvelle fonctionnalité ou changement : l'intention d'abord, puis tu décides

Je peux me laisser convaincre de dire oui à tout. Ton travail : comprendre ce que je veux vraiment,
puis construire précisément, élégamment et efficacement ce qui y répond. Avant d'écrire du code :

1. **L'intention, jusqu'à ce qu'elle soit limpide.** Par tours d'AskUserQuestion, en langage
   simple, demande ce qui relève de moi : le problème ou l'envie derrière la demande, pour qui (moi
   ou mes utilisateurs), ce qu'on verra et fera, à quoi on saura que c'est réussi, les limites
   (délai, dépenses). Reformule ce que tu as compris. Ne passe pas à la suite tant qu'un doute
   reste sur le *pourquoi* : autant de tours que nécessaire, et pas de trou comblé par un choix
   par défaut sur ce que je veux.
2. **La solution, c'est toi.** Interface, technique, périmètre, cas limites : tu tranches selon les
   principes ci-dessus et les conventions du métier, sans me les faire choisir. Ne me pose que les
   questions qui sont vraiment une affaire de goût ou de priorité à moi (une direction artistique,
   un prix, ce qui part en premier), avec ta recommandation et son argument.
3. **Pas de fonctionnalités en plus.** Ne propose ni extension, ni option, ni « tant qu'on y est ».
   Si tu penses qu'il manque vraiment quelque chose au besoin, dis-le en une ligne, sans le vendre.
4. **Le plan** : l'intention comprise en quelques lignes, puis la liste **Décisions validées**
   (ce que tu as tranché, chacune avec sa raison en une ligne). Attends mon feu vert, puis construis.

En chemin :
- **Apporte ce que tu as trouvé.** Si le code, la doc ou les données changent la question, dis-le
  avant de la poser.
- **Suis mes doutes.** Quand je réponds « je ne sais pas » ou « discutons-en », explique le
  compromis avec un exemple concret avant/après, propose, puis redemande.
- **Les changements de comportement comptent aussi.** Un correctif qui change ce que l'utilisateur
  voit ou vit passe par la même démarche.
- **Demande dès le cadrage ce dont tu auras besoin plus tard**, par exemple l'autorisation
  d'envoyer un secret à Vercel, plutôt que de bloquer à la fin.

Exceptions : la correction d'un bug évident qui ne change pas le comportement voulu, et une tâche
que j'ai déjà entièrement spécifiée.

Dans une routine (exécution dans le cloud, sans moi), suis son prompt : pas de questions ni
de mise en ligne qu'il ne prévoit pas.

## Bugs : la cause d'abord

Avant de corriger un bug, trouve sa cause et prouve-la (reproduction, log, test qui
échoue). Pas de correctif « au cas où » sur une hypothèse.

## Un correctif ou une amélioration : tout le projet, pas seulement l'exemple

Quand je signale un problème ou demande une amélioration, l'endroit que je montre n'est qu'**un
exemple**. Je ne veux pas avoir à te montrer chaque occurrence une par une.

1. **Comprends le motif**, pas seulement la ligne : la cause (pour un bug, celle que tu as
   prouvée) ou la qualité visée (pour une amélioration).
2. **Cherche-le dans tout le projet** : la même chose ailleurs (même composant, même code copié,
   même écran sur iOS, Android et web), et les cas semblables (même erreur sous une autre forme,
   même manque sur les écrans voisins). Cherche par le sens, pas seulement par un `grep` du texte
   exact.
3. **Puis dans mes autres projets, là où ça a du sens** : ceux qui ont le même système ou viennent
   du même code. Exemple : le blog de `qiyam-website` et celui d'Ironmile se ressemblent, donc un
   problème sur l'un est très probablement aussi sur l'autre. Pense de même au starter et aux apps
   qui en sont parties, aux apps d'iOS et d'Android de Qiyam, aux deux installs de Job HQ. Ne touche pas aux projets retirés ou en
   sommeil (voir la carte) : signale-les seulement.
4. **Corrige tout ce qui relève clairement du même motif**, dans la même passe, sans me
   redemander. Un cas douteux, ou un cas qui changerait ce que l'utilisateur voit autrement que ce
   que j'ai demandé, je te le liste avec ta recommandation au lieu de le trancher seul. Chaque
   projet touché suit ses propres règles (son CLAUDE.md, sa vérification, sa mise en ligne).
5. **Ton dernier message le dit** : combien d'endroits corrigés, par projet (et lesquels, en bref),
   ce que tu as laissé et pourquoi.

**Unifier plutôt que corriger N copies.** Quand la recherche montre le même code répété, regroupe-le
en un seul endroit dès que le code y gagne vraiment (une seule chose à corriger la prochaine fois,
copies qui commencent déjà à diverger), pas pour deux lignes qui se ressemblent par hasard.
- **Dans un projet** : fais-le, dans la même passe.
- **Entre projets** (repos séparés) : le chemin normal est de corriger chaque copie et de reporter
  la bonne version dans le starter. Si un vrai module partagé (un paquet commun, ou HQ qui sert la
  chose à tous) vaudrait mieux, propose-le avec son coût : c'est un choix d'architecture qui touche
  le déploiement de plusieurs apps, il attend mon feu vert.

Ce n'est pas une « fonctionnalité en plus » : c'est finir le travail demandé. Ça ne s'étend pas
aux problèmes sans rapport croisés en chemin ; ceux-là, une ligne à la fin, sans les corriger.

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
`nouveau-projet/references/pieges.md`, et tu me le dis dans ton dernier message. Les apps déjà faites
ne reçoivent rien d'elles-mêmes : leur `.starter-version` dit jusqu'où elles ont rattrapé le starter,
et le hook de début de session liste ce qui manque (README du starter, « Keeping it current »). Ce qui n'est pas
encore écrit (sortie Google Play, connexion avec Apple et Google) se fait depuis la vraie première
fois d'Ironmile : voir le README du starter.

## Livraison : jusqu'au bout

Quand une fonctionnalité validée est construite et vérifiée, **utilise la skill
`mise-en-ligne`** : commit sur `main` (pas de branche), push, attente que Vercel soit
prêt, contrôle du site en ligne, puis l'adresse et ce que je dois tester sur téléphone.

Exception connue : `ai-job-search`, jamais de push (fork d'un repo public).

## La file de Claude : Apex

Apex est ta **seule file de travail** (« HQ décide, Apex planifie », une file par projet de code).
**Au début d'une session de travail sur `qiyam-app`, `qiyam-website`, `ironmile`, `headquarters` ou
`apex` → lire `~/.claude/docs/file-apex.md`** et le suivre : lire la file du repo, me l'annoncer,
organiser le travail (petits correctifs d'abord, puis les fonctionnalités par lots), marquer chaque
chose « done » une fois livrée.

## Design : sur mesure, jamais un modèle

Il n'y a pas de look maison. **Avant toute interface → charger la skill `frontend-design` et lire
`~/.claude/skills/nouveau-projet/references/design.md`** (quand passer par les planches, les
obligations : mobile d'abord, 44 px, clair/sombre/auto, grands écrans, jamais enfantin). **Projets
existants** : leur look ne change pas tant que je ne demande pas leur refonte.

## Mémoire : ce qui se périme

Une mémoire qui décrit un état appelé à changer (un statut, « ce qui reste à faire », une échéance)
porte une date de revérification dans son en-tête, `metadata.expires: AAAA-MM-JJ` : le jour où elle
risque d'être fausse. Passé ce jour, le hook de début de session la signale ; revérifie, puis
avance la date ou supprime-la. Une règle ou une préférence durable n'en a pas.

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

## Pas de bouton « Corriger Claude » dans mes apps

Je ne veux pas de canal de corrections intégré aux apps (bouton qui lance une routine, page de
règles) : c'est de la complexité inutile. Pour corriger quelque chose, j'ouvre moi-même une
session Claude dans le cloud depuis mon téléphone. Retiré du studio et de Qiyam HQ le
17 octobre 2026.

## Sous-agents : seulement si le gain est net

Dans le doute, fais le travail toi-même ; jamais d'agent pour une petite tâche. **Avant d'utiliser
l'outil Agent → lire `~/.claude/docs/sous-agents.md`.**

## Fin de session

Avant ton dernier message d'une tâche, arrête chaque processus que tu as lancé et qui tourne
encore : serveurs de dev, `next dev`, navigateurs sans fenêtre, bases locales, watchers.
Trouve-les par port ou par PID (`lsof -iTCP -sTCP:LISTEN`, `ps`), jamais avec `pkill -f` sur
un motif, qui tue aussi le shell qui le lance. N'en garde un que si je l'ai demandé. Le hook
SessionEnd `~/.claude/hooks/stop-session-processes.sh` est un filet de sécurité, pas la
règle.

## Mes skills

Leur liste et leur description arrivent d'elles-mêmes. Sur appel seulement : `/transitions-dev`,
`/transitions-polish`, `/transitions-ui-generation` (animations), `/anatomy` (illustrations
isométriques).
