# Une app pour apprendre : les principes

Tirés de Briefing (manuel interactif SPHAIR, novembre 2026), puis triés par Amine le 6 novembre 2026.
**À lire avant de concevoir une app ou un module d'apprentissage** (et Learning HQ, son futur toit
commun). Ce fichier grandira avec les recherches d'Amine sur l'étude et la mémoire : une règle qui en
sort s'ajoute ici, avec sa source. Le code de référence est Briefing (`~/Projects/briefing`,
`apps/web/lib/learning.ts`, `lib/plan.ts`, `lib/versions.ts`, `docs/decisions.md`).

## Quoi étudier, et quand

1. **Mesurer d'abord, à la bonne échelle.** Un test de positionnement décide de l'ordre. Le nombre de
   questions suit la taille et la densité de la matière : un chapitre court peut en avoir deux, un
   chapitre long et détaillé se mesure partie par partie. Un sujet n'a pas forcément de chapitres
   égaux ; le découpage (chapitre, partie, notion) s'adapte au matériau.
2. **Apprendre avant de s'interroger.** Une question ratée ne revient pas tant que sa partie n'a pas
   été lue.
3. **Ne sauter que ce qui est vraiment acquis, mesuré de façon fiable.** Jamais sur une ou deux
   questions. La maîtrise d'une partie combine plusieurs mesures : assez de questions et sur toutes
   ses notions, plusieurs formats et variantes, la justesse **dans le temps** (une réponse juste après
   un délai vaut plus qu'une réponse juste après la lecture), la confiance déclarée, le temps de
   réponse, le niveau des questions réussies. Tant qu'il n'y a pas assez de mesures, on le dit
   (« première mesure ») au lieu de trancher.
4. **Une ligne d'arrivée, toujours.** Un examen réel quand il y en a un ; sinon une date que la
   personne se fixe, parce qu'une ligne d'arrivée fait avancer chaque jour. Le plan jour par jour en
   part : le plus faible d'abord, la veille pour s'entraîner en conditions réelles, le jour même rien
   de nouveau ; ce qu'un jour n'a pas fini passe au lendemain, marqué « en retard ».
5. **Une seule prochaine action** sur l'accueil : on n'a jamais à décider quoi faire.
6. **Dire quand la journée est finie** (« Fini pour aujourd'hui »), avec l'avance en option.
7. **Le compte à rebours** jusqu'à la ligne d'arrivée, sur l'accueil.

## Comment une leçon enseigne

8. **L'ordre du manuel, et des explications abondamment claires.** Les parties suivent l'ordre du
   livre de référence. Chaque partie s'ouvre sur une introduction (pourquoi c'est utile, ce qu'on va
   voir), puis plonge progressivement du simple au détaillé, avec des analogies et des intuitions,
   des exemples, la règle à retenir et ses pièges. Le but est la compréhension profonde : on préfère
   une explication plus longue et limpide à un résumé.
9. **Prédire avant de lire la suite** : on répond avant que l'explication apparaisse.
10. **Les exemples corrigés restent cachés jusqu'à l'essai sur papier.**
11. **Les pièges sont nommés** : l'erreur classique et sa correction, à l'encre rouge dans la marge.
12. **Des schémas qu'on manipule** : curseurs, animations, choses à essayer (pause hors de l'écran,
    mouvement réduit respecté).
13. **Une série de 10 questions juste après la lecture**, sur cette partie seulement.

## Comment la mémoire s'entraîne

14. **Répétition espacée, adaptée à la ligne d'arrivée** (Briefing : 2 h, 5 h, 20 h, 48 h, rien
    après le matin de l'examen). Le premier retour d'une question ratée vient 1 à 2 h plus tard, pas
    10 min : la répétition dans la même séance, c'est la question ratée reposée en fin de série ;
    à 10 min, les révisions dues envahissent chaque séance et on n'avance plus (Amine, 7 nov. 2026).
15. **Trois réponses de confiance : « Sûr », « Pas sûr », « Je ne sais pas ».** « Je ne sais pas »
    évite de deviner et distingue « jamais appris » (à enseigner) de « mal compris » ; une erreur
    « Sûr » signale une idée fausse, le signal le plus important à corriger. Une bonne réponse
    « Pas sûr » ne compte qu'à moitié et revient plus tôt.
16. **Une question ratée revient en fin de série**, puis au prochain briefing.
17. **Une question change quand elle revient** : autres nombres ou autre situation, même idée, bonne
    réponse ailleurs ; on montre la version vue il y a le plus longtemps. Écrites et revérifiées
    comme le reste (règle 30).
18. **Des briefings courts** (une douzaine de questions, 10 minutes), faits pour le téléphone.

## Voir ses points faibles

19. **Un niveau par partie avec des seuils clairs**, calculé selon la règle 3.
20. **Les idées faibles, pas seulement les chapitres faibles** (« Corrigé en rouge »).
21. **Un carnet d'erreurs avec une raison** (notion, calcul, mal lu, piège), et une série « refaire
    mes erreurs ».

## Conditions réelles

22. **Les formats de la vraie épreuve**, quand il y en a une.
23. **Des examens blancs chronométrés** : la vraie cadence, pas de correction avant la fin, reprise
    après un rechargement.
24. **Les examens tirent des questions de niveau épreuve** dans toutes les parties, en évitant ce que
    les examens précédents ont déjà pris.
25. **Des fiches avec les réponses cachées**, pour se tester.

## Comment les questions sont écrites

26. **Chaque explication dit pourquoi la bonne réponse est juste et pourquoi la fausse tentante est
    fausse.**
27. **Les mauvais choix viennent de vraies erreurs** (oublier le carré, prendre l'inverse…).
28. **Les bonnes réponses se répartissent entre A et D.**
29. **Tout reste dans la matière source** : une question n'exige que ce que la leçon enseigne.
30. **Une IA écrit, une autre résout tout de son côté** et corrige avant que l'élève ne voie rien
    (Briefing : `docs/claude/content-review.md`, `variants-brief.md`, `variants-review.md`).

## Appareils

31. **L'ordinateur et une feuille pour apprendre ; le téléphone pour les révisions rapides, les
    questions et les fiches.** Installable sur l'écran d'accueil.
32. **Raccourcis clavier sur ordinateur** (A–D, Entrée) ; grandes zones tactiles sur téléphone.
33. **Un design tiré du sujet** (Briefing : un cahier de labo), en clair et en sombre.

## Sous le capot

34. **Aucune réponse ne se perd** : file d'envoi sur l'appareil, hors ligne compris.
35. **Le serveur décide si une réponse est juste**, jamais l'appareil.
36. **Les leçons et les questions sont du code**, avec des ids permanents et des tests qui font
    respecter ces règles.
37. **Toutes les règles d'apprentissage vivent dans un seul module testé** : chaque écran est d'accord.
38. **Un seul endroit pour tout apprendre** (décision en cours, 6 novembre 2026) : Learning HQ, une
    plateforme avec connexion où chaque sujet est un paquet de contenu avec sa ligne d'arrivée,
    plutôt qu'une app par sujet. Projet « Learning HQ » dans Apex.
