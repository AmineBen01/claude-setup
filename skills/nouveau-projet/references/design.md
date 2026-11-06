# Concevoir une interface : sur mesure, jamais un modèle

Décidé le 1er novembre 2026. Il n'y a plus de look maison : ni Stripe, Linear ou Vercel comme
référence par défaut, ni police, couleur, forme ou barre latérale imposées. Chaque projet reçoit un
design de haut niveau, tiré de son sujet et de ses utilisateurs, avec la skill `frontend-design`.
Le niveau attendu : l'identité d'Ironmile (`~/Projects/ironmile/brand/README.md`) ; Amine : « c'est
le niveau de travail et d'attention au détail que j'attends ».

**Projet existant dont le `CLAUDE.md` cite l'ancien guide** : son look reste celui de
`ancien-style-sobre.md` tant qu'Amine ne demande pas sa refonte.

## Ce qui reste obligatoire : l'usage

- **Mobile d'abord**, puis l'élargissement.
- **44 px minimum** pour toute cible tactile sur téléphone.
- **Clair et sombre** qui suivent l'appareil, avec un choix Clair / Sombre / Auto
  (`next-themes`, `attribute="class"`, `defaultTheme="system"`, `themeColor` par schéma). Les deux
  thèmes sont dessinés, le sombre n'est pas une inversion.
- **La largeur des grands écrans sert** : jamais une colonne étroite seule au milieu de 1440 px.
- **Jamais enfantin** : Amine a jugé ainsi le look « mignon » et ses gros boutons arrondis. La
  question est le ton de l'ensemble, pas une forme interdite.
- **Du mouvement, au niveau d'Apex** (décidé le 6 novembre 2026 : « fais-le dans tous mes futurs
  projets ») : voir « Le mouvement » plus bas.

Tout le reste se décide pour le projet.

## Quand passer par les planches

| Travail | Démarche |
|---|---|
| Nouveau projet, refonte complète, y compris les outils internes | Tout le parcours ci-dessous |
| Grand nouvel écran : une page ou un parcours avec sa propre tâche principale | Tout le parcours ; dans un projet existant, à l'intérieur de son identité, sauf refonte demandée |
| Petit ajout (un champ, une ligne, un état, un réglage) | Suivre `brand/README.md` du projet, sans planches |

Dans le doute sur « grand » : si Amine découvrirait une nouvelle façon d'utiliser le produit, c'est
un grand écran.

## Le parcours, dans cet ordre

### 1. La carte des tâches, validée avant tout visuel

Pour chaque écran, en langage simple : **qui arrive ici et pourquoi ; ce qu'il doit comprendre en
5 secondes ; la prochaine action ; ce qui peut attendre un niveau plus bas**. Partir des vraies
données et, pour une refonte, de ce qui gêne aujourd'hui. Amine valide avec AskUserQuestion ; les
planches montrent ensuite ces tâches-là, pas un décor.

### 2. Deux ou trois références du domaine

Étudier 2 ou 3 des meilleurs produits **de ce domaine précis**, pas toujours les mêmes noms. Dire ce
qu'on en reprend et pourquoi : un mécanisme d'usage, jamais un look copié. Vérifier ce qu'ils
montrent aujourd'hui plutôt que de citer de mémoire.

### 3. Trois directions artistiques, sur planches

Toujours avec `frontend-design`, en planches HTML rendues par Chrome sans fenêtre et ouvertes dans
Aperçu (dire l'ordre).

- **Vraiment différentes** : chacune part d'une idée tirée du monde du sujet, et change la
  composition, la typographie, la couleur, la densité et la façon de montrer les données. Trois
  variantes de couleur d'un même écran ne comptent pas.
- **Mêmes écrans principaux**, avec le **vrai contenu** (ou des données réalistes), sur téléphone et
  1440 px, en clair et en sombre.
- **Écrire pour chacune** son idée en une phrase, ce qu'elle rend plus facile, et ce qu'elle coûte.
- **Éviter les looks de série** : tableau de bord SaaS gris, crème et serif, néon sur noir, dégradé
  violet, éclairs, cartes identiques partout. **Se critiquer et redessiner avant de montrer.**

Si la marque n'existe pas, la marque passe d'abord (`SKILL.md`, étape 1 bis).

### 4. Le choix, puis la planche combinée

Amine peut choisir écran par écran et mélanger. Une planche combinée vérifie que l'ensemble tient ;
il la valide ; seulement alors le code commence.

### 5. Écrire le système dans le repo

`brand/README.md` : l'idée, la typographie, les couleurs clair et sombre, la composition, le
composant signature, le motif, la voix, le mouvement, et ce qui est interdit **à ce projet**. Toutes
les valeurs vivent dans un seul endroit du code (`globals.css`, `layout.tsx`). Pour un projet tiré
du starter : remplir `apps/web/design-direction.json` et retirer la base nue, sinon le build échoue.

### 6. Le critique indépendant, sur le vrai produit

Pour un nouveau projet, une refonte ou un grand écran, une fois construit (`verifier`, section
« Critique ») : un agent qui n'a pas vu ce raisonnement juge le produit.

## Le mouvement

Amine, sur Apex : l'app ne doit pas être inerte. Les actions qui tombent à plat, les écrans qui
apparaissent d'un coup et l'absence de récompense le gênaient. Le niveau voulu : **discret et rapide
partout, expressif à un ou trois endroits**, autant sur ordinateur que sur téléphone. Référence
construite : Apex (`~/Projects/apex/brand/README.md`, « Motion »). Le starter apporte la mécanique
(`components/motion.tsx`, `lib/celebrate.ts`, `components/celebration.tsx`, fin de `globals.css`).

- **Seulement en réponse** à ce que fait la personne, ou pour une récompense ; jamais d'animation
  qui tourne toute seule (fond, entrée de chaque section au chargement, survol de chaque carte).
- **Les quatre couches**, toutes présentes :
  1. **Le geste** : cocher, valider, enregistrer répond tout de suite (la case qui « pop » et dessine
     sa coche, `.tick-pop`, seulement quand on vient de cocher).
  2. **Les éléments d'une liste** arrivent, partent et glissent vers leur nouvelle place
     (`ItemMotion`, nommé par l'id ; un id visible deux fois annule l'animation).
  3. **Les écrans** : le contenu se fond, le cadre (barre, onglets) reste immobile ; les flèches
     précédent/suivant glissent dans le sens du geste (`transitionTypes`).
  4. **La récompense** : un à trois moments où la personne a fini quelque chose qui compte, choisis
     avec Amine pendant le cadrage (sur Apex : la dernière tâche du jour, la dernière habitude, un
     jalon). Son dessin vient de la signature du projet (sur Apex, le soleil de la marque qui monte
     jusqu'à l'apex), jamais des confettis de série. Une fois par jour pour un moment quotidien,
     jamais au chargement.
- **Durées** : 150 / 220 / 300 ms, une courbe ; la récompense ~800 ms. Le projet peut les accorder à
  sa marque, pas les enlever.
- **Pas de bibliothèque** pour ça : `<ViewTransition>` de React 19.3 (sur le web) anime ce que le
  serveur a renvoyé. Une app Expo suit les mêmes quatre couches avec Reanimated.
- **« Réduire les animations »** de l'appareil coupe tout ; la récompense s'affiche immobile.
- `brand/README.md` du projet écrit son mouvement (ses moments, son dessin) ; `verifier` prouve que
  chaque transition se termine sans erreur (envelopper `document.startViewTransition` et lire
  `finished` / `ready`) et que la récompense part au bon moment, une seule fois.

## Ce qu'une bonne interface fait toujours

- **Ce qui demande une action vient d'abord** : en arrivant, on sait quoi faire, et quand il n'y a
  rien à faire, l'écran le dit.
- **Une action principale par écran**, atteignable au pouce, sans quitter ce qu'il faut lire pour
  décider.
- **Un chiffre a un sens** : il vient avec une comparaison, une tendance ou un seuil, et l'écran dit
  si c'est bien ou non.
- **Un statut se comprend sans légende**, et jamais par la couleur seule.
- **La navigation suit les tâches**, pas la base de données : les usages quotidiens à un geste, le
  reste plus bas.
- **Aucune impasse** : les états vide, chargement, erreur et hors-ligne sont dessinés et disent quoi
  faire ensuite.

## Le test final

Devant chaque écran : **sans le logo, reconnaîtrait-on ce projet ?** Et : **quelqu'un qui arrive
comprend-il en 5 secondes quoi faire ?** Si non à l'une des deux, ce n'est pas fini.
