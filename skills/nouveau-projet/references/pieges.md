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

## Tâches planifiées

- **Le `schedule` de GitHub Actions n'est pas ponctuel** : sur un repo peu actif, des exécutions
  arrivent avec des heures de retard ou sautent (Qiyam HQ : « toutes les heures » → 5 exécutions
  en 13 h). Planifier deux essais par heure si l'endpoint ignore un doublon, et rafraîchir aussi à
  l'ouverture de l'app quand la donnée est vieille (`after()` dans le layout).
- Équipe Vercel sur Pro (depuis le 20 octobre 2026) : les crons Vercel (`vercel.json`, `CRON_SECRET`)
  n'ont plus la limite d'une par jour ; les préférer à GitHub Actions dans un nouveau projet.

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

- Sur le driver HTTP de Neon : pas de transaction interactive, donc l'adaptateur tourne avec
  `transaction: false` (son défaut). Nos écritures sur plusieurs tables passent par `db.batch([...])`.
- Ses tables sont générées : `pnpm dlx auth@<version> generate --config lib/auth.ts --output
  db/auth-schema.ts --yes`, avec `import "server-only"` commenté dans `db/index.ts` pendant
  l'exécution (le CLI ne sait pas le charger) et `DATABASE_URL` exportée.
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

## Maestro (tests de l'app native)

- `hideKeyboard` échoue sur iOS : taper sur un titre à la place.
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

## App Store et RevenueCat

- **Le formulaire web d'App Store Connect perd les valeurs posées par automatisation** (vu le
  20 octobre 2026) ; l'API non : la fiche passe par `scripts/asc-listing.mjs`.
- **Les premiers abonnements d'une app ne passent pas par l'API** : dans l'interface web, « Add for
  Review » sur le **groupe** d'abonnements, puis sur **chaque** abonnement, puis sur la version,
  tous dans le même brouillon, puis « Submit for Review ». Un brouillon ouvert par le script doit
  d'abord perdre sa version, sinon la page de la version ne propose rien.
- Le Test Store de RevenueCat raccourcit l'essai d'une semaine à 5 minutes : « Gratuit jusqu'au »
  affiche la date du jour, ce n'est pas un bug.
- Nom, sous-titre, catégories, classement d'âge, étiquettes de confidentialité et déclaration de
  dispositif médical se règlent une fois dans l'interface web.

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
- **La sortie, réflexion comprise, fait ~90 % de la facture** : mesurer l'effort (`low`,
  `medium`) sur des cas de test avant de le monter ; Ironmile est passé à `low` pour les plans
  hebdomadaires (−42 % de jetons, plans aussi bons).
- **Ce qui n'est pas urgent passe par l'API Batches (−50 %)** : le run reste « en file » (pas
  « en cours », sinon l'app tourne en rond), une tâche planifiée récupère les résultats.
- **Réparer plutôt que réécrire** : quand un contrôle échoue, ne renvoyer que les parties fautives
  et fusionner. Le schéma de la réparation doit être celui du plan (un schéma à part rate le
  cache : 11k jetons réécrits, la réparation coûtait plus que la réécriture).

## Travail en parallèle (agents dans des worktrees)

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
- **`fetch` de Node reçoit une réponse JSON de redirection** depuis `/oauth2/authorize` là où un
  navigateur reçoit un 302 : un test de bout en bout doit suivre l'URL du JSON.
- **Les limites de débit de Better Auth (5 par minute par IP)** s'appliquent à toute la plage d'IP
  sortante de Claude (partagée par tous ses utilisateurs) : à relever avant d'ouvrir le connecteur
  au public.
- Un connecteur réutilise les fonctions des routes de l'app (jamais de logique à part) et ne lit que
  les données de l'utilisateur du jeton.

## Plusieurs portes vers le même produit

- **App, site web de l'app, connecteur : une seule source pour ce qu'ils disent** (Ironmile, 28 octobre
  2026 : la page Connexions du web gardait l'ancien menu Strava corrigé dans l'app). Les textes et les
  règles partagés vivent dans `packages/core` ; un changement de ce que l'app montre ou fait touche les
  autres portes dans le même commit (ou la porte dit « dans l'app »). Le `CLAUDE.md` du projet l'écrit
  dans ses règles.

