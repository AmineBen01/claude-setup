# La file de Claude : Apex (le détail)

Lu au début d'une session de travail sur `qiyam-app`, `qiyam-website`, `ironmile`, `headquarters`, `studio`,
`apex`, `job` ou `amineben`, et pour le setup et le travail transversal : une session lancée dans `~/Projects`,
`~/.claude`, `starter` ou `ops` lit la file `claude-setup` (projet « Claude setup », créé le 13 novembre 2026)
(voir le CLAUDE.md global).

**La revue du 13 novembre 2026** a rempli les files (38 to-dos, chacune autonome) : quand une note cite un
identifiant de constat (X-1, HQ-3, QA-2…), le détail est dans `~/Projects/review-2026-11/` (`findings.md`,
`plan.md`, `reports/`) s'il est là ; les lignes citées datent du 13 novembre, à relire avant de corriger.

Décidé le 4 novembre 2026, « HQ décide, Apex planifie » ; une file par projet depuis le 6 novembre.
**Apex** (https://apex.amineben.ch, mon planificateur, `~/Projects/apex`) est ta **seule file de
travail**. Tâches et idées n'y font plus qu'une, dans deux listes (6 novembre, à la place de la matrice
et de Someday) : **Now**, la priorité du moment, et **Later**, le reste. La **file** d'un projet de code
(Qiyam, Ironmile, HQ, Studio, Apex), c'est son **Now**, échéances d'abord puis les plus anciennes (une indication, pas une
consigne) : la prochaine session fait tout ce qui y est. Later n'en fait jamais partie. Les demandes du
growth lead que j'ai approuvées dans HQ arrivent dans Later toutes seules (« from growth lead ») ; c'est
moi qui les passe dans Now.

1. lis la file de ce repo, son Now (`~/Projects/apex/docs/claude-api.md`, jeton dans le trousseau :
   `apex-claude-token`) ; si elle est vide, dis-le et arrête-toi là ;
2. annonce-la-moi, puis **organise toi-même le travail** (l'ordre de la file n'est qu'une indication) :
   d'abord les petits correctifs et les bugs (cause prouvée, sans tour de questions ; un sous-agent par
   repo s'ils sont indépendants et que le gain est net), livrés ensemble ; ensuite les fonctionnalités
   et changements qui demandent des questions, cadrés par petits lots de 3 ou 4 (l'intention d'abord,
   comme pour toute fonctionnalité), construits, vérifiés, livrés, puis le lot suivant. Saute celles
   marquées `held` (« HELD until… » dans les notes) et dis-le ;
3. marque chacune « done » avec une note d'une ligne (commit, ce qui a changé) une fois livrée. Apex
   prévient HQ tout seul.

N'interroge plus les demandes de HQ directement.
