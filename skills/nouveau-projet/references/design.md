# Le style de mes interfaces : un outil précis et sobre

Validé sur le studio de contenu Qiyam (15 octobre 2026) : « c'est le type et le niveau de
design que je veux ». À appliquer à toute nouvelle app et à tout écran remanié, avec la skill
`frontend-design`. Implémentation de référence : **AmineBen01/content** (`app/globals.css`,
`components/ui/button.tsx`, `components/status-badge.tsx`, `app/(studio)/page.tsx`,
`app/(studio)/settings/page.tsx`, `components/post-workspace.tsx`).

Références : **Linear**, le tableau de bord **Vercel / Stripe**, **Notion**.

## Ce que je ne veux plus (« enfantin », « slop »)

- Boutons en pilule, coins de 16 px partout, boutons de 56 px de haut.
- Blocs de couleur pleine (une tuile de statistique bleue), pastilles teintées vert menthe ou
  ambre, graphiques bicolores criards.
- Le kit « SaaS » : chaque bloc dans la même carte blanche avec ombre, quel que soit le contenu.
- Une seule police sans échelle typographique : titres et texte qui se ressemblent.

## Les choix

- **Le contenu porte la couleur** (visuels, images, données). L'interface reste neutre : une
  seule couleur d'action (celle de la marque), tout le reste en gris et en encre.
- **Typographie : Geist** (`next/font/google`), échelle 12 / 13 / 14 / 15 / 17 / 20 / 24 px.
  Titres de page 17 px sur téléphone, 15 px sur ordinateur ; titres de section 15 px semibold
  avec une description de 13 px en gris ; chiffres en `tabular-nums`. Graisse 500 pour les
  boutons, 600 pour les titres, jamais 700. Garder la police de marque pour le contenu
  lui-même (ex. les diapositives) si elle existe.
- **Couleurs, clair :** fond `#f7f8fa`, surfaces blanches, encre `#0f1b2d` (teintée de la
  marque), texte secondaire `#5b6676`, lignes `#e4e7ec`, champs `#d5dae2`, action = couleur de
  la marque.
- **Couleurs, sombre : graphite avec une pointe de bleu**, pas la couleur de la marque : fond
  `#0d1117`, surfaces `#151a22`, menus `#1b212b`, lignes `#262d38`, texte `#e6eaf0`,
  secondaire `#8b95a5`, action = la couleur de la marque éclaircie.
- **Statuts : un point de couleur + le mot en gris** (ambre à relire, bleu programmé, vert
  publié, rouge échec, point vide pour neutre). Jamais de pastille pleine.
- **Coins :** 6 px pour les contrôles, 8 px pour les panneaux (`--radius: 0.5rem`). Pas
  d'ombre, sauf menus et panneaux qui s'ouvrent.
- **Structure :** des listes à filets (`divide-y` dans un panneau bordé) plutôt que des cartes
  empilées ; une bande de chiffres séparés par des filets plutôt que des tuiles ; les
  réglages en lignes « titre + description à gauche, contrôle à droite ».
- **Boutons :** 44 px de haut sur téléphone (minimum tactile d'Apple), 36 px sur ordinateur
  (`h-11 md:h-9`), 15 px / 14 px. Un bouton principal désactivé devient gris neutre, pas bleu
  délavé.
- **Navigation :** barre latérale compacte (lignes de 32 px, compteurs en gris alignés à
  droite, l'élément actif sur fond gris léger), en-tête de 48 px ; sur téléphone, onglets en
  bas de 56 px, icônes 20 px trait fin, l'onglet actif en encre (pas en couleur).
- **Écran de décision** (relire, approuver) : sur ordinateur la scène à gauche et un panneau
  bordé à droite, collant ; sur téléphone **une barre fixe fine** au-dessus des onglets avec
  l'action principale large et remplie, les secondaires compactes.
- **Mouvement :** aucun, sauf l'ouverture des menus et panneaux. Pas d'apparitions animées.
- **Textes :** phrases courtes, casse de phrase, pas de libellés en MAJUSCULES, pas de
  « A · B · C » (des virgules), pas de flèche ajoutée aux liens.

## Vérifier

Captures en clair et en sombre, iPhone, Android et 1440 px. Se demander devant chaque écran :
est-ce que ça pourrait être un écran de Linear ou de Vercel ? Si un élément attire l'œil sans
être le contenu ou l'action principale, l'enlever.
