# Le style de mes interfaces : un outil précis et sobre

Validé sur le studio de contenu Qiyam (15 octobre 2026) : « c'est le type et le niveau de
design que je veux ». À appliquer à toute nouvelle app et à tout écran remanié, avec la skill
`frontend-design`. Implémentation de référence : **AmineBen01/content** (`app/globals.css`,
`components/ui/button.tsx`, `components/status-badge.tsx`, `app/(studio)/page.tsx`,
`app/(studio)/settings/page.tsx`, `components/post-workspace.tsx`).

Références : **Linear**, le tableau de bord **Vercel / Stripe**, **Notion**.

## Outil ou app grand public : la question à trancher d'abord

Ce guide décrit un **outil** (studio, HQ, tableau de bord) : sobre, neutre, au service des
données. Appliqué tel quel à une **app grand public** (qu'on ouvre pour soi, chaque jour), il
donne un look « Expo / shadcn par défaut » qu'on ne reconnaît pas (constaté sur Ironmile le
20 octobre 2026).

Pour une app grand public, la base reste celle-ci (gris neutres, une couleur d'action, pas
d'ombres, pas de pilules, rien d'enfantin), **plus un système d'identité obligatoire**, tiré du
monde du sujet, pour qu'on reconnaisse l'app sur une seule capture sans le logo :

- **une police de marque** pour les titres et **les chiffres** (Geist reste pour le texte) ;
- **un composant signature** présent sur les écrans principaux (Ironmile : la bande de la
  semaine) ;
- **un motif** qui revient (Ironmile : la route, ses jalons et ses tirets) ;
- **une voix** (Ironmile : le coach en Barlow italique, phrases courtes) ;
- **une seule surface de couleur de marque**, pour la chose la plus importante de l'écran
  principal (Ironmile : la séance du jour) ; partout ailleurs la couleur reste sur l'action ;
- **un seul mouvement orchestré**, qui répond à un vrai moment (Ironmile : les barres de la
  semaine qui poussent quand le coach l'a écrite). Il joue pour tout le monde : pas de version
  coupée pour « Réduire les animations » (décidé le 21 octobre 2026).

Exemple de référence : Ironmile, `brand/README.md` (règles) et
`apps/mobile/src/components/{week-band,road,today-hero}.tsx`.

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
- **Gris neutres, sans teinte** (décidé le 16 octobre 2026 sur Qiyam HQ : le graphite bleuté
  du studio faisait « bizarre » ; le studio garde son ancien thème tant que je ne demande
  pas de le changer). Seule la couleur d'action et les données portent la marque.
- **Couleurs, clair :** fond `#fafafa`, surfaces blanches, encre `#0a0a0a`, texte secondaire
  `#6b6b6b`, lignes `#e5e5e5`, champs `#d4d4d4`, action = couleur de la marque.
- **Couleurs, sombre : charbon doux, neutre** (style Linear / Notion), jamais un noir bleuté :
  fond `#121212`, surfaces `#181818`, menus `#202020`, lignes `#2a2a2a`, texte `#e8e8e8`,
  secondaire `#9a9a9a`, action = la couleur de la marque éclaircie.
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
- **Barre latérale (ordinateur), comme ChatGPT** (décidé le 17 octobre 2026 après le même
  défaut sur le studio et Qiyam HQ) :
  - le **bouton de repli est dans la barre**, en haut à droite à côté du logo ; l'en-tête de la
    page n'a ni bouton de repli ni trait vertical (pas de `SidebarTrigger` + `Separator` dans
    l'en-tête) ;
  - **repliée**, il ne reste que le logo, **toujours carré** (`size-6 shrink-0` dans un bouton
    `size-8`, jamais dans un `SidebarMenuButton` qui le rétrécit) ; **au survol, le logo devient
    le bouton d'ouverture** (icône `PanelLeftOpen`) ;
  - **un fin interstice entre les entrées** (`SidebarMenu` en `gap-0.5`) : le gris du survol ne
    se colle jamais au gris de l'entrée active ;
  - modèle prêt : `references/modeles/sidebar-top.tsx` (bascule en CSS sur
    `group-data-[collapsible=icon]`, donc même rendu serveur et navigateur).
- **Écran de décision** (relire, approuver) : sur ordinateur la scène à gauche et un panneau
  bordé à droite, collant ; sur téléphone **une barre fixe fine** au-dessus des onglets avec
  l'action principale large et remplie, les secondaires compactes.
- **Mouvement :** aucun, sauf l'ouverture des menus et panneaux. Pas d'apparitions animées.
  (App grand public : un seul moment orchestré en plus, voir plus haut.)
- **Textes :** phrases courtes, casse de phrase, pas de libellés en MAJUSCULES, pas de
  « A · B · C » (des virgules), pas de flèche ajoutée aux liens.

## Vérifier

Captures en clair et en sombre, iPhone, Android et 1440 px. Se demander devant chaque écran :
- **outil** : est-ce que ça pourrait être un écran de Linear ou de Vercel ?
- **app grand public** : sans le logo, reconnaîtrait-on l'app sur cette capture ? Si non, il
  manque la signature.

Dans les deux cas, si un élément attire l'œil sans être le contenu ou l'action principale,
l'enlever.
