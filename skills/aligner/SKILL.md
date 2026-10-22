---
name: aligner
description: Après un changement qu'on remarque dans une app (Qiyam, Ironmile), remettre d'accord tout ce qui la décrit — site, fiches App Store et Google Play, notes de l'écrivain et du growth lead dans HQ, captures — avec la liste de faits de l'app. Corrige les phrases fausses soi-même ; ce qui demande une nouvelle section, une refonte ou de nouvelles captures devient une demande dans HQ. À utiliser dans `mise-en-ligne` dès qu'un changement touche ce que l'utilisateur voit ou ce que fait l'app, ou quand l'utilisateur dit « aligne », « mets le site à jour », « vérifie que tout est encore vrai ».
---

# Aligner

Décidé le 21 octobre 2026, après des posts qui contredisaient le nouveau coach d'Ironmile. Chaque
app a **une liste de faits** (ce qu'elle dit vrai d'elle-même) ; tout ce qui la décrit doit dire
la même chose. Les posts de HQ se signalent tout seuls quand un fait change (`docs/app-facts.md`
dans `../headquarters`) ; cette skill s'occupe du reste, qui demande du jugement.

**Quand :** après tout changement qu'on remarque dans l'app ou dans ce qu'elle fait (une règle,
une fonctionnalité, un prix, une plateforme), une fois le commit prêt. Pas après une correction
interne invisible.

## 1. Partir des faits

| App | Faits | Envoyés à HQ |
|---|---|---|
| Ironmile | `../ironmile/apps/api/lib/product/facts.ts` (chiffres lus dans `coach/rules.ts`) | à chaque push (`.github/workflows/facts.yml`) |
| Qiyam | `../qiyam-app/spec/facts.json` (testés par `FactsSpecTest`) | quand le fichier change |

1. Le changement a-t-il mis les faits à jour ? Sinon, c'est la première chose à faire, dans le même
   commit (une fonctionnalité nouvelle = un fait ; une règle changée = sa nouvelle phrase ; une
   version Qiyam = `since`). Un chiffre énoncé = une ligne de test.
2. Noter ce qui a changé : faits ajoutés, modifiés, retirés (`git diff` du fichier de faits), et ce
   que le changement montre à l'écran.

## 2. Passer chaque endroit qui décrit l'app

Lire chacun en entier, pas seulement chercher des mots : une phrase peut devenir fausse sans
reprendre les mots du fait.

**Ironmile**
- ironmile.app : `apps/api/app/page.tsx` (les règles et le prix viennent déjà des faits ; le reste
  est du texte), `apps/api/app/support/`, les captures `apps/api/public/screens/`.
- La fiche App Store : `docs/store/listing.md` (envoyée par `scripts/asc-listing.mjs`) et les
  captures `store/screenshots/`.
- HQ : `writer/ironmile/*.md` (voix, séries, blocs), `lib/ironmile/samples.ts`,
  `.claude/skills/growth-lead/references/ironmile.md`.

**Qiyam**
- qiyamapp.com (`../qiyam-website`) : `app/page.tsx`, `app/android/page.tsx`, `app/llms.txt`,
  `app/layout.tsx` (description), `components/blog/BlogCTA.tsx`, et les articles
  `content/blog/*.md` qui parlent de l'app (tag « App Features » et toute mention de Qiyam).
- Les fiches : `docs/marketing/APP-STORE-LISTING.md`, `PLAY-STORE-LISTING.md`, les pages
  « Nouveautés » (`spec/whats-new.json`) de la version en cours.
- HQ : `writer/voice.md`, `writer/series/inside-qiyam.md`, les `shows` et `facts` des captures
  (`scripts/capture-app-screens.ts`, `data/app-screens.json`), `.claude/skills/growth-lead/references/qiyam.md`.

## 3. Corriger ou demander

- **Une phrase fausse ou dépassée** (un chiffre, une règle, une plateforme, une fonctionnalité qui
  a changé de nom ou de palier) : la corriger soi-même, dans le dépôt concerné, en reprenant la
  phrase du fait. Commit et push dans ce dépôt (« Aligner : … »), avec la règle de livraison de
  chaque projet.
- **Ce qui demande du jugement ou du design** : une nouvelle section pour une fonctionnalité, une
  refonte, de nouvelles captures, un article à réécrire : ne pas le faire ; déposer une demande
  dans HQ (`POST /api/lead/requests`, `docs/lead-api.md`) : `target` (`ironmile`, `qiyam-app`,
  `qiyam-website`, `hq`), `kind` `feature` ou `fix`, `title`, `body` (quoi, où, d'après quels faits),
  `why` (le changement qui l'a rendu nécessaire). Amine approuve ; la session suivante sur ce dépôt
  la construit, avec ses questions.
- Un article de blog dont l'idée reste vraie mais un détail a changé : corriger le détail. Un
  article bâti sur ce qui n'est plus vrai : demande.
- Ne jamais écrire une affirmation qu'aucun fait ne soutient, ni un prix ou une durée d'essai pour
  Qiyam.

Un dépôt absent (session dans le cloud) : tout ce qu'on n'a pas pu lire ou corriger devient une
demande, et on le dit.

## 4. Rendre compte

Dans le message de livraison : les endroits passés, ce qui a été corrigé (dépôt, fichier, phrase
avant → après), les demandes déposées (titre), et ce qui n'a pas pu être vérifié.
