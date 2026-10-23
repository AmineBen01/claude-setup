---
name: aligner-carriere
description: Garder vrai tout ce qui me présente aux recruteurs — le site amineben.ch, les 4 CV (FR/EN), les faits de la routine de candidatures (Job HQ, ROUTINE.md) et le texte LinkedIn — quand mes projets avancent ou qu'un nouveau apparaît. Corrige soi-même ce qui est petit (statut, version, chiffre, stack, date) et met en ligne ; ce qui est gros (nouveau projet, étude de cas à réécrire, projet à mettre en avant) devient une demande dans Job HQ (« Needs you » + notification). Routine du lundi matin « Carrière : aligner », ou quand je dis « aligne ma carrière », « mets mon CV/site à jour avec mes projets ».
---

# Aligner carrière

Décidé le 23 octobre 2026. Le site, les CV, la routine de candidatures et LinkedIn disent la même
chose de moi, et c'est vrai aujourd'hui. Les **chiffres vivants** (téléchargements, pays, note,
lancement d'Ironmile) se mettent à jour seuls : flux public de HQ
(`https://hq.amineben.ch/api/public/numbers`, lu chaque jour par le site ; `cv/fetch-numbers.mjs`
et `.github/workflows/cv.yml` reconstruisent les CV le lundi). Cette skill s'occupe de ce qui
demande du jugement.

## Règles qui ne bougent pas

- **Ne jamais inventer.** Une phrase vient d'un fichier de faits, d'un commit, d'une doc du repo
  ou de moi. EPFL = deux premières années, jamais un diplôme. Anglais B2.
- **Jamais en public** (site, CV, LinkedIn) : Job HQ, dawah-map, les coûts d'API d'Ironmile, des
  données d'utilisateurs, des captures de HQ avec des données. HQ = architecture seulement.
- Un travail pour un client ou une association : le nommer et montrer des captures seulement si je
  l'ai autorisé (déjà oui : Simple Je, It's Time Barber, CIAO / ontécoute.ch). Sinon : demander.
- Pas de note App Store tant que le flux dit `rating: null` (moins de 10 avis).

## 1. Préparer (routine dans le cloud)

Repos (ajouter avec `add_repo`, cloner selon sa réponse) : `amineben` et `job-hq` (écriture),
`qiyam-app`, `ironmile`, `headquarters`, `ciao`, `starter`, `claude-setup` (lecture). Repère de la
dernière passe : réglage `aligner_last_run` dans la base de Job HQ (Neon, projet `job-hq`
`frosty-violet-16640419`, branche par défaut = production, table `settings`, valeur ISO). Pas de
repère : prendre 7 jours.

## 2. Ce qui a changé depuis le repère

- **Faits des apps** : `qiyam-app/spec/facts.json` (+ `docs/marketing/RELEASE-NOTES.md`,
  `docs/technical/31-ANDROID-STRATEGY.md`), `ironmile/apps/api/lib/product/facts.ts` (+
  `docs/business/decisions.md`, `apps/api/lib/launch.ts`). `git log --since=<repère>` et le diff
  de ces fichiers (récupérer l'historique avec `git fetch --shallow-since=<repère>`).
- **Le flux HQ** : Ironmile `status` passé à `live` ? (le site bascule seul ; les CV, la routine
  et LinkedIn, non).
- **Les autres repos** : `ciao`, `starter`, `headquarters` (architecture), et tout **nouveau
  repo** (`list_repos` : créé ou poussé depuis le repère, hors `job-hq`, `dawah-map`,
  `claude-setup`, `ai-job-search`, `instructions`, anciens prototypes).
- Rien de remarquable : mettre à jour le repère, terminer (pas de commit vide).

## 3. Passer ce qui me décrit

Lire chaque endroit en entier (une phrase devient fausse sans reprendre les mots du fait) :

| Où | Fichiers |
|---|---|
| Site amineben.ch | `amineben/content/` (projets, parcours, textes FR et EN, faits de secours des chiffres) et les pages d'étude de cas |
| CV (4 variantes × FR/EN) | `job-hq/cv/content.mjs` (seule source), rendu `node cv/build.mjs --cvs-only` |
| Routine de candidatures | `job-hq/ROUTINE.md`, section « Who Amine is » ; `job-hq/READING.md` si un nouveau type de poste devient pertinent |
| LinkedIn | `job-hq/docs/linkedin.md` (appliqué par le Claude du Mac avec Claude in Chrome, quand je le demande) |

## 4. Corriger ou demander

**Petit = je corrige moi-même**, dans les quatre endroits à la fois : un statut (« en revue » →
« sur l'App Store », test fermé → public), une version, une date, une plateforme, une ligne de
stack, un chiffre que le flux ne couvre pas (nombre de tests, d'écrans), une phrase devenue fausse.
Puis :
- `amineben` : `pnpm typecheck`, `pnpm lint`, `pnpm build` ; commit sur `main` (« Aligner
  carrière : … ») et push (Vercel redéploie) ; contrôle en lecture de la page en ligne.
- `job-hq` : `CHROME_PATH=<chromium> node cv/build.mjs --cvs-only`, regarder chaque page rendue
  (`pdftoppm`) : une page, rien ne déborde ; commit et push sur `main`.

**Gros = je ne le fais pas, je le demande** : un nouveau projet (étude de cas, captures,
autorisation du client), un projet à mettre en avant ou à retirer, une étude de cas à réécrire,
une nouvelle variante de CV ou une nouvelle famille de postes. Pour chacun, un rappel dans Job HQ
(il apparaît dans « Needs you » et part en notification) :

```sql
insert into reminders (offer_id, kind, due_at, note, url)
values (null, 'career', now(), '<ce qui a changé, ce que je propose, en 2 phrases>', '<lien : commit, page, repo>');
```

## 5. Terminer

- Mettre `aligner_last_run` à l'heure de début de cette passe.
- Compte rendu court : corrigé (où, commits), demandé (rappels créés), rien à faire.
- Une leçon qui vaut pour l'avenir (nouvel endroit qui me décrit, nouvelle règle) : l'ajouter ici.
