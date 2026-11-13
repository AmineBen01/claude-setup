# Pièges connus (appris sur de vrais projets)

## Next.js 16 (Cache Components activé par défaut)

- **Lire la doc embarquée** avant d'écrire du code : `node_modules/next/dist/docs/`
  (`AGENTS.md` le rappelle). L'API a changé par rapport aux souvenirs d'entraînement.
- **Toute lecture dynamique doit être sous `<Suspense>`** : base de données, `cookies()`,
  `headers()`, `searchParams`, `params`. Sinon le build échoue (« blocking route »).
  Patron : la page rend le cadre statique et un `<Suspense fallback>` autour d'un
  composant async qui lit les données.
- **`usePathname()` dans un layout** casse le prérendu des routes dynamiques
  (`/x/[id]`) : isoler le composant qui l'utilise dans un `<Suspense>`.
- **`Date.now()`, `Math.random()`, `crypto.randomUUID()` pendant le rendu** : refusés par
  le lint (React Compiler, règle de pureté) et par le prérendu. Les calculer dans un
  gestionnaire d'événement, un `useState(() => …)`, ou après `await connection()`.
- **`setState` dans un `useEffect`** est signalé par le lint. Pour du code qui lit
  `localStorage` : rendre le composant seulement côté client via
  `useSyncExternalStore(() => () => {}, () => true, () => false)`, puis lire le stockage
  dans l'initialiseur de `useState`.
- Après une action serveur qui modifie la page courante : `refresh()` de `next/cache`.
- **Une action serveur qui lance une erreur perd son message en production** (Next le remplace
  par un message générique). Un `catch` côté écran ne sait donc pas pourquoi : Apex affichait
  « Check the connection » pour des notes trop longues (12 novembre 2026). Patron : l'action
  rattrape les refus (zod, « introuvable ») et **renvoie** `{ refused: "la raison" }` ; l'écran
  affiche cette raison, « hors ligne » seulement si `navigator.onLine === false`, sinon « ça n'est
  pas passé ». Apex : `lib/refused.ts`, `act` dans `lib/actions.ts`, `lib/call.ts`.
- Les route handlers `GET` qui lisent la base sont dynamiques d'office : rien à faire.
- **Cache de build Turbopack** (`.next/cache/turbopack`, activé par défaut, conservé par
  Vercel) : il a déjà resservi un ancien `globals.css` (variables du thème absentes du CSS
  produit). Mettre `experimental.turbopackFileSystemCacheForBuild: false` et, après un
  changement de thème, vérifier le CSS produit (`grep <nouvelle variable> .next/static/chunks/*.css`).
- **La règle Turbopack de Tailwind sur `*.css` casse les modules CSS** : pour ce qui sort de
  Tailwind (diapositives, impression), du CSS global simple avec un préfixe.
- `create-next-app` refuse un dossier non vide : générer dans le scratchpad, puis
  `rsync -a --exclude node_modules --exclude .next --exclude .git`.

## États d'enregistrement et cookies

- **« Enregistré » doit vouloir dire « ce qui est affiché est en base »**, pas « l'objet
  existe en base ». Après une modification qui échoue puis un rechargement, l'écran ne
  doit pas prétendre le contraire : garder un indicateur séparé (ex. `synced`), remis à
  faux à chaque nouvel envoi.
- Cookies : `secure: process.env.VERCEL === "1"` (et non `NODE_ENV === "production"`),
  sinon Safari les refuse quand on teste le build de production en `http://localhost`.
- Fenêtre de choix sur téléphone : ne pas donner le focus au champ de recherche quand
  elle s'ouvre au doigt (le clavier masque la liste) — Base UI :
  `initialFocus={(type) => (type === "touch" ? listRef.current : true)}`. Même chose pour
  toute fenêtre ou panneau qui contient un champ (sinon le clavier de l'iPhone le couvre) :
  `initialFocus={(type) => type === "keyboard" || type === "mouse"}`.
- **Dates dans un composant client** : jamais `toLocaleDateString` (Node écrit « Fri 16 Oct »,
  les navigateurs « Fri, 16 Oct » : l'hydratation échoue). Formater avec des noms de mois et
  de jours écrits à la main.
- **Nombres décimaux** : `Intl.NumberFormat("fr-CH")` donne « 6,5 » dans Node mais « 6.5 »
  dans Safari. Écrire la virgule à la main (`toFixed(1).replace(".", ",")`).
- Tri alphabétique français : `Intl.Collator("fr-CH")` en JS ; Postgres classe les
  lettres accentuées après « z ».
- Textes cachés des composants shadcn (« Close »…) : les traduire.

## shadcn/ui (style par défaut « base-nova »)

- Construit sur **Base UI**, pas Radix : composer avec la prop `render={<Button />}`, pas
  `asChild`. `cn` vient du paquet `cn`.
- Tailles par défaut trop petites pour le tactile (boutons 32 px, texte 14 px) :
  agrandir dans `components/ui/button.tsx` et `input.tsx` (h-11, `text-base`).
- Le composant `command` (cmdk) est pensé pour le bureau ; pour un choix dans une liste
  sur téléphone, une fenêtre (`Dialog`) avec recherche et grandes lignes marche mieux.
- `AlertDialogAction` ne ferme pas la fenêtre tout seul : piloter `open`.
- **`Button` Base UI rendu en lien** (`render={<Link />}`) : ajouter `nativeButton={false}`.
- **Haut de la `sidebar` shadcn** (défaut répété sur deux projets) : le `SidebarTrigger` mis dans
  l'en-tête de la page laisse un trait (`Separator`) bizarre et sort le bouton de la barre ; un
  logo `img` dans un `SidebarMenuButton` est écrasé en largeur une fois replié (`size-8! p-2!`) ;
  `SidebarMenu` en `gap-0` colle le gris du survol à celui de l'entrée active. Utiliser
  `references/modeles/sidebar-top.tsx` et `gap-0.5`.
- **`sidebar` shadcn** : son panneau mobile, décidé dans le navigateur, casse l'hydratation
  d'une barre latérale streamée (ne jamais l'utiliser, le téléphone a des onglets) ; son
  `SidebarInset` est un `<main>`, imbriqué dans celui de chaque page : en faire une `<div>`.

## Safari iOS

- **Champs `type="date"`** : ils dépassent de leur colonne. Ajouter `min-w-0`,
  `appearance-none`, `block`, et `[&::-webkit-date-and-time-value]:text-left` ; `min-w-0`
  aussi sur l'élément de grille parent.
- `crypto.randomUUID()` n'existe qu'en HTTPS (pas en test sur le réseau local en HTTP) :
  prévoir un repli `crypto.getRandomValues`.
- Encoche et barre d'accueil : `viewportFit: "cover"` + `env(safe-area-inset-*)` sur
  l'en-tête, les barres fixes et les marges latérales.
- Icônes d'écran d'accueil en mode sombre : iOS les assombrit lui-même, un site ne peut
  rien y faire.
- **Un contenu affiché dans un `<button>`** (aperçu cliquable, carte qu'on touche pour l'ouvrir)
  hérite du `text-align: center` que WebKit met aux boutons : fixer `text-align` sur la racine du
  contenu, sinon l'aperçu ne ressemble plus à l'original (vu sur l'aperçu des slides de HQ).
- **`line-clamp-*` sur un `<button>` est ignoré par WebKit** (vu le 4 novembre 2026, vue Semaine
  d'Apex) : le titre s'étalait sur 8 lignes. Mettre le `line-clamp` sur un `<span>` à l'intérieur du
  bouton.
- **`field-sizing: content`** (la classe `field-sizing-content` du `Textarea` shadcn) n'existe pas dans
  les Safari plus anciens : le champ reste à sa hauteur de départ. Garder un repli qui règle la hauteur
  sur `scrollHeight` quand `CSS.supports("field-sizing", "content")` est faux (Apex,
  `components/ui/textarea.tsx`, 6 novembre 2026). Un titre à éditer sur téléphone : `Textarea rows={1}`
  qui grandit, Entrée qui enregistre, plutôt qu'un `Input` d'une ligne.
- **Les suggestions du navigateur** (anciennes saisies sous un champ) gênent dans un outil : mettre
  `autoComplete="off"` par défaut dans le composant `Input` de l'app, les formulaires de connexion
  gardant leurs propres valeurs.

## Base de données (Neon + Drizzle)

- Driver `drizzle-orm/neon-http`, `import "server-only"` dans `db/index.ts`.
- `drizzle.config.ts` : `process.loadEnvFile(".env.local")` dans un `try`.
- Seed en `tsx --env-file=.env.local db/seed.ts`, code dans une fonction `main()`
  (pas de `await` au niveau du module dans un projet CommonJS). Le seed ne doit pas
  importer `db/index.ts` (qui contient `server-only`).
- Id d'enregistrement généré côté client + `onConflictDoNothing` : un « Réessayer » ne
  crée pas de doublon.
- Suppression récupérable (`deleted_at`) plutôt que `DELETE` quand l'utilisateur peut
  supprimer.
- **`drizzle-kit migrate` peut échouer en silence** (code de sortie 1, seuls les NOTICE s'affichent,
  aucune migration appliquée) : faire de `pnpm db:migrate` un petit script `tsx db/migrate.ts` avec
  le `migrate()` de `drizzle-orm/postgres-js/migrator`, qui affiche l'erreur SQL (modèle : Qiyam HQ).
- **Un rôle créé par l'API Neon (MCP `create_postgres_role`, console) est membre de
  `neon_superuser`** : il lit et écrit tout, et on ne peut pas le lui retirer en SQL. Pour un
  utilisateur restreint (lecture seule, analyste) : `create role … login password '…'` en SQL,
  puis `reset_postgres_role_password` par l'API pour que Neon garde le mot de passe et que
  `run_sql` puisse l'utiliser avec `role_name`. Vérifier `pg_auth_members` avant d'accorder quoi
  que ce soit.
- Le MCP Neon refuse (garde-fou) les `UPDATE`/`DELETE` sans cible précise : cibler par id.
- **Dans une session cloud, Postgres en TCP (port 5432) est bloqué** : `pnpm db:migrate` échoue
  (connexion qui expire). Appliquer la migration par HTTPS : MCP Neon `run_sql_transaction` avec les
  instructions du fichier (séparées par `--> statement-breakpoint`), plus la ligne de
  `drizzle.__drizzle_migrations` (`hash` = sha256 du fichier, `created_at` = `when` du journal), dans
  la même transaction. Lire d'abord les lignes existantes pour copier leur format (Job HQ, 23 octobre
  2026).

## Vercel

- `vercel ls` et la plupart des tableaux du CLI s'écrivent sur **stderr** : `2>&1`.
- `vercel link --yes --project <nom>` **crée** le projet s'il n'existe pas.
- `vercel link` ajoute `VERCEL_OIDC_TOKEN` à `.env.local` : sans danger, ignoré par git.
- `vercel.json` avec `"regions": ["fra1"]` quand la base Neon est à Francfort.
- Envoyer un secret sans l'afficher : `vercel env add NOM production < <(commande)`.
- **Une variable « Secret » (sensible) ne se relit jamais** : `vercel env pull` écrit un masque
  (`[redacted]`), pas la valeur. Un secret qu'on devra réutiliser depuis le Mac (appeler une route
  de maintenance avec `CRON_SECRET`…) se garde dans le trousseau dès sa création ; sinon il faut le
  remplacer (`vercel env update NOM production` avec la valeur sur l'entrée standard) puis
  redéployer (`vercel redeploy <url>`). Vu sur HQ le 2026-10-29.
- **Web Analytics sur le plan Pro : pas de `?ref=` par l'API** (vu le 2026-10-29 sur HQ) : l'API
  répond 402 aux dimensions UTM (Enterprise ou l'option « Web Analytics Plus »). Pour savoir d'où
  viennent les visiteurs, un **drain Web Analytics** (`vercel api /v1/drains -X POST --input -`,
  schéma `analytics` v1, livraison `http` JSON signée HMAC-SHA1 dans `x-vercel-signature`,
  échantillonnage 1) vers une route de l'app, qui garde `queryParams`. Pas d'historique avant sa
  création. **`queryParams` arrive en objet JSON** (`{"ref":"tiktok"}`), pas en chaîne de requête
  comme dans l'exemple de la doc : le lire comme tel. Le script de `@vercel/analytics` se charge depuis un chemin au hasard
  (`/<hash>/script.js`, puis `POST /<hash>/view`), pas `/_vercel/insights` : chercher ça pour
  vérifier qu'une visite part.

## Tâches planifiées

- **Le `schedule` de GitHub Actions n'est pas ponctuel** : sur un repo peu actif, des exécutions
  arrivent avec des heures de retard ou sautent (Qiyam HQ : « toutes les heures » → 5 exécutions
  en 13 h). Planifier deux essais par heure si l'endpoint ignore un doublon, et rafraîchir aussi à
  l'ouverture de l'app quand la donnée est vieille (`after()` dans le layout).
- Équipe Vercel sur Pro (depuis le 20 octobre 2026) : les crons Vercel (`vercel.json`, `CRON_SECRET`)
  n'ont plus la limite d'une par jour ; les préférer à GitHub Actions, aussi pour une tâche déjà
  en place dont l'heure se remarque (Ironmile : « toutes les 30 min » → une exécution toutes les
  4,6 h, la semaine du coach encore absente à 20 h 15 un dimanche ; passée à Vercel le 1er novembre 2026).
- **Un cron toutes les 5 minutes, toute la semaine, garde la base Neon éveillée** : elle s'endort après
  5 minutes sans requête, donc environ 180 heures de calcul par mois à 0,25 CU, au-delà des quelque
  100 du plan gratuit (chiffre de mémoire, à revérifier). Resserrer le cron sur les heures utiles (Ironmile : dimanche soir).

## Actions serveur : tester sans navigateur (secours)

Les ids d'actions sont dans `.next/server/server-reference-manifest.json`. Appel :
`POST <page>` avec les en-têtes `Next-Action: <id>`, `Accept: text/x-component`,
`Content-Type: text/plain;charset=UTF-8`, corps = tableau JSON des arguments. Le
résultat est la ligne qui commence par `1:`. Écrire ce genre de test en Node (`fetch`),
pas en bash (guillemets).

## Routines cloud et processus

- **Jamais `pnpm test | grep … && git push`** : le `grep` qui trouve la ligne « Tests » renvoie 0
  même quand des tests échouent, et la chaîne pousse (vu le 26 octobre 2026). Lire le résultat,
  puis committer dans une commande à part.
- **Des tests lourds en calcul (balayages de milliers de cas) affament les tests de base de données
  lancés en parallèle** : délais de 30 s au hasard. Les mettre dans un projet Vitest à part qui passe
  d'abord (`projects` + `sequence.groupOrder`), pas les retirer.

- **Une routine cloud n'atteint que les domaines autorisés** : un run échoue avec
  `fetch failed` ou un `403` du proxy (`CONNECT tunnel failed`) tant que l'accès réseau de
  l'environnement n'autorise pas le domaine de l'app. Ce n'est pas le jeton.
- **Une tâche planifiée créée depuis une session (`create_trigger`) n'emporte pas les connecteurs**
  (Neon, Gmail…) : elle tourne sans, et tout appel au connecteur échoue. Les ajouter à la tâche dans
  l'interface des tâches planifiées de claude.ai, et le dire à Amine en la créant (« Carrière :
  aligner », 23 octobre 2026).
- **Arrêter un serveur de dev** : par port ou PID (`lsof -t -iTCP:3000 -sTCP:LISTEN`).
  `pkill -f "next dev"` tue aussi le shell qui le lance.

## Better Auth

- **`BETTER_AUTH_URL` = le domaine public** (`https://<app>.app`), jamais l'adresse `*.vercel.app` :
  Better Auth ne fait confiance qu'à sa propre origine, donc une connexion ou une réinitialisation
  postée depuis une page du vrai domaine est refusée « Invalid origin » (Ironmile, 28 octobre 2026 :
  le site web et la page de réinitialisation étaient cassés sans qu'on le voie, l'app native passait
  par `ironmile://`). Vérifier en ligne : `POST /api/auth/sign-in/email` avec `Origin` du domaine doit
  répondre 401 (mauvais identifiants), pas 403.
- **Connexion Google** (module `accounts`, du starter depuis Apex, 4 novembre 2026) : le client OAuth
  se crée dans le projet GCP `headquarters-509211` (Google Auth Platform → Clients → Web application ;
  redirections `<domaine>/api/auth/callback/google` et `http://localhost:3010/api/auth/callback/google`).
  Le secret ne s'affiche qu'une fois : trousseau `<app>-google-client-secret`, puis Vercel
  (`AUTH_GOOGLE_ID`, `AUTH_GOOGLE_SECRET`). Le champ `consent` de Better Auth doit rester
  `required: false`, sinon toute inscription Google échoue (« consent is required ») ; le hook
  l'exige à la place.

- Sur le driver HTTP de Neon : pas de transaction interactive, donc l'adaptateur tourne avec
  `transaction: false` (son défaut). Nos écritures sur plusieurs tables passent par `db.batch([...])`.
- Ses tables sont générées : `pnpm dlx auth@<version> generate --config lib/auth.ts --output
  db/auth-schema.ts --yes`, avec `import "server-only"` commenté dans `db/index.ts` pendant
  l'exécution (le CLI ne sait pas le charger) et `DATABASE_URL` exportée. **Relire le diff de
  `auth-schema.ts` avant `db:generate`** (Apex, 4 novembre 2026) : le CLI réécrit tout le fichier et
  perd ce qu'on y a réglé à la main (`consent` y redevenait sans défaut ni `not null`, et la migration
  aurait modifié la table `user` en production). Remettre la ligne, puis générer.
- `after()` lève une erreur hors requête : les tests qui appellent les handlers directement la
  font échouer. Le travail en arrière-plan passe par un `later()` qui l'ignore sous Vitest (starter :
  `apps/web/lib/later.ts`).

## App native (Expo) : serveurs et build

- **Lancer les serveurs de dev en tâche de fond de l'outil, jamais avec `&`** dans une commande :
  ils meurent avec elle au bout d'un moment (Metro et l'API disparus en plein test : « No script
  URL provided », puis « Can't load your account »).
- **Jamais Metro avec `CI=1`** : la surveillance des fichiers est coupée et l'app tourne en silence
  avec du vieux code.
- **Port 3000 souvent pris par un autre projet** : l'API d'une app tourne sur 3010 et l'app vise ce
  port par défaut. Ne jamais tuer un serveur qu'on n'a pas lancé.
- **Tester sur un vrai iPhone : `pnpm phone` (`next start --keepAliveTimeout 120000`), pas `next
  dev`.** `next dev` ferme les connexions inactives après 5 s ; l'iPhone les réutilise, iOS
  relance les lectures mais pas les écritures, donc la première écriture après une pause pendait.
  Metro avec `EXPO_PUBLIC_API_URL=http://<IP Wi-Fi du Mac>:3010`.
- **Après un archive de release (`release-ios.sh`), le build de dev casse** : l'archive tourne en
  Release dans le même `ios/` et laisse les parties précompilées en version release. Symptômes :
  `Undefined symbols … Sealable::Sealable()` au lien, puis des plantages au lancement. Ne pas
  bricoler pièce par pièce : `npx expo prebuild --clean --platform ios` puis `expo run:ios`
  (~15 min). DerivedData n'y est pour rien.
- **Santé et notifications sont natives** : tout changement de leurs plugins dans `app.json`
  demande `npx expo prebuild --clean` et un nouveau build de dev, sur les deux plateformes.
- **Faire viser un autre port de Metro à un build de dev sans `expo-dev-client`** (plusieurs
  sessions en parallèle, chacune son Metro) : le build lit `RCT_jsLocation` dans les préférences
  de son conteneur. `defaults write` simple écrit à côté et rien ne change (« No script URL
  provided ») ; passer par le démon du simulateur avec le chemin du conteneur : `xcrun simctl spawn
  <udid> defaults write <conteneur data>/Library/Preferences/<bundle id> RCT_jsLocation
  localhost:8083` (conteneur : `xcrun simctl get_app_container <udid> <bundle id> data`), puis
  relancer l'app. Supprimer la clé à la fin (vu le 28 octobre 2026 sur Ironmile).
- **Ne pas descendre le `compileSdk` d'Android sous celui d'Expo** (SDK 58 : 37). Health Connect
  n'a besoin que de `minSdkVersion: 26` (`expo-build-properties`).
- `npx expo install <paquet>` toujours (versions accordées au SDK).
- **`expo lint` garde en cache les imports non résolus** : après l'ajout d'un paquet, il peut
  encore dire « Unable to resolve path to module » alors que `tsc` et `npx eslint` passent.
  `npx expo lint --no-cache` une fois (vu le 22 octobre 2026 sur Ironmile).
- **`expo-background-task` affiche un bandeau d'avertissement sur le simulateur iOS**, par-dessus
  la barre d'onglets : il gêne les taps de Maestro, ce n'est pas un bug de l'app.
- **Builds sur appareil** : HealthKit et les notifications ne passent pas par un profil wildcard ;
  la première fois `xcodebuild … -allowProvisioningUpdates`, installation avec `xcrun devicectl
  device install app`. `expo run:ios --device` veut l'UDID matériel (`xcrun xctrace list devices`).
- Le numéro de build d'une release vient du script (`EXPO_PUBLIC_BUILD`, nombre de commits), pas
  d'un module natif : l'écran « Mettre à jour » marche sans reconstruire le client de dev.
- **Hors ligne : garder aussi le compte, pas seulement les données** (Ironmile, 6 novembre 2026). L'app
  gardait la semaine sur le téléphone, mais `MeProvider` attendait `/api/me` au lancement : en mode
  avion, « Can't load your account » couvrait tout. Une app qui promet le hors-ligne garde aussi la
  réponse de `/api/me` (par compte, effacée à la déconnexion), l'utilise sur tout échec sauf 401, et
  redemande au retour au premier plan. Le starter n'a pas de mode hors ligne : à ajouter avec lui.
- **`npx expo install` dans `apps/mobile` peut casser l'API d'à côté** (Ironmile, 6 novembre 2026) :
  un paquet qui devient pair d'`expo` (ici `expo-widgets`) change l'empreinte de tout ce qui dépend
  d'expo, `better-auth` compris (via `@better-auth/expo`) ; le lien de `apps/api/node_modules`
  pointe alors vers un dossier disparu (« Cannot find module 'better-auth' »). Remède : `pnpm install`
  à la racine, puis relancer typecheck et tests de l'API.
- **Widgets et Live Activities : `expo-widgets`** (module Expo, SDK 58 ; mises en page en JS avec
  `@expo/ui/swift-ui`, directive `'widget'`, rien du module ni de hooks dans la fonction). Les
  données se calculent dans l'app (fonction pure testée) et le widget ne fait que dessiner ; un
  `require` paresseux limité à iOS évite d'importer le module natif sur Android. Le compte à rebours
  d'une Live Activity se donne en deux dates (`Text timerInterval`) : iOS l'anime seul, app fermée.
  **Finir une Live Activity avec `end('immediate')`** : la politique par défaut laisse la dernière
  bannière jusqu'à 4 heures sur l'écran verrouillé. Ajouter l'extension = `expo prebuild --clean`
  et un nouveau build (TestFlight), jamais une mise à jour OTA.

## App native : écrans et navigation

- **Le navigateur racine doit s'afficher dès la première image** (l'écran de lancement le couvre).
  Ne rien afficher pendant le chargement de la session perd le lien d'un démarrage à froid : le
  lien de réinitialisation ouvrait l'écran de connexion.
- **`/` a besoin d'une route hors de toute garde** (`src/app/index.tsx` redirige selon la
  session). Sans elle, un lancement déconnecté montre « Unmatched route ».
- **iOS 26 : la barre d'onglets flotte sur le contenu** ; `contentInsetAdjustmentBehavior=
  "automatic"` sur les `ScrollView`. Simulateur principal : iPhone 17 Pro sur iOS 26 (iOS 17 cache
  ces bugs).
- **Le React Compiler refuse la lecture d'une ref pendant le rendu** (`react-hooks/refs`) : retenir
  ce qu'un rendu précédent a vu avec un état posé pendant le rendu.
- **Les réponses de l'API ne font que grandir** : le serveur se déploie tout de suite, les apps se
  mettent à jour des jours plus tard (le build 1.0.0 (1) d'Ironmile plantait au lancement après la
  disparition d'un champ). Garder les anciens champs, avec un test qui les épingle ; sinon relever
  `MIN_BUILD` (écran « Mettre à jour »).
- **Une tâche longue lancée par une requête est enregistrée avant la réponse** : l'app qui
  interroge s'arrête sur tout autre état que « en cours ».
- iOS demande « Ouvrir dans <app> ? » quand un lien ouvre l'app par son schéma (`acme://`), sur un
  vrai téléphone aussi. Les liens universels (`apple-app-site-association`) l'enlèvent une fois le
  domaine en place.
- **Icône iOS = fichier Icon Composer** (généré par `scripts/brand-assets.mjs`) : la couche liste
  son SVG par apparence (`image-name-specializations` pour sombre et teinté) et ne doit **pas**
  avoir aussi un `image-name` simple, qui les écrase. Le simulateur ne change pas de style
  d'icône : vérifier avec `ictool <fichier>.icon --export-image --rendition Dark|TintedDark|ClearLight`.
- Le simulateur n'a ni notifications push ni vraies données de montre : il prouve la demande
  d'autorisation et une synchro propre, pas plus. Health Connect montre d'abord son propre écran
  « Get started ».
- **Clavier : `KeyboardAvoidingView` laisse le champ sous le clavier dans une feuille modale iOS**,
  hors de portée même en défilant (Ironmile, 3 novembre 2026, prouvé sur le simulateur). Le
  starter utilise `react-native-keyboard-controller` : `KeyboardProvider` à la racine,
  `KeyboardAwareScrollView bottomOffset={72}` dans `Screen` quand `keyboard`. Module natif : nouveau
  build de dev.
- **`Panel` ne mettait pas de trait entre les lignes d'un `.map()` suivi d'une autre ligne** : les
  enfants se lisent avec `Children.toArray` (aplatis), pas `Array.isArray`.
- **Widgets et Live Activities (expo-widgets), vu sur Ironmile le 13 novembre 2026** : un `Text`
  minuteur (`timerInterval`) prend toute la largeur qu'on lui laisse : dans l'île compacte, le temps
  flottait au milieu. Le fixer à son bord : `frame({ width, alignment: 'trailing' })` +
  `multilineTextAlignment('trailing')`. L'île dynamique est toujours noire : ses couleurs sont celles
  du thème sombre, jamais celles du thème du téléphone (un bleu foncé sur noir était illisible).
  L'extension ne lit ni les polices ni les images de l'app : dessiner le logo avec des `Rectangle`.
  Une barre de progression du minuteur : `ProgressView timerInterval`.
- **Live Activity d'expo-widgets 58 : `env.colorScheme` vaut toujours « light »** (prouvé sur Ironmile le
  13 novembre 2026, iPhone en sombre, carte blanche) : la bibliothèque lit l'environnement au niveau du
  `Widget`, hors de la vue. Ne pas s'en servir pour l'écran verrouillé : texte en couleurs adaptatives
  (`{ type: 'hierarchical', style: 'primary' | 'secondary' }`), pas d'`activityBackgroundTint` (fond du
  système), un accent lisible sur les deux fonds (≥ 3:1 en grand texte) ; un mode clair ou sombre choisi
  dans l'app se transmet dans les props. Les widgets de l'écran d'accueil, eux, reçoivent la bonne valeur.
- **Un minuteur ne vit pas dans un écran** : s'il tient dans le `useState` de l'écran, le quitter
  (aller voir l'accueil) l'arrête, avec sa notification et sa Live Activity (Ironmile, 13 novembre
  2026). Le garder dans un petit magasin de module (`useSyncExternalStore`) qui possède aussi la
  notification et l'activité ; sur iOS 26, `NativeTabs.BottomAccessory` le montre au-dessus des onglets.
- **La barre d'onglets fait partie de l'identité** (Ironmile, 13 novembre 2026 : Amine la trouvait
  « trop par défaut », restée soleil / calendrier / graphique / personne en encre depuis le starter,
  alors que tout le reste avait pris la marque). La garder native (Liquid Glass, `minimizeBehavior`,
  accessoire) mais lui donner les icônes de la marque (`brand/tabs/*.svg` →
  `node scripts/tab-icons.mjs` → `src={require(...)}` avec `renderingMode="template"`), la police de
  marque dans `labelStyle` et la couleur d'action pour l'onglet actif. Le build du starter refuse
  désormais des icônes `sf=` dans `(tabs)/_layout.tsx`. Même chose pour la barre du bas de la version web.
- **Les icônes se dessinent, elles ne se tapent pas** : ✓ › ‹ → en texte font amateur (taille et
  graisse qui ne suivent pas, alignement approximatif). `expo-symbols` (SF Symbols, avec leur
  équivalent Material sur Android) dans l'app, lucide sur le web.

## Données de santé (Apple Health, Health Connect) — vu sur Ironmile, 4 novembre 2026

- **Relire « depuis la dernière synchro » à la minute coupe le jour le plus ancien** : sa nuit n'a
  plus que ses dernières minutes, ses pas leurs dernières centaines, et cette valeur partielle
  écrase la valeur complète déjà enregistrée. Lire depuis minuit la veille du premier jour et
  n'envoyer que des jours entiers.
- **Une phase de sommeil compte pour le matin qui suit** (journée de sommeil de 18 h à 18 h, comme
  Santé), pas pour le jour où elle finit : sinon la première heure d'une nuit passe à la veille.
- **Plusieurs sources écrivent la même chose** (la montre en direct, son app dans Santé, Strava) :
  pour chaque mesure, un ordre fixe (montre connectée d'abord) et jamais « le dernier arrivé gagne ».
  Une séance arrive en plusieurs copies, parfois d'un autre type (Strava écrit une séance de muscu
  en « entraînement ») : les regrouper par heure de début et durée, pas par type.

## Maestro (tests de l'app native)

- **Sur iOS, un `View` avec un `testID` cache ses enfants à `childOf`** (Ironmile, 3 nov. 2026 : deux cartes de
  compétence, chacune avec ses `skill-step-<n>`). Le parent est trouvé, les enfants non. Viser par `index`
  (`tapOn: { id: "skill-step-1", index: 1 }`) ou donner des `testID` uniques aux enfants.
- **Le pavé numérique iOS n'a pas de touche « OK »** : `hideKeyboard` échoue. Toucher un texte hors du champ
  (un intitulé visible), et vérifier que l'écran ferme bien le clavier à ce toucher.

- `hideKeyboard` échoue sur iOS : taper sur un titre à la place.
- **`inputText` contourne la majuscule automatique et la correction d'iOS** : « hello. i » arrive tel
  quel même dans un champ normal. Pour tester la majuscule, taper les touches du clavier à l'écran
  (`tapOn: { point: "55%,76%" }`, des pourcentages entiers : `54.8%` plante Maestro). Le clavier du
  simulateur est celui de la langue du Mac (AZERTY ici) : « i » → « I » est une correction anglaise.
- **Une ligne dont tout le `Pressable` porte un `accessibilityLabel` cache ses textes à Maestro** :
  viser le libellé (`".*New 5 km best.*"`), et y mettre ce qui compte (VoiceOver le lit aussi).
  Une ligne de réglage (`Row` du starter) met sa valeur dans `accessibilityValue`, sinon VoiceOver
  lit « Session length » sans « 75 minutes » (Ironmile, 2026-11-03) ; Maestro la vise par `testID`.
- **Un `tapOn` sur un texte caché par la barre d'onglets flottante d'iOS 26 touche l'onglet** (sans
  erreur : le flow continue sur un autre écran) : `scrollUntilVisible` avec `centerElement: true` d'abord.
- Avec un émulateur Android allumé, passer `--device <udid>`, sinon Maestro prend Android.
- iOS cache les champs de mot de passe sur les captures : un champ vide n'est pas un bug.
- La feuille « Enregistrer le mot de passe ? » d'iOS 26 arrive après l'inscription ou la connexion,
  à des moments variables, et cache tout l'écran : `tapOn: { text: "Not Now", optional: true }`.
  Android propose aussi d'enregistrer (Google Password Manager) : « Not now ».
- **`tapOn: "Not Now"` touche aussi le « Not now » de l'app** (la recherche de texte ignore la
  casse) : donner un `testID` aux boutons de l'app et viser la feuille système par son texte exact
  seulement quand l'app n'a rien de semblable à l'écran.
- **Health Connect demande l'historique (plus de 30 jours) et la lecture en arrière-plan sur une
  deuxième page**, après les types de données : le flow doit la passer aussi.
- **Un tap pendant qu'une feuille modale monte se perd** : `waitForAnimationToEnd` avant de taper
  dans un écran présenté en modal (le paywall qui s'ouvre tout seul après un relancement).
- **`tapOn` sur un id ne fait pas défiler** : un bouton sous le pli (le « Save » d'une feuille sur un
  écran de 6,3 pouces) se tape dans le vide sans erreur ; `scrollUntilVisible` d'abord.
- **La barre jaune « Open debugger to view warnings » de React Native** se pose sur la barre
  d'onglets et avale les taps : `LogBox.ignoreLogs` pour les avertissements connus de développement
  (clé de test RevenueCat, « Sending `onAnimatedValueUpdate` with no listeners registered »).
- **Une capture prise au début d'une étape animée ne prouve rien** : la semaine « vide » de la
  révélation se dessinait jour après jour ; regarder la capture de l'étape suivante avant de
  conclure à un bug.
- Les flows tournent depuis un dossier `.screens/` (ignoré) ; les captures sont dans
  `~/.maestro/tests/<run>/…`, à regarder une par une.
- **`launchApp` relance l'app** (état perdu) : pour revenir dans l'app après `pressKey: Home`, c'est
  `launchApp: { stopApp: false }`. Le Centre de notifications du simulateur peut montrer une bannière
  de Live Activity **en cache** (ancien contenu) : se fier à la Dynamic Island et aux journaux de
  l'app, vérifier la vraie bannière sur le téléphone. Un widget s'ajoute au doigt (Edit → Add
  Widget → recherche du nom) ; celui de l'écran verrouillé ne se pose pas avec Maestro.

## App Store et RevenueCat

- **Le formulaire web d'App Store Connect perd les valeurs posées par automatisation** (vu le
  20 octobre 2026) ; l'API non : la fiche passe par `scripts/asc-listing.mjs`.
- **Les premiers abonnements d'une app ne passent pas par l'API** : dans l'interface web, « Add for
  Review » sur le **groupe** d'abonnements, puis sur **chaque** abonnement, puis sur la version,
  tous dans le même brouillon, puis « Submit for Review ». Un brouillon ouvert par le script doit
  d'abord perdre sa version, sinon la page de la version ne propose rien.
- **Rejet 3.1.2(c) « ne décrit pas ce que l'utilisateur reçoit pour le prix »** (Ironmile, 5 novembre
  2026) : c'est l'écran d'abonnement **dans l'app** (la capture jointe au rejet le montre). Le
  paywall doit dire ce que le prix achète (une liste concrète), plus le titre de l'abonnement, la
  durée et le prix de chaque option, l'essai et ses dates, le renouvellement et comment annuler,
  Restaurer, et des liens « Terms of Use » (EULA) et « Privacy Policy » (annexe 2, 3.8(b)). Mettre
  à jour aussi la **capture de vérification** de chaque abonnement (elle montre l'ancien écran) et
  sa description (55 caractères, verrouillée tant que l'abonnement est dans une soumission).
- **Après le rejet d'une première soumission avec abonnements**, un abonnement retiré de la
  soumission ne peut plus y revenir (« Impossible d'ajouter pour vérification ») : annuler la
  soumission rejetée (« Annuler la soumission »), puis refaire un brouillon groupe → chaque
  abonnement → version, et soumettre. Ce qu'on aurait répondu à Apple va dans les notes de
  vérification de la version. Les captures et notes des abonnements se changent par l'API
  (`subscriptionAppStoreReviewScreenshots`, `reviewNote`).
- **Renvoyer la même version avec un correctif seulement** : construire depuis le commit de la
  build rejetée (une branche `release-x.y.z`), avec un numéro de build au-dessus de toutes les
  builds déjà envoyées (`BUILD=<n> scripts/release-ios.sh`) ; l'écart de numéros n'a aucune
  importance pour Apple.
- Le Test Store de RevenueCat raccourcit l'essai d'une semaine à 5 minutes : « Gratuit jusqu'au »
  affiche la date du jour, ce n'est pas un bug.
- Nom, sous-titre, catégories, classement d'âge, étiquettes de confidentialité et déclaration de
  dispositif médical se règlent une fois dans l'interface web.
- **Apple ajoute des questions au classement d'âge** (`socialMedia`, octobre 2026) : tant qu'une
  est sans réponse, toute soumission échoue (409 `ENTITY_STATE_INVALID`, détail sur
  `/v1/ageRatingDeclarations/…`), même pour une mise à jour. La déclaration ne se lit que par
  `/v1/appInfos/<id>/ageRatingDeclaration` ; `scripts/asc-submit.mjs` signale les questions sans
  réponse. C'est la déclaration d'Amine : il répond, ou donne son accord explicite.
- **Réordonner les captures d'un jeu** (`PATCH …/appScreenshotSets/<id>/relationships/appScreenshots`)
  exige la liste de **toutes** les captures du jeu (409 sinon) : supprimer les anciennes d'abord, puis
  réordonner. Une nouvelle version reprend les captures et textes de la précédente.
- **Sous-titre et mots-clés ne changent qu'avec une version** (le texte promotionnel, lui, à tout
  moment) : pour changer la fiche sans changer l'app, une version au même code suffit. Les mots du
  nom, du sous-titre et des mots-clés sont indexés ensemble : un mot répété est perdu.

## IA (Claude) dans une app

- **En local, le modèle tourne sur l'abonnement Max, pas sur l'API** (Ironmile, 22 octobre 2026 :
  `coachEngine()` et `viaClaudeCode()` dans `apps/api/lib/coach/generate.ts`). `claude -p
  --model … --effort … --system-prompt <le prompt de l'app> --json-schema <le schéma>
  --tools "" --setting-sources "" --strict-mcp-config --no-session-persistence --output-format
  json`, lancé depuis le dossier temporaire, avec un environnement sans `ANTHROPIC_*` (sinon il
  facture la clé) ni `CLAUDE*` (sinon il se croit enfant de la session). Le résultat est dans
  `structured_output`, `stop_reason` vaut `tool_use` ; `usage` donne les vrais jetons, donc le
  prix API équivalent. Jamais sur Vercel (`VERCEL` force l'API), jamais pour d'autres
  utilisateurs. Les évals payantes (Sonnet/Opus sur l'API) exigent `--confirm-cost`.
- **Un schéma de sortie se valide sur la vraie API, au moins une fois, avec Haiku** : `claude -p
  --json-schema` et les tests à client simulé acceptent des schémas que l'API refuse. Un objet « plan
  ou réparation » qui contenait deux fois le schéma d'une séance a été refusé sur Haiku et Opus
  (« The compiled grammar is too large ») : tous les appels du coach auraient échoué en production.
  Un seul schéma plat, chaque gros objet une seule fois.
- **Le schéma est près de la limite : un seul champ de plus peut tout casser, et rien en local ne le
  voit** (Ironmile, 28 octobre 2026 : un champ `hr` nullable sur les étapes de course a fait échouer
  en production tous les appels du coach, 400 « The compiled grammar is too large » ; les évals sur
  `claude -p` et les tests à client simulé passaient). Un test réel à la demande
  (`REAL_SCHEMA=1 … schema.real.test.ts`) envoie la requête de production telle quelle (même prompt,
  même schéma, chaque modèle de la route, `max_tokens` minuscule, quelques centimes) et échoue sur
  tout 400 : à lancer avant de pousser toute modification du schéma. Ce qui a une seule bonne réponse
  (où va un plafond, une étiquette déduite) se calcule dans le code après la lecture, hors du schéma.
- **Même un seul champ de premier niveau peut dépasser la limite** (Ironmile, 3 novembre 2026 : un
  tableau de chaînes nullable `recap` a fait refuser le schéma, une simple chaîne, une ligne par
  ligne, est passée). Un champ ajouté pour un usage secondaire se lit avec `.catch(...)` : mal
  formé ou absent, il ne coûte jamais un nouvel essai.
- **Donner au modèle les nombres que le contrôle va vérifier** : la plupart des réessais d'un plan
  hebdomadaire venaient de comptes (une course de moins, des minutes de trop) que le modèle devait
  recalculer ; les mettre dans le brief, calculés par les mêmes fonctions que le contrôle, fait passer
  plus de plans du premier coup.
- **La sortie, réflexion comprise, fait ~90 % de la facture** : mesurer l'effort (`low`,
  `medium`) sur des cas de test avant de le monter ; Ironmile est passé à `low` pour les plans
  hebdomadaires (−42 % de jetons, plans aussi bons).
- **Ce qui n'est pas urgent passe par l'API Batches (−50 %)** : le run reste « en file » (pas
  « en cours », sinon l'app tourne en rond), une tâche planifiée récupère les résultats.
- **Réparer plutôt que réécrire** : quand un contrôle échoue, ne renvoyer que les parties fautives
  et fusionner. Le schéma de la réparation doit être celui du plan (un schéma à part rate le
  cache : 11k jetons réécrits, la réparation coûtait plus que la réécriture).

## Travail en parallèle (agents dans des worktrees)

- **`isolation: "worktree"` crée le worktree du dépôt où tourne la session** (vu le 2026-10-29) :
  lancée depuis `~/Projects`, ou depuis un autre dépôt, l'agent atterrit dans le mauvais repo. Lancer
  depuis le dossier du dépôt visé, ou demander à l'agent de cloner le dépôt dans le scratchpad et d'y
  travailler sur une branche (puis `git fetch <clone> <branche>` et fusionner).
- **`.claude/worktrees/` dans `.gitignore`** : sinon `git status` du dépôt principal les montre.
- **Un worktree peut partir d'un commit plus ancien que `main`** (vu le 22 octobre 2026) :
  vérifier `git worktree list` et faire `git merge main` dans le worktree avant tout travail qui
  dépend du dernier commit.
- **Un build de dev sur un autre simulateur et un autre port de Metro, sans rebuild** (vu le
  28 octobre 2026 sur Ironmile) : copier l'app installée sur le simulateur principal
  (`xcrun simctl get_app_container <udid> <bundle id> app`, `cp -R`, `xcrun simctl install <autre udid>`),
  puis `xcrun simctl spawn <autre udid> defaults write <bundle id> RCT_jsLocation localhost:<port>`
  (un build de dev sans expo-dev-client cherche Metro là) et `EXPO_PUBLIC_API_URL=http://localhost:<port API>
  npx expo start --port <port>`.
- **Deux sessions Claude sur le même projet web** (vu le 4 novembre 2026, Apex) : un `git worktree`
  à soi (`git worktree add -b <branche> ../<projet>-<sujet> origin/main`, copier `.env.local`,
  `pnpm install`), sans jamais toucher l'arbre de l'autre ; un autre port, en surchargeant pour ce
  seul processus `BETTER_AUTH_URL` et `APP_URL` (sinon la connexion échoue sur l'origine) ; pour se
  connecter sans le mot de passe d'Amine, `AUTH_ALLOWED_EMAIL=<adresse de test>` dans la même
  commande et un compte de test sur la base de dev. Rebaser sur `origin/main` juste avant de pousser
  (`git push origin HEAD:main`), prévenir l'autre session (SendMessage) des fichiers en commun et des
  numéros de migration pris. Un `fatal error in commit_refs` de GitHub au push est passager : refaire.
- Chaque agent ses ports (API, Metro) et son simulateur ; la base de dev partagée ne reçoit que
  des migrations additives écrites pour tourner deux fois (`IF NOT EXISTS`), renumérotées à la
  fusion (régénérer avec `drizzle-kit generate` pour un instantané juste, puis remettre le SQL
  idempotent).

## Rédaction (site, fiches, posts)

- **Les faits disent ce qui est vrai, pas quoi écrire** (Ironmile, 27 octobre 2026). Une page
  bâtie en recopiant les phrases de `lib/product/facts.ts` (`fact("a") + fact("b")` dans une FAQ,
  des paragraphes « inventaire ») énonce sans convaincre ; Amine l'a vu tout de suite. Le texte
  suit un argument (le problème, une preuve vécue, le prix) et cite un fait seulement là où il
  prouve ce que le lecteur veut savoir à ce moment, avec ses mots ; moins de faits, mieux placés.
  Les chiffres restent importés du code. La skill `aligner` rend un texte vrai, elle ne le
  remplit pas des faits du jour.

## Connecteur Claude (MCP) d'une app

- **Better Auth 1.7 sert un connecteur claude.ai** avec `@better-auth/oauth-provider` + `@better-auth/mcp`
  (Ironmile, 28 octobre 2026, `apps/api/app/mcp/`, `lib/connector/`) : l'enregistrement dynamique des
  clients (RFC 7591) s'active **explicitement**, et les routes de métadonnées s'ajoutent à la main dans
  Next (`/.well-known/oauth-protected-resource/<chemin du serveur>` et
  `/.well-known/oauth-authorization-server/api/auth`, aussi à la racine). Claude n'utilise que le
  premier serveur d'autorisation listé ; son retour OAuth est `https://claude.ai/api/mcp/auth_callback`.
- **Avec `cacheComponents`, les routes de métadonnées OAuth (`/.well-known/…`) doivent appeler
  `await connection()`** avant le handler de Better Auth (Apex, 4 novembre 2026) : sinon Next tente de les
  prérendre au build (« needs to bail out of prerendering … request.headers ») et le build échoue. Le
  cache de build de Vercel l'a masqué deux fois avant d'échouer : un build local réussi ne le prouve
  qu'après `rm -rf .next/cache`. Les tests qui appellent ces handlers simulent `connection` (`vi.mock`).
- **`fetch` de Node reçoit une réponse JSON de redirection** depuis `/oauth2/authorize` là où un
  navigateur reçoit un 302 : un test de bout en bout doit suivre l'URL du JSON.
- **Les limites de débit de Better Auth (5 par minute par IP)** s'appliquent à toute la plage d'IP
  sortante de Claude (partagée par tous ses utilisateurs) : à relever avant d'ouvrir le connecteur
  au public.
- Un connecteur réutilise les fonctions des routes de l'app (jamais de logique à part) et ne lit que
  les données de l'utilisateur du jeton.
- **Des server actions qui lisent la session ne servent pas un connecteur** (Apex, 4 novembre 2026) :
  leur logique va dans `lib/ops.ts` (l'id de l'utilisateur en premier argument), et `lib/actions.ts`
  ne garde que des enveloppes `"use server"` (session + `refresh()`). Une action qui en appelait une
  autre perdait son `refresh()` implicite : le remettre dans son enveloppe.
- **Navigateur de test et limite de 5 connexions par minute** : donner à chaque contexte Playwright
  sa propre adresse (`extraHTTPHeaders: { "x-forwarded-for": "10.9.x.y" }`), comme les tests Vitest.
- **L'attente dans claude.ai vient des tours d'outils, pas du serveur** (Apex, 11 novembre 2026 : base
  ~16 ms, point d'accès 0,15 s, mais 3–4 lectures enchaînées avant la première réponse). Concevoir le
  connecteur avec **une seule lecture de départ** (« brief » : tout ce qu'il faut pour répondre ou
  planifier, compact, sans champs `null`, textes longs coupés en aperçu) et mettre le **guide dans les
  `instructions` du serveur** (lues une fois à la connexion), pas dans le résultat d'un outil. Journaliser
  chaque appel avec son outil et sa durée (`[mcp] tools/call get_brief 200 312 ms`) pour mesurer.

## Plusieurs portes vers le même produit

- **App, site web de l'app, connecteur : une seule source pour ce qu'ils disent** (Ironmile, 28 octobre
  2026 : la page Connexions du web gardait l'ancien menu Strava corrigé dans l'app). Les textes et les
  règles partagés vivent dans `packages/core` ; un changement de ce que l'app montre ou fait touche les
  autres portes dans le même commit (ou la porte dit « dans l'app »). Le `CLAUDE.md` du projet l'écrit
  dans ses règles.

## Design

- **Un look maison revient toujours s'il reste quelque part** (1er novembre 2026) : le guide, le
  starter et le test de `verifier` imposaient tous le même modèle, donc chaque projet finissait par se
  ressembler. Le starter est désormais une base nue, et son build échoue tant qu'une direction n'est
  pas choisie (`apps/web/design-direction.json`, `apps/web/scripts/check-design.mjs`).
- **Une refonte prouve ce qu'elle ne refait pas** (Job HQ et HQ, 1er novembre 2026) : `globals.css` et les polices touchent aussi ce qui partage le layout racine (l'écran de Lahcen, les diapositives qui partent sur les réseaux). Capturer l'ancienne version avant de coder, puis comparer les images à l'identique (`cmp`) à la fin.
- **Deux chiffres sur deux périodes se contredisent à un geste d'écart** (HQ : « en baisse » sur l'accueil, « en hausse » sur la page ouverte) : le lien emporte la période (`?period=7d`).

## Vu sur Vestiaire (1er novembre 2026)

- **`bytea` avec le driver HTTP de Neon** : il répond un `Buffer`, pas du texte hexadécimal. Un `customType` Drizzle qui fait `String(v)` corrompt le fichier sans erreur. Le `fromDriver` accepte les deux, et le test relit les octets (`RIFF`…), pas seulement le statut 200.
- **Une `<input>`/image dans un `<button>` (bouton dans bouton)** : erreur d'hydratation, l'arbre est régénéré côté client. Le contrôle console de `verifier` l'attrape.
- **État client initialisé depuis une prop (`useState(props.x)`) quand l'adresse change** : les données fraîches arrivent après le montage et l'état reste l'ancien. Dériver de la prop tant que la personne n'a rien choisi, et `key` sur le paramètre.
- **`grid` sans colonnes sur téléphone** : une liste à défilement horizontal élargit toute la page (`grid-cols-[minmax(0,1fr)]`, `min-w-0`).
- **Des dizaines de `<Link>` vers des pages dynamiques** : préchargement de chacune, inutile sur téléphone, et messages d'erreur dans WebKit à l'abandon : `prefetch={false}`.
- **Boutiques vues d'un serveur** : C&A sert ses pages et ses photos à plat (`-08` devant, `-11` dos) ; H&M, Zalando, Decathlon, Adidas, Nike, Arket, COS, Weekday refusent ou renvoient une page vide. Toujours prévoir un chemin « l'utilisateur ajoute l'image ».
- **Tests de navigateur en série** : la limite de 5 connexions par minute de Better Auth s'applique aussi à eux : espacer les connexions ou réutiliser la session.
- **Google avec Better Auth, une seule personne** (Vestiaire, là où le connecteur Claude impose Better Auth plutôt qu'Auth.js) : `socialProviders.google`, `accountLinking` avec `trustedProviders: ["google"]` pour rejoindre un compte existant, et la liste blanche à deux endroits : `databaseHooks.user.create.before` et `session.create.before` (retourner `false`). Sur la page du connecteur, `callbackURL` = `/connect` + sa requête signée, sans `oauth_query` dans le corps. Le client OAuth se crée dans la console (`headquarters-509211`), Google n'affiche son secret qu'une fois.

## Adresses e-mail d'un domaine (Qiyam, 3 novembre 2026)

- **Jamais de boîte mail payante** (Namecheap Private Email, etc.) : réception par **redirection** vers le Gmail d'Amine, envoi par **Resend**. Rien à payer, une seule boîte de réception.
- **ImprovMX gratuit = 1 seul domaine** (déjà pris par ironmile.app). Pour les autres : **Forward Email**, gratuit sans limite de domaines, réglé seulement dans le DNS (Vercel) : `MX 10 mx1.forwardemail.net` et `mx2`, SPF `include:spf.forwardemail.net`, et le TXT `forward-email=…` **chiffré** (`POST https://api.forwardemail.net/v1/encrypt {"input":"contact:x@gmail.com,…"}`), sinon l'adresse Gmail est publique dans le DNS.
- **Resend** : ajouter le domaine racine (région Irlande) pour envoyer en `@domaine` ; ses enregistrements (`resend._domainkey`, CNAME `send` et `rsend`) ne touchent pas aux MX de la redirection. Une clé « Sending access » limitée au domaine par usage (serveur, Gmail).
- **Tester la redirection** : depuis le Mac, le port 25 est bloqué par le fournisseur ; envoyer par l'API Resend vers chaque alias, puis chercher dans Gmail (`subject:` + `in:anywhere`) et vérifier le libellé INBOX (pas Spam).
- **« Envoyer en tant que » dans Gmail** : SMTP `smtp.resend.com`, port 465 (SSL), utilisateur `resend`, mot de passe = la clé : c'est Amine qui la colle, Claude ne saisit pas de clé.
- **Résilier une boîte payante efface ses messages définitivement** : c'est Amine qui clique, après avoir regardé ce qu'elle contient.
- **E-mail à un utilisateur (relance, question) : texte brut.** Avec des boutons HTML et l'en-tête `List-Unsubscribe`, Gmail a classé l'e-mail de Qiyam dans Promotions ; le même en texte brut arrive dans Principale. Le lien de désinscription reste en bas du texte. Avant d'envoyer à de vrais utilisateurs : un aperçu envoyé à Amine seul, et l'interrupteur (variable d'environnement) que c'est Amine qui bascule.
- **Envoi automatique : une ligne par destinataire et par occasion, réservée en base avant d'envoyer** (index unique + `onConflictDoNothing`, clé d'idempotence Resend dérivée de l'occasion) : un cron Vercel peut être livré deux fois.

## Vu sur VMC Trainer (3 novembre 2026)

- **`/favicon.ico` en 404 dans chaque console** : les navigateurs le demandent d'eux-mêmes malgré
  `app/icon.png`. Le starter le génère désormais (`scripts/brand-assets.mjs` → `apps/web/public/favicon.ico`).
- **Outil privé à un seul utilisateur** : un code d'accès (`APP_PASSCODE`) vérifié par `proxy.ts`
  (Next 16) + un cookie httpOnly signé (HMAC, jamais le code lui-même), et chaque route le revérifie.
  Le `?next=` de la page d'accès se résout avec `new URL(next, origine factice)` : un simple test
  `startsWith("//")` laisse passer `/\t/evil.com` (le navigateur retire tabulations et retours).
  Exclure du `matcher` tout fichier que le service worker met en cache (`offline.html`), sinon il
  garde la page d'accès à la place. Modèle : `~/Projects/vmc-trainer/apps/web/lib/vmc/access.ts`.
- **Mesurer un temps de réaction** : prendre l'instant d'affichage dans un `useLayoutEffect` au
  moment où l'élément est posé, pas dans un `requestAnimationFrame` (il peut tomber bien plus tard,
  les temps mesurés étaient faux de ~100 ms). Ignorer `e.repeat` sur les touches de réponse.
- **Un état d'écran (`stage`) qui survit d'un bloc à l'autre** : le remettre à zéro au début de
  chaque bloc, et faire lire l'index courant dans une ref par les minuteurs (pause pendant le
  décompte → reprise au mauvais index, bloc vide enregistré).
- **Lancer une agent de relecture indépendante avant de livrer** : sur VMC Trainer, 8 vrais bugs
  que les tests et le parcours dans le navigateur n'avaient pas vus.

## Vu sur Apex (4 novembre 2026)

- **Planches HTML : un `id` SVG qui porte le nom d'un élément de la page** (`url(#r1)` alors qu'une
  rangée de la planche s'appelle `id="r1"`) : le dégradé pointe vers la `div` et la forme sort vide, sauf
  la première. Préfixer les ids des dégradés (`sky0`, `sky1`…).
- **Première visite : la page lit en même temps que le layout prépare le compte** (valeurs par défaut,
  modèle de journée…) : la page crée ses données avant que les défauts existent (une journée sans blocs).
  La fonction de données appelle elle-même la préparation (`ensureSetup` idempotent), et toute copie
  « une seule fois » est garantie par un **index unique** en base, pas seulement par un verrou applicatif.
- **Rappels à l'heure avec Neon gratuit** : pas de cron à la minute (la base ne s'endort jamais). Cron
  toutes les 15 min sur les heures utiles ; chaque passage envoie ce qui commence dans [T, T+15) en
  donnant l'heure exacte, réservé dans une table `notification_log` avant l'envoi (cron livré deux fois).
- **Horaires de prière d'une mosquée (Mawaqit)** : pas d'API publique, mais la page publique de la
  mosquée (`mawaqit.net/fr/<slug>`) porte toute l'année dans `confData.calendar` (12 mois, jour →
  [fajr, shuruq, dhuhr, asr, maghrib, isha]). Lire l'objet accolade par accolade (chaînes respectées),
  copier l'année en base chaque nuit, repli approximatif signalé si un jour manque. Modèle :
  `~/Projects/apex/apps/web/lib/prayers.ts`.
- **Mode auto de Claude Code** : `vercel env pull` de la production d'un autre projet et `vercel redeploy`
  d'un autre projet sont refusés. Poser les variables (`vercel env add … --force`), puis laisser le
  prochain déploiement normal les prendre, ou demander à Amine.
- **Grille sans colonnes sur téléphone** (déjà noté) : revu sur une page Réglages en deux colonnes —
  `grid-cols-[minmax(0,1fr)] md:grid-cols-2` et `min-w-0` sur chaque colonne.

## Vu sur Apex (5 novembre 2026)

- **Rangée d'actions d'un en-tête de page qui déborde sur téléphone** : un conteneur `flex shrink-0
  flex-wrap` ne revient jamais à la ligne (il ne rétrécit pas), la page devient plus large que l'écran
  dès qu'on y ajoute un contrôle. Écrire `flex max-w-full min-w-0 flex-wrap md:shrink-0`, et contrôler
  `document.documentElement.scrollWidth === innerWidth` dans `verifier`.
- **Survol invisible dans Playwright « iPhone » et « Android »** : ces profils émulent un écran tactile
  (`(hover: hover)` faux), et Tailwind v4 n'applique `hover:` que sous `@media (hover: hover)`. Un
  élément révélé au survol (poignée, bouton) ne s'y voit jamais : lui donner le même style en
  `focus-visible:` (utile au clavier de toute façon) et le vérifier en tabulant dessus.
- **Champ date vide dans Safari** : WebKit y affiche une date grisée qui passe pour une valeur. Une
  date facultative (échéance) s'ouvre par un bouton « + Échéance » qui fait apparaître le champ.
- **Navigation qui affiche un écran vide entre deux pages** (Apex : ~0,3 s de noir à chaque changement de
  jour). Cause : avec `cacheComponents` + `partialPrefetching: true`, un `<Link>` ne précharge que le cadre
  de la page, jamais les données lues en base pour l'utilisateur ; chaque page attend donc le serveur
  derrière son `<Suspense>`, dont le fallback était un `div` vide. Recette (Apex, commit du 5 nov.) :
  `partialPrefetching: false` + `prefetch` sur les liens qui comptent (flèches, onglets, menu latéral ;
  jamais sur une grille de 30 jours qui créerait des données) ; `experimental.staleTimes { dynamic: 300,
  static: 300 }` ; après chaque écriture `revalidatePath("/", "layout")` (vide **tout** le cache du
  navigateur ; `router.refresh()` ne vide que la page courante) ; au retour dans l'app
  (`visibilitychange`, absent > 15 s) une action serveur qui fait de même ; chaque fallback = le contour
  de la page, et celui du layout un cadre fixe sans `usePathname` ni `new Date()` (sinon le build refuse
  le prérendu). Mesure : passage direct d'une page à l'autre en ~40 ms, aucun cadre vide.

## Vu sur Apex (6 novembre 2026)

- **Glisser pour réordonner, au doigt** : `@dnd-kit/sortable` avec une poignée (`touch-none`, 44 px)
  et `PointerSensor` (distance 4) + `KeyboardSensor`. Pour le **prouver** : la souris de Playwright
  dans le profil WebKit tactile (iPhone) ne déclenche pas le glisser de dnd-kit (faux échec) ; le
  doigt se simule sur Chromium (Android) avec `Input.dispatchTouchEvent` via une session CDP, et la
  logique d'ordre se teste aussi au clavier (Espace, flèches, Espace). Enregistrer l'ordre en une
  seule fois (`db.batch`), pas une requête par ligne.
- **Les réglages par défaut d'un nouveau compte s'écrivaient deux fois** : les premiers écrans se
  chargent en même temps et chacun appelait la mise en place (« pas encore de profil → tout
  insérer ») ; un compte neuf avait 14 domaines au lieu de 7. **Réserver d'abord** : insérer la ligne
  qui marque « fait » (`onConflictDoNothing().returning()`), et seule la requête qui l'a créée écrit
  le reste (`db.batch`) ; en cas d'échec, rendre la réservation. Un test lance la mise en place trois
  fois en parallèle et compte les lignes.
- **Une rangée de boutons qui doit passer à la ligne** : un groupe intérieur en `shrink-0` ne se
  replie jamais et pousse la page en largeur dès que les boutons dépassent ; sur ordinateur
  `md:min-w-0 md:shrink md:flex-wrap` sur le groupe aussi. Tester une largeur étroite (1024 px) avec
  plus de boutons que prévu.
- **View transitions (le mouvement)** : laisser le fond de page (`root`) sans fondu
  (`::view-transition-old(root), ::view-transition-new(root) { animation: none }`), sinon chaque
  rafraîchissement après une action fait clignoter les changements ; clé de l'écran = l'adresse,
  pour qu'un rafraîchissement n'anime pas toute la page ; un même nom visible deux fois annule la
  transition (une copie en `display:none`, téléphone/ordinateur, ne gêne pas). Les filtres d'une
  liste en `startTransition`, mais pas la frappe dans une recherche.

## Le CLAUDE.md d'une app : en couches (6 novembre 2026)

- **Un CLAUDE.md se charge en entier à chaque session.** Ceux d'Ironmile et de HQ avaient atteint
  ~32 Ko (~8 000 tokens) : les règles valables partout s'y noyaient dans le détail de la mise en
  ligne, de la vérification et du studio. Ne garder dedans que ce qui vaut à chaque tâche (ce
  qu'est l'app, les règles partout, les commandes) ; chaque sujet d'un moment précis va dans
  `docs/claude/<sujet>.md`, avec une ligne « Before … → read `docs/claude/<sujet>.md` ». Le starter
  le fait d'office (`claude-template/` devient le `docs/claude/` de l'app) ; `verifier` et
  `mise-en-ligne` suivent ces renvois. Au-delà d'environ 15 Ko, découper.

## Vu sur Briefing (6 novembre 2026)

- **Une file d'envoi `running = (async () => {…})()` peut se bloquer pour toujours** (VMC Trainer et
  Briefing, même code) : quand il n'y a rien à envoyer, le corps de la fonction async s'exécute en
  entier de façon synchrone (aucun `await` atteint), son `finally` remet `running = null`… puis
  l'affectation pose la promesse déjà résolue dans `running`. Chaque `flush()` suivant la renvoie et
  plus rien ne part : les réponses restent « en attente » sur l'appareil. Commencer le corps par
  `await Promise.resolve()`, et un test « vider une file vide, puis envoyer » (Briefing,
  `lib/sync-queue.test.ts`). Les tests unitaires d'avant ne le voyaient pas : seul le vrai parcours
  dans le navigateur l'a montré.
- **Le navigateur Playwright du MCP est partagé** : des sous-agents qui s'en servent pendant que tu
  testes changent la page sous tes yeux (et tes réponses de test partent avec). Donner aux agents
  un outil de capture à eux (`scripts/shot.sh` avec Chrome sans fenêtre, `--user-data-dir` neuf), et
  tester soi-même dans un navigateur isolé (un script Playwright avec son propre `launch()`).
- **Après une réécriture complète de `globals.css`, `next dev` a servi l'ancien CSS** (et un ancien
  rendu serveur d'un composant modifié : erreur d'hydratation trompeuse) : arrêter le serveur,
  `rm -rf .next`, relancer, avant de conclure à un bug.
- **Une fonction importée d'un fichier `"use client"` dans un composant serveur n'est plus une
  fonction** (référence client) : les petites fonctions partagées (formatage d'une réponse…) vivent
  dans un module sans directive (`lib/…`).
- **Ne pas importer l'index du contenu (`@/content`) dans un composant client** : tout le contenu
  part dans le JavaScript du navigateur. Passer au client seulement ce qu'il affiche.
- **`cacheComponents` garde les pages visitées en vie (React `<Activity>`)** : un composant client
  dont l'état part de ses props (`useState(questions)`, une série, un formulaire à étapes) revient
  tel qu'on l'a laissé quand on rouvre la page par un lien, même si le serveur a envoyé de nouvelles
  données. Donner une `key` neuve à chaque requête (`crypto.randomUUID()` dans une fonction de
  `lib/`, appelée après `await connection()`). Prouvé sur Briefing : « Une autre série » rouvrait
  l'ancien bilan.
- **SVG calculés avec `Math.sin/cos`** : Node et les navigateurs diffèrent sur les derniers chiffres,
  l'attribut rendu côté serveur ne correspond plus et l'hydratation échoue. Dessiner ces schémas
  seulement dans le navigateur (`useIsClient`), avec un cadre de même hauteur en attendant.
- **Relecture de code indépendante avant de livrer, encore** : sur Briefing, elle a trouvé 11 vrais
  problèmes (bilan d'examen gonflé, Entrée sans effet après un clic, champ numérique jamais
  focalisé…) que les tests et mes parcours n'avaient pas vus.
- **`pnpm build` qui échoue par moments sur `Can't resolve '@vercel/turbopack-next/internal/font/google/font'`**
  (24 erreurs, « next/font/google queries have exactly one entry ») : ce n'est pas le code, c'est
  Google Fonts qui n'a pas répondu au build sur le Mac. Relancer le build seul ; vérifier son code de
  sortie (`echo $?`), pas seulement l'absence d'erreurs filtrées par `grep`.
- **Un `?` dans une URL non citée casse toute la ligne zsh** (`no matches found`) : zsh n'exécute
  rien de la ligne, pas même les commandes placées avant ; sans sortie, on croit à tort qu'elles ont
  réussi. Toujours citer les URL.

## Les liens entre apps tombent en silence (6 novembre 2026)

- Un lien entre deux apps (un flux à jeton, une copie de base, un article commité dans un autre
  repo) échoue sans bruit là où il sert : Apex gardait un bloc sport sans nom quand Ironmile ne
  répondait pas ; HQ marquait « publié » un article commité, sans regarder le site. Tout nouveau
  lien entre dans le contrôle quotidien de HQ (`headquarters/lib/links.ts`, qui appelle aussi
  `GET /api/hq/links` d'Apex et de Studio) : une notification nomme ce qui a cassé.

- **Vu sur Briefing (9 nov 2026) : une image privée ne va pas dans `public/`.** Le `matcher` du
  `proxy.ts` du starter laisse passer tout fichier `.png/.jpg/.webp…` sans code d'accès : une image
  derrière le mot de passe (capture, document) se range hors de `public/` et se sert par une route
  (`route.ts` qui vérifie l'accès puis lit le fichier), avec `outputFileTracingIncludes` pour que
  Vercel embarque les fichiers.
