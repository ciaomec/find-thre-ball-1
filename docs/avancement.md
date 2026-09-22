# Avancement et décisions à prendre

## Où on en est

| Phase | État | Détail |
|---|---|---|
| 0 — Mise en place | **en cours** | Dépôt créé, `ConfigJeu` écrit. Reste : appairer Claude et Studio sur le Mac. |
| 1 — Œufs et éclosion | à faire | Bloquée par une décision (voir plus bas) |

### Fait

- Dépôt Git créé avec la structure `src/` qui reflète Studio.
- `docs/passation.md` : toute la vision v2, conservée telle quelle.
- `docs/appairage-roblox-studio.md` : la marche à suivre pour relier Claude à Studio.
- `CLAUDE.md` : les règles de travail (langue, ton, pièges connus).
- `src/ReplicatedStorage/ConfigJeu.lua` : le module de réglages v2, **pas encore posé dans Studio**.

### Prochaine action

Appairer Claude et Roblox Studio sur le Mac → `docs/appairage-roblox-studio.md`.

---

## Correction repérée dans la passation

La passation annonce **43 œufs** et **301 balles** à l'index.
En comptant les œufs réellement décrits, on trouve :

| Zone | Nombre d'œufs |
|---|---|
| 1 Ping-pong | 6 |
| 2 Golf | 6 |
| 3 Tennis | 6 |
| 4 Baseball | 6 |
| 5 Rugby | 7 |
| 6 Basket | 7 |
| 7 Football | 7 |
| **Total** | **45** |

Donc **45 œufs × 7 raretés = 315 balles**, pas 301.
`ConfigJeu` contient bien les 45 œufs. Les 43/301 de la passation sont à corriger
partout où ils apparaissent (index, quêtes, textes du jeu).

---

## Décisions en attente de Laurence

Rangées par urgence : les premières bloquent la phase 1.

| # | Sujet | Question | Bloque |
|---|---|---|---|
| 1 | Éclosion | L'œuf éclôt **tout seul** dès qu'il est posé sur le socle, ou il faut appuyer sur **E** ? | Phase 1 |
| 2 | Temps d'éclosion | On garde les longues attentes (Ballon d'Or = 45 min) ou on raccourcit ? | Phase 1 |
| 3 | Améliorations Robux v1 | Comment compenser les joueurs qui ont payé, au passage sur `FindTheBall_v2` ? | Phase 1 |
| 4 | Game Pass Double portage | À créer sur le Creator Hub (Monétisation > Passes), puis mettre l'ID dans `ConfigJeu.PassDoublePortage.Id` | Phase 1 |
| 5 | Événements | Les mutations disparaissent : on les remplace par quoi (ex. « pluie d'œufs rares ») ? | Phase 5 |
| 6 | Gains hors ligne | Plafond (ex. 8 h) et pourcentage des gains normaux ? | Phase 6 |
| 7 | Récompenses quotidiennes / arbre | Contenu : argent, vitesse, œufs, lucky blocks ? | Phase 6 |
| 8 | Fusion | Combien de balles pour fusionner, et rareté supérieure garantie ou au hasard ? | Phase 7 |
| 9 | Boss | On les garde tels quels, ou ils donnent un œuf jackpot ? | Phase 7 |
| 10 | Battes de baseball | ⚠️ Ajoute une **arme** : il faudra **refaire le questionnaire de maturité**, avec un risque de restreindre le public. On le fait ? | Phase 7 |

---

## Ce qu'on ne casse pas

| À protéger | Pourquoi |
|---|---|
| DataStore `FindTheBall_LuckyBlocks_v1` | Lucky blocks achetés et pas encore ouverts |
| Les IDs des Developer Products | Déjà vendus, déjà en ligne |
| Un seul `ProcessReceipt` (`GestionAchatsRobux`) | Règle Roblox : sinon les paiements se perdent |
| Chances des lucky blocks affichées + `PolicyService` | Règle Roblox sur les objets aléatoires payants |
| Objets `Origine = "LuckyBlock"` non donnables | Règle Roblox : pas d'échange d'objets payants |
