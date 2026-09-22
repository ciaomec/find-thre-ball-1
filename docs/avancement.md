# Avancement et décisions à prendre

## Où on en est

| Phase | État | Détail |
|---|---|---|
| 0 — Mise en place | **en cours** | Dépôt créé, `ConfigJeu` écrit. Reste : appairer Claude et Studio sur le Mac. |
| 1 — Œufs et éclosion | prête | Éclosion tranchée (auto, 15 s → 6 h). Démarre dès que Studio est appairé. |

### Fait

- Dépôt Git créé avec la structure `src/` qui reflète Studio.
- `docs/passation.md` : toute la vision v2, conservée telle quelle.
- `docs/appairage-roblox-studio.md` : la marche à suivre pour relier Claude à Studio.
- `CLAUDE.md` : les règles de travail (langue, ton, pièges connus).
- `src/ReplicatedStorage/ConfigJeu.lua` : le module de réglages v2, **pas encore posé dans Studio**.
- Éclosion automatique et durées exponentielles (15 s → 6 h) codées dans `ConfigJeu.Eclosion`.

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

## Décisions prises

### 1. L'éclosion est automatique ✅

L'œuf posé sur un socle démarre son compte à rebours **tout seul**. Rien à presser.
Un socle occupé par un œuf en cours ne rapporte rien et affiche le temps restant.

`ConfigJeu.Eclosion.Automatique = true`

### 2. Les temps d'éclosion sont exponentiels, jusqu'à 6 h ✅

Le temps n'est plus écrit œuf par œuf : il est **calculé**, à partir de deux
multiplications qui se cumulent.

| Réglage | Valeur | Effet |
|---|---|---|
| `TempsDepart` | 15 s | Le tout premier œuf du jeu (Ping-pong Blanche) |
| `FacteurZone` | ×1,724 | Chaque zone plus lointaine multiplie l'attente |
| `FacteurRang` | ×1,95 | Chaque œuf plus rare de la zone la multiplie encore |
| `TempsMax` | 6 h | Plafond absolu, jamais dépassé |

> L'image : chaque pas vers l'extérieur de la carte, et chaque cran de rareté,
> **doublent à peu près** l'attente. Comme un pli de feuille de papier — deux plis
> ne font rien, vingt plis atteignent la Lune.

Résultat, du premier œuf au dernier :

| Zone | Temps d'éclosion, du plus commun au plus rare |
|---|---|
| 1 Ping-pong | Blanche 15s · Orange 29s · Picot 57s · Néon 1m51 · Étoilée 3m37 · Champion 7m03 |
| 2 Golf | à Fossettes 26s · Gazon 50s · Bunker 1m38 · Drapeau 3m12 · Birdie 6m14 · Trou en un 12m09 |
| 3 Tennis | Feutrée 45s · Terre battue 1m27 · Gazon anglais 2m50 · Fluo 5m31 · Tie-break 10m45 · Grand Chelem 20m57 |
| 4 Baseball | à Coutures 1m17 · Poussière 2m30 · Gant 4m52 · Batte 9m30 · Curveball 18m31 · Home Run 36m07 |
| 5 Rugby | de Cuir 2m13 · Boueuse 4m18 · Maillot 8m24 · Mêlée 16m23 · Drop 31m56 · Essai 1h02 · Chelem d'Or 2h01 |
| 6 Basket | Parquet 3m48 · Filet 7m25 · Street 14m29 · Alley-oop 28m14 · Dunk 55m03 · Buzzer 1h47 · Panier d'Or 3h29 |
| 7 Football | Hexagone 6m34 · Nocturne 12m48 · Stade 24m58 · Lucarne 48m40 · Penalty 1h34 · Coupe 3h05 · **Ballon d'Or 6h00** |

**Pour régler après les tests :** une seule ligne à changer dans `ConfigJeu.Eclosion`.
Baisser `FacteurRang` raccourcit surtout les œufs rares ; baisser `FacteurZone`
raccourcit surtout les zones lointaines. Et pour forcer un œuf précis :
`ConfigJeu.Eclosion.Perso["FO_BallonOr"] = 18000`.

**Point de vigilance :** avec 6 h d'attente et **un seul œuf porté à la fois**,
le nombre de socles devient la vraie limite du joueur. Il faudra vérifier en phase 1
qu'un joueur de zone 7 a assez de socles pour ne pas rester les bras ballants,
et la phase 6 (gains hors ligne) prend d'autant plus d'importance.

---

## Décisions en attente de Laurence

Rangées par urgence : les premières bloquent la phase 1.

| # | Sujet | Question | Bloque |
|---|---|---|---|
| 1 | Améliorations Robux v1 | Comment compenser les joueurs qui ont payé, au passage sur `FindTheBall_v2` ? | Phase 1 |
| 2 | Game Pass Double portage | À créer sur le Creator Hub (Monétisation > Passes), puis mettre l'ID dans `ConfigJeu.PassDoublePortage.Id` | Phase 1 |
| 3 | Nombre de socles | Combien de socles au départ, et jusqu'où l'amélioration peut monter ? (devient important avec les éclosions de 6 h) | Phase 1 |
| 4 | Événements | Les mutations disparaissent : on les remplace par quoi (ex. « pluie d'œufs rares ») ? | Phase 5 |
| 5 | Gains hors ligne | Plafond (ex. 8 h) et pourcentage des gains normaux ? | Phase 6 |
| 6 | Récompenses quotidiennes / arbre | Contenu : argent, vitesse, œufs, lucky blocks ? | Phase 6 |
| 7 | Fusion | Combien de balles pour fusionner, et rareté supérieure garantie ou au hasard ? | Phase 7 |
| 8 | Boss | On les garde tels quels, ou ils donnent un œuf jackpot ? | Phase 7 |
| 9 | Battes de baseball | ⚠️ Ajoute une **arme** : il faudra **refaire le questionnaire de maturité**, avec un risque de restreindre le public. On le fait ? | Phase 7 |

---

## Ce qu'on ne casse pas

| À protéger | Pourquoi |
|---|---|
| DataStore `FindTheBall_LuckyBlocks_v1` | Lucky blocks achetés et pas encore ouverts |
| Les IDs des Developer Products | Déjà vendus, déjà en ligne |
| Un seul `ProcessReceipt` (`GestionAchatsRobux`) | Règle Roblox : sinon les paiements se perdent |
| Chances des lucky blocks affichées + `PolicyService` | Règle Roblox sur les objets aléatoires payants |
| Objets `Origine = "LuckyBlock"` non donnables | Règle Roblox : pas d'échange d'objets payants |
