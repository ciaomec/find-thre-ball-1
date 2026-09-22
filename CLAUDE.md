# Find the Ball — règles de travail

Jeu Roblox (Luau) de Laurence (compte `zouzou_lpb8`).
Expérience `10766552916` · lieu de départ `116829569599129`.

## Langue

Tout est en **français** : noms de scripts, variables, commentaires, textes du jeu,
et les réponses faites à Laurence.

## Comment parler à Laurence

- Elle est **débutante en programmation**. Expliquer simplement, avec des
  **analogies concrètes** et des **tableaux récapitulatifs**.
- Toujours préciser : **quel fichier**, **où il se trouve dans Studio**, et
  **ce qu'elle doit voir en testant**.
- **Ne jamais publier sans son accord explicite.**
- Lui rappeler `File > Download a Copy` avant chaque séance de travail.

## Organisation du dépôt

| Dossier | Correspond à, dans Roblox Studio |
|---|---|
| `src/ReplicatedStorage/` | ReplicatedStorage (ModuleScripts) |
| `src/ServerScriptService/` | ServerScriptService (Scripts et Modules) |
| `src/ServerStorage/` | ServerStorage |
| `src/StarterPlayerScripts/` | StarterPlayer > StarterPlayerScripts (LocalScripts) |
| `docs/` | Documentation : passation, appairage, décisions |

Le dépôt est la **source de vérité** du code. Studio en est le reflet.

## Pièges connus (lire avant de coder)

| Piège | À savoir |
|---|---|
| Collages coupés | Cause n°1 des bugs en v1 (`Expected 'end'`, `<eof>`). Préférer l'écriture via MCP plutôt que le copier-coller manuel. |
| Fichier local | Un `.rbxl` ouvert depuis le Mac n'accède pas aux DataStores. Toujours ouvrir la version **en ligne**. |
| Hauteur du sol | Toujours `workspace:GetAttribute("HauteurSol")` (mesurée après création du Terrain). |
| Ordre de chargement | Créer les RemoteEvents / RemoteFunctions **en premier** dans les scripts serveur, avant les `require` (sinon « Infinite yield » côté LocalScript). |
| GenerateurCarte | Doit rester dans **ServerStorage**, pas ServerScriptService. |
| ProcessReceipt | **Un seul** dans tout le jeu : `GestionAchatsRobux`. Tout nouvel achat Robux passe par lui. |
| Valeurs de test | Toujours les remettre à la normale avant publication (intervalle des boss, événements forcés, durées raccourcies). |
| StreamingEnabled | Reste décoché dans Workspace. |

## Méthode v2

Les nouveaux scripts remplacent les anciens ; les anciens sont **désactivés**
(case `Enabled` décochée) plutôt que supprimés, pour pouvoir revenir en arrière.

Ne pas casser ce qui a été payé : garder le DataStore `FindTheBall_LuckyBlocks_v1`,
et prévoir une reprise des améliorations Robux avant de basculer sur `FindTheBall_v2`.

## Avant de dire « c'est fait »

1. Le script `Diagnostic` affiche des ✅ au démarrage.
2. L'Output ne montre aucune erreur rouge.
3. Testé avec **Play**, et avec **Local Server à 2 joueurs** pour tout ce qui est multijoueur.
