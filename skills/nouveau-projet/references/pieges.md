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
  `initialFocus={(type) => (type === "touch" ? listRef.current : true)}`.
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
- Le MCP Neon refuse (garde-fou) les `UPDATE`/`DELETE` sans cible précise : cibler par id.

## Vercel

- `vercel ls` et la plupart des tableaux du CLI s'écrivent sur **stderr** : `2>&1`.
- `vercel link --yes --project <nom>` **crée** le projet s'il n'existe pas.
- `vercel link` ajoute `VERCEL_OIDC_TOKEN` à `.env.local` : sans danger, ignoré par git.
- `vercel.json` avec `"regions": ["fra1"]` quand la base Neon est à Francfort.
- Envoyer un secret sans l'afficher : `vercel env add NOM production < <(commande)`.

## Actions serveur : tester sans navigateur (secours)

Les ids d'actions sont dans `.next/server/server-reference-manifest.json`. Appel :
`POST <page>` avec les en-têtes `Next-Action: <id>`, `Accept: text/x-component`,
`Content-Type: text/plain;charset=UTF-8`, corps = tableau JSON des arguments. Le
résultat est la ligne qui commence par `1:`. Écrire ce genre de test en Node (`fetch`),
pas en bash (guillemets).
