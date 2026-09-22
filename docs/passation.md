# Passation — Find the Ball (Roblox)

Document de reprise du projet pour Claude Code. Il résume l'état actuel du jeu (v1, publiée), la vision de la v2 validée avec la créatrice, les décisions prises, les points encore ouverts et les règles de travail.

---

## 1. Contexte

| Élément | Valeur |
|---|---|
| Nom du jeu | Find the Ball |
| Créatrice | Laurence (compte Roblox : zouzou_lpb8), débutante en programmation, travaille sur Mac |
| Outil | Roblox Studio (langage Luau) |
| ID de l'expérience | 10766552916 |
| ID du lieu de départ | 116829569599129 |
| Statut | **Publié en public**, questionnaire de maturité rempli (classification « Léger »), vérification d'âge faite |
| Joueurs par serveur | 6 (une base par joueur) |
| Langue du jeu | Français (noms de scripts, variables, commentaires et textes en français) |

### Façon de travailler avec Laurence

- Elle est débutante : expliquer simplement, avec des **analogies concrètes** et des **tableaux récapitulatifs**.
- Toujours dire **quel fichier**, **où il se trouve** et **ce qu'elle doit voir en testant**.
- Elle veut garder la main sur la publication : **ne jamais publier sans son accord**.
- Avant chaque séance : `File > Download a Copy` (copie de secours).
- Tester avec **Play** (et **Local Server** à 2 joueurs pour tout ce qui est multijoueur) avant toute publication.
- Le script `Diagnostic` affiche au démarrage des ✅/❌ pour les modules principaux : c'est le premier contrôle à faire.

---

## 2. Le but du jeu

Jeu de collection et de progression à 6 joueurs. Chaque joueur a une base au centre de la carte. Autour, 7 zones de sports en anneaux, de plus en plus lointaines et difficiles. On y ramasse des objets, on les ramène à sa base, et ils rapportent de l'argent en continu.

**Problème constaté par Laurence et ses amis après plusieurs heures de jeu :** le jeu se termine trop vite et lasse rapidement, car il n'y a pas de vrai objectif à part l'index. La v2 doit **allonger fortement la durée de vie**.

**Boucle de la v2 :** explorer → ramasser un œuf → le ramener et le poser sur un socle → attendre l'éclosion → découvrir la rareté de la balle → gagner argent et vitesse → aller plus loin.

---

## 3. La v1 actuelle (en ligne)

### 3.1 Fichiers

**ReplicatedStorage (ModuleScripts)**

| Fichier | Rôle |
|---|---|
| ConfigBalles | Réglages centraux v1 : zones, matériaux (raretés v1), effets (mutations), XP, boutique, carte, `HauteurSolZone()` |
| ConfigThemes | 7 thèmes de base débloqués par l'index (bonus de revenus) |
| ConfigLuckyBlocks | Lucky blocks : délai gratuit 6 h, produits Robux, récompenses, objets spéciaux |
| ConfigAmeliorationsRobux | Paliers de prix Robux des améliorations du magasin (`Paliers`, `Palier()`) |
| ConfigJeu | **v2 — à créer** (code complet en annexe) |

**ServerStorage**

| Fichier | Rôle |
|---|---|
| GenerateurCarte | Construit la carte avec le Terrain Roblox, mesure la hauteur réelle du sol (attribut `workspace:GetAttribute("HauteurSol")`), place bases, socles, décors, bordure |

**ServerScriptService**

| Fichier | Type | Rôle |
|---|---|---|
| ConstructionCarte | Script | Lance GenerateurCarte au démarrage |
| DonneesJoueurs | Module | Carnet du joueur (argent, niveau, XP, améliorations, balles stockées, sac, quêtes, index, thème). DataStore `FindTheBall_v1` |
| Bases | Module | Balles visuelles, socles, bouton E pour ranger dans le sac |
| Gardes | Module | Patrouille, poursuite, sprint, plaquage + projection |
| EffetsBalles | Module | Animations des mutations (Slime, Roulante, Cachée, Congelée) |
| Projection | Module | Projette un joueur (RemoteEvent `Projection`) |
| Quetes | Module | 20 quêtes principales + 3 quêtes horaires |
| GestionBalles | Script | Apparition des balles, ramassage, pile sur la tête, dépôt, revenus/s, durée de vie des balles au sol (150–180 s, disparitions étalées) |
| GestionBoss | Script | Boss toutes les 480 s, mutations, mini-jeu de timing, projection en cas d'échec. Attributs `Prochain`, `Nom`, `Fin` sur le dossier `workspace.Boss` |
| GestionBoutique | Script | Améliorations en argent (RemoteFunction `AcheterAmelioration`) |
| GestionJoueurs | Script | Arrivée/départ, attribution des bases, sauvegarde auto toutes les 2 min + BindToClose |
| GestionSac | Script | Sac à dos, actions Placer/Équiper/Jeter, construit la poubelle |
| GestionIndex | Script | Index (paliers 33/66/100 %), récompenses, thèmes (RemoteFunction `ChoisirTheme`) |
| GestionEvenements | Script | Événements de mutation (30 min / 5 min), dossier `ReplicatedStorage.Evenement` |
| GestionLuckyBlocks | Script | Lucky blocks : gratuit, ouverture animée, récompenses. Reçoit les paiements via la BindableFunction `ServerStorage.RecuLuckyBlock`. DataStore `FindTheBall_LuckyBlocks_v1` |
| GestionAchatsRobux | Script | **Guichet central unique** : seul script qui définit `MarketplaceService.ProcessReceipt`. Transmet les lucky blocks à GestionLuckyBlocks, gère les améliorations Robux. DataStore `FindTheBall_AchatsAmeliorations_v1` |
| GestionDons | Script | Dons de balles entre joueurs (proposition/acceptation, 15 studs, niveau requis, objets de lucky blocks non donnables) |
| Magasin | Script | Bâtiment du magasin (prompt `OuvrirBoutique`) |
| TableauQuetes | Script | Tableau physique des quêtes |
| Classements | Script | 5 classements mondiaux. DataStore `FindTheBall_Stats_v1` |
| ThemesBase | Script | Applique le thème choisi sur la base |
| PanneauTimers | Script | Arche au centre de la place : comptes à rebours du prochain événement et du prochain boss |
| Diagnostic | Script | Vérifie 9 modules au démarrage |

**StarterPlayer > StarterPlayerScripts (LocalScripts)**

Interface, Boutique, Quetes, Sac, Silhouettes, Surbrillance (**désactivé**, jugé inutile), Vente, Index, AffichageTableau, Evenements, ApparenceBalles, MiniJeuBoss, ProjectionJoueur, LuckyBlocks, DispositionEcran (réorganise les boutons en colonne à gauche, adapte les fenêtres aux petits écrans), Dons.

### 3.2 Monétisation en place

| Produit | Type | ID |
|---|---|---|
| 1 lucky block | Developer Product | 3713266286 |
| 3 lucky blocks | Developer Product | 3713266352 |
| 10 lucky blocks | Developer Product | 3713266430 |
| 25 lucky blocks (599 R$) | Developer Product | 3713266644 |
| Améliorations du magasin (Vitesse, Socles, Multiplicateur, Capacité) | Developer Products, 3 paliers chacun | IDs dans `ConfigAmeliorationsRobux` (à vérifier dans le fichier) |

### 3.3 Règles Roblox déjà respectées (à conserver en v2)

- Lucky blocks = **objets aléatoires payants** : chances affichées avant achat, `PolicyService` (`ArePaidRandomItemsRestricted`) vérifié, achat bloqué côté serveur pour les comptes concernés.
- Les objets issus des lucky blocks portent `Origine = "LuckyBlock"` et **ne peuvent pas être donnés** (pas d'échange d'objets payants).
- Un seul `ProcessReceipt` dans tout le jeu (GestionAchatsRobux). Tout nouvel achat Robux doit passer par lui.
- Achats idempotents (PurchaseId enregistré).

---

## 4. La v2 — vision validée

### 4.1 Décisions prises

| Décision | Détail |
|---|---|
| On **garde le même jeu** | Pas de nouveau jeu : on conserve l'ID, la portée de publication, les produits Robux, la page |
| **Sauvegardes repartent de zéro** | Nouvelle clé de DataStore `FindTheBall_v2` pour le carnet principal |
| Travail **directement dans le jeu** | Pas de lieu de test ; ne publier qu'une fois une phase testée |
| **Carte en grand cercle** | On garde les 7 anneaux complets, mais les zones deviennent **plus profondes** pour que la course reste longue malgré les grandes vitesses |
| **Nouveau spawn coloré** | L'ancienne place est trop grise |

⚠️ **Attention au passage en v2** : ne pas effacer ce que des joueurs ont payé.
- Garder `FindTheBall_LuckyBlocks_v1` (lucky blocks achetés non ouverts).
- Les améliorations achetées en Robux étaient stockées dans le carnet `FindTheBall_v1` : prévoir une compensation ou une reprise pour les joueurs concernés avant la bascule.

### 4.2 Fonctionnalités v1 conservées

Carte à 7 zones de sports avec décors, bases à socles, revenus par seconde, multiplicateur de base, magasin physique, poubelle, sac à dos, bouton « Équiper les meilleures », gardes, boss avec mini-jeux, quêtes principales et horaires, index avec thèmes de base, classements mondiaux, lucky blocks (gratuit + Robux), achats Robux via guichet central, dons entre joueurs, tableau des quêtes, arche des comptes à rebours, interface adaptée mobile.

### 4.3 Nouveautés et changements de la v2

| # | Nouveauté | Détail |
|---|---|---|
| 1 | Fin des raretés v1 | Plus de matériaux (bronze, argent, or…) ni de mutations (Slime, Roulante, Cachée, Congelée) |
| 2 | **Œufs propres à chaque zone** | 6 ou 7 œufs par zone, **43 au total**, chacun avec son thème, son nom, sa couleur, sa taille, son temps d'éclosion et ses chances |
| 3 | **Deux objets distincts** | L'**œuf** (sur la carte) se ramasse et éclôt ; la **balle** (éclose, sur les socles) rapporte de l'argent. Un socle avec un œuf en cours ne rapporte rien et affiche un compte à rebours |
| 4 | 7 raretés | Commun, Rare, Épique, Légendaire, Divin, Arc-en-ciel, Secret |
| 5 | Œufs jackpot | Panier d'Or (basket) et Ballon d'Or (football) garantissent Arc-en-ciel ou Secret |
| 6 | Zones qui se chevauchent | Une balle commune de football vaut à peu près une balle épique/légendaire de basket |
| 7 | Gros chiffres | Économie à grande échelle (jusqu'aux milliers de milliards de $/s), avec de **vrais** chiffres, pas d'affichage gonflé |
| 8 | **L'XP disparaît** | Remplacée par des **points de vitesse** gagnés aux éclosions, aux quêtes et à l'index |
| 9 | Plus de blocage par niveau | On peut aller partout ; ce sont les **gardes** qui empêchent de ressortir sans assez de vitesse |
| 10 | Magasin | L'achat de vitesse est remplacé par un **multiplicateur de vitesse** (+5 % par achat, sans limite, prix croissant). La ligne Capacité disparaît |
| 11 | Vitesses très élevées | Joueurs et gardes beaucoup plus rapides (garde de football : 280). Attention aux traversées de murs à grande vitesse |
| 12 | Transport | **1 œuf à la fois**. Game Pass **Double portage** (199 R$ conseillé) pour en porter 2 — pass à créer |
| 13 | Rotation des œufs | Toutes les **5 min**, une **barrière blanche** entoure le spawn, les joueurs y sont contraints **20 s**, pendant ce temps tous les œufs sont renouvelés dans leur zone |
| 14 | Beaucoup plus d'œufs sur la carte | Tailles variées pour l'impression de diversité |
| 15 | Bases | Agrandies et beaucoup plus belles |
| 16 | Gardes | Plus beaux, meilleurs comportements, patrouillent dans toute leur zone |
| 17 | Sons de pas | Différents selon la zone |
| 18 | Téléportations depuis le spawn | Boutons « Magasin » et « Ma base » |
| 19 | Lucky blocks physiques au spawn | Vitrine pour pousser les achats |
| 20 | Interface | Supprimer le bandeau d'événement au centre de l'écran ; afficher le multiplicateur de base |
| 21 | Tutoriel | Expliquer la boucle aux nouveaux joueurs |
| 22 | Gains hors ligne | Argent gagné même déconnecté |
| 23 | Récompenses quotidiennes | À chaque jour de connexion |
| 24 | Arbre de récompenses | Une récompense toutes les 5 min de jeu |
| 25 | Machine à fusion | Fusionner des balles pour en obtenir de meilleures (utilité des doublons) |
| 26 | Battes de baseball | Se taper entre joueurs pour se disputer les œufs |
| 27 | Nouveau spawn | Coloré et joyeux : damier coloré, grand cercle doré, rayons vers chaque zone, guirlandes, ballons, confettis, fontaine, grandes flèches au sol vers les zones, bâtiments habillés comme un village de fête, panneau de bienvenue |

### 4.4 Système de vitesse

`Vitesse = (16 + points de vitesse) × (1 + 0,05 × niveau du multiplicateur du magasin)`, × 0,85 en portant un œuf, plafond 500.

| Source | Gain de points de vitesse |
|---|---|
| Éclosion d'un œuf | 0,15 × numéro de la zone |
| Quête horaire | 1 |
| Quête principale | 2 (ajustable par quête) |
| Page d'index complétée | 4 |
| Index complet | 30 |

| Zone | Vitesse du garde | Vitesse visée pour s'en sortir |
|---|---|---|
| 1 Ping-pong | aucun garde | 16 |
| 2 Golf | 26 | ~30 |
| 3 Tennis | 42 | ~48 |
| 4 Baseball | 68 | ~78 |
| 5 Rugby | 110 | ~125 |
| 6 Basket | 175 | ~200 |
| 7 Football | 280 | ~320 |

### 4.5 Les 43 œufs

| Zone | Œufs (du plus commun au plus rare) |
|---|---|
| 1 Ping-pong | Blanche, Orange, Picot, Néon, Étoilée, Champion |
| 2 Golf | à Fossettes, Gazon, Bunker, Drapeau, Birdie, Trou en un |
| 3 Tennis | Feutrée, Terre battue, Gazon anglais, Fluo, Tie-break, Grand Chelem |
| 4 Baseball | à Coutures, Poussière, Gant, Batte, Curveball, Home Run |
| 5 Rugby | de Cuir, Boueuse, Maillot, Mêlée, Drop, Essai, Chelem d'Or |
| 6 Basket | Parquet, Filet, Street, Alley-oop, Dunk, Buzzer, Panier d'Or (jackpot) |
| 7 Football | Hexagone, Nocturne, Stade, Lucarne, Penalty, Coupe, Ballon d'Or (jackpot) |

Index v2 : 43 œufs × 7 raretés = **301 balles** à collectionner.

| Rareté | Multiplicateur de valeur |
|---|---|
| Commun | ×1 |
| Rare | ×4 |
| Épique | ×15 |
| Légendaire | ×60 |
| Divin | ×250 |
| Arc-en-ciel | ×1200 |
| Secret | ×6000 |

Valeur d'une balle = valeur de base de la zone × bonus de l'œuf × multiplicateur de rareté. Tout est dans `ConfigJeu` (annexe).

---

## 5. Points encore à décider

| Sujet | Question |
|---|---|
| Éclosion | Démarre automatiquement quand l'œuf est posé, ou il faut appuyer sur E ? |
| Game Pass Double portage | À créer sur le Creator Hub (Monétisation > Passes) puis mettre l'ID dans `ConfigJeu.PassDoublePortage.Id` |
| Temps d'éclosion | Garder les longues attentes (Ballon d'Or 45 min) ou raccourcir ? |
| Fusion | Combien de balles, quel résultat (rareté supérieure garantie ou chance) ? |
| Récompenses quotidiennes / arbre | Contenu : argent, vitesse, œufs, lucky blocks ? |
| Gains hors ligne | Plafond (ex. 8 h) et pourcentage des gains normaux |
| Événements | Les mutations disparaissent : les remplacer par quoi (ex. « pluie d'œufs rares ») ? |
| Boss | Garder tel quel ou leur faire donner un œuf jackpot ? |
| Battes de baseball | Ajoute une arme et du combat entre joueurs : **refaire le questionnaire de maturité**, risque de restreindre le public |
| Améliorations Robux déjà achetées | Comment les compenser lors du passage à `FindTheBall_v2` |

---

## 6. Feuille de route v2

| Phase | Contenu |
|---|---|
| 1 | Œufs et éclosion : `ConfigJeu`, nouveau carnet `FindTheBall_v2`, apparition des œufs par zone, ramassage (1 œuf, 2 avec pass), pose sur socle, compte à rebours, éclosion animée avec révélation de rareté, apparence des œufs et balles |
| 2 | Vitesse et progression : suppression de l'XP et des niveaux requis, points de vitesse, multiplicateur de vitesse au magasin, gardes calés sur les vitesses de zone |
| 3 | Carte : grand cercle avec zones plus profondes, beaucoup plus d'œufs, nouveau spawn coloré, bases agrandies et embellies, bordures renforcées pour les grandes vitesses |
| 4 | Rotation : barrière blanche toutes les 5 min, 20 s au spawn, renouvellement de tous les œufs |
| 5 | Confort : téléportations, suppression du bandeau central, multiplicateur de base affiché, sons de pas par zone |
| 6 | Rétention : gains hors ligne, récompenses quotidiennes, arbre de récompenses |
| 7 | Contenu : machine à fusion, lucky blocks physiques, battes de baseball |
| 8 | Finitions : tutoriel, gardes plus beaux, adaptation de l'index (301 balles), des quêtes, des lucky blocks (récompenses en œufs) et des classements à la v2 |

Méthode prévue : les nouveaux scripts remplacent les anciens ; les anciens sont **désactivés** (Enabled décoché) plutôt que supprimés, pour pouvoir revenir en arrière.

---

## 7. Pièges connus

| Piège | À savoir |
|---|---|
| Collages coupés | Cause n°1 des bugs pendant la v1 (erreurs `Expected 'end'`, `<eof>`) |
| Fichier local | Un `.rbxl` ouvert depuis le Mac n'accède pas aux DataStores (« You must publish this place to the web ») : toujours ouvrir la version en ligne, ou publier avec `Publish to Roblox As` en choisissant Find the Ball |
| Studio non connecté | Erreurs « Failed to fetch place info » / « User is not authenticated » : se déconnecter/reconnecter dans Studio |
| Hauteur du sol | Toujours utiliser `workspace:GetAttribute("HauteurSol")` (mesurée après la création du Terrain) |
| Ordre de chargement | Créer les RemoteEvents/RemoteFunctions **en premier** dans les scripts serveur, avant les `require`, pour ne pas bloquer les LocalScripts (« Infinite yield ») |
| GenerateurCarte | Doit rester dans ServerStorage (pas ServerScriptService) |
| ProcessReceipt | Un seul endroit : GestionAchatsRobux |
| Valeurs de test | Toujours les remettre avant de publier (intervalle des boss, événement forcé, récompense forcée, durées raccourcies…) |
| StreamingEnabled | Décoché dans Workspace |

---

## 8. Annexe — `ConfigJeu` (ModuleScript dans ReplicatedStorage)

Version validée avec Laurence. Pas encore créée dans Studio.

```lua
-- Réglages de la version 2 de Find the Ball
-- Vocabulaire : un ŒUF se ramasse et éclôt ; une BALLE (éclose) rapporte de l'argent
-- Chaque zone a ses propres œufs, aux couleurs de son sport
local ConfigJeu = {}

---------------------------------------------------------------
-- VITESSE (remplace complètement l'XP)
---------------------------------------------------------------
ConfigJeu.VitesseDepart = 16
ConfigJeu.VitesseMax = 500
ConfigJeu.CoefOeufPorte = 0.85

ConfigJeu.GainsVitesse = {
	Eclosion = 0.15,             -- x numéro de la zone, à chaque éclosion
	QueteHoraire = 1,
	QuetePrincipale = 2,
	PageIndex = 4,
	IndexComplet = 30,
}

ConfigJeu.MultiplicateurVitesse = {
	Gain = 0.05,                 -- +5 % par achat, sans limite
	PrixDepart = 750,
	Croissance = 1.5,
}

function ConfigJeu.PrixMultiplicateurVitesse(niveau)
	local m = ConfigJeu.MultiplicateurVitesse
	return math.round(m.PrixDepart * m.Croissance ^ niveau)
end

function ConfigJeu.Vitesse(pointsVitesse, niveauMultiplicateur, porteDesOeufs)
	local m = ConfigJeu.MultiplicateurVitesse
	local vitesse = (ConfigJeu.VitesseDepart + (pointsVitesse or 0)) * (1 + (niveauMultiplicateur or 0) * m.Gain)
	if porteDesOeufs then
		vitesse *= ConfigJeu.CoefOeufPorte
	end
	return math.clamp(vitesse, 8, ConfigJeu.VitesseMax)
end

---------------------------------------------------------------
-- TRANSPORT DES ŒUFS (1 par défaut, 2 avec le Game Pass)
-- Remplace 0 par l'ID du pass créé sur le Creator Hub
---------------------------------------------------------------
ConfigJeu.CapaciteDepart = 1
ConfigJeu.PassDoublePortage = { Id = 0, Capacite = 2, Nom = "Double portage" }

function ConfigJeu.Capacite(aLePass)
	return aLePass and ConfigJeu.PassDoublePortage.Capacite or ConfigJeu.CapaciteDepart
end

---------------------------------------------------------------
-- RARETÉS (ce qui sort de l'œuf et rapporte l'argent)
---------------------------------------------------------------
ConfigJeu.Raretes = {
	{ Id = "Commun",     Nom = "Commun",      Multiplicateur = 1,    Couleur = Color3.fromRGB(190, 190, 200) },
	{ Id = "Rare",       Nom = "Rare",        Multiplicateur = 4,    Couleur = Color3.fromRGB(70, 150, 255) },
	{ Id = "Epique",     Nom = "Épique",      Multiplicateur = 15,   Couleur = Color3.fromRGB(170, 90, 255) },
	{ Id = "Legendaire", Nom = "Légendaire",  Multiplicateur = 60,   Couleur = Color3.fromRGB(255, 160, 40) },
	{ Id = "Divin",      Nom = "Divin",       Multiplicateur = 250,  Couleur = Color3.fromRGB(255, 255, 215) },
	{ Id = "ArcEnCiel",  Nom = "Arc-en-ciel", Multiplicateur = 1200, Couleur = Color3.fromRGB(255, 110, 200) },
	{ Id = "Secret",     Nom = "Secret",      Multiplicateur = 6000, Couleur = Color3.fromRGB(45, 20, 35) },
}

ConfigJeu.RareteParId = {}
for _, r in ipairs(ConfigJeu.Raretes) do
	ConfigJeu.RareteParId[r.Id] = r
end

---------------------------------------------------------------
-- PALIERS DE CHANCES (T1 = œuf banal, T7 = œuf très rare)
---------------------------------------------------------------
local PALIERS = {
	T1 = { Commun = 72, Rare = 22, Epique = 5, Legendaire = 0.9, Divin = 0.1 },
	T2 = { Commun = 58, Rare = 28, Epique = 11, Legendaire = 2.5, Divin = 0.5 },
	T3 = { Commun = 45, Rare = 32, Epique = 17, Legendaire = 5, Divin = 1 },
	T4 = { Commun = 30, Rare = 32, Epique = 24, Legendaire = 11, Divin = 2.8, ArcEnCiel = 0.2 },
	T5 = { Commun = 16, Rare = 28, Epique = 30, Legendaire = 18, Divin = 7, ArcEnCiel = 0.9, Secret = 0.1 },
	T6 = { Commun = 5, Rare = 17, Epique = 30, Legendaire = 28, Divin = 16, ArcEnCiel = 3.5, Secret = 0.5 },
	T7 = { Commun = 1, Rare = 7, Epique = 23, Legendaire = 32, Divin = 27, ArcEnCiel = 8.5, Secret = 1.5 },
	JACKPOT1 = { ArcEnCiel = 85, Secret = 15 },
	JACKPOT2 = { ArcEnCiel = 40, Secret = 60 },
}

-- oeuf(identifiant, nom affiché, fréquence, secondes d'éclosion, multiplicateur de valeur, palier, couleur)
local function oeuf(id, nom, poids, temps, bonus, palier, couleur)
	return { Id = id, Nom = nom, Poids = poids, TempsEclosion = temps, Bonus = bonus,
	         Chances = PALIERS[palier], Couleur = couleur }
end

---------------------------------------------------------------
-- ZONES ET LEURS ŒUFS
---------------------------------------------------------------
ConfigJeu.Zones = {
	{ Numero = 1, Sport = "Ping-pong", ValeurBase = 25, Taille = 1.0, VitesseGarde = 0, NbGardes = 0,
	  Couleur = Color3.fromRGB(250, 250, 250), Couleur2 = Color3.fromRGB(235, 120, 40),
	  Oeufs = {
		oeuf("PP_Blanche",  "Blanche",   40, 15,  1,   "T1", Color3.fromRGB(250, 250, 250)),
		oeuf("PP_Orange",   "Orange",    26, 30,  1.6, "T2", Color3.fromRGB(240, 130, 40)),
		oeuf("PP_Picot",    "Picot",     18, 60,  2.4, "T3", Color3.fromRGB(120, 200, 235)),
		oeuf("PP_Neon",     "Néon",      10, 120, 3.6, "T4", Color3.fromRGB(80, 255, 230)),
		oeuf("PP_Etoilee",  "Étoilée",   5,  240, 6,   "T5", Color3.fromRGB(255, 225, 90)),
		oeuf("PP_Champion", "Champion",  1,  600, 14,  "T6", Color3.fromRGB(255, 200, 40)),
	} },

	{ Numero = 2, Sport = "Golf", ValeurBase = 200, Taille = 1.2, VitesseGarde = 26, NbGardes = 2,
	  Couleur = Color3.fromRGB(240, 240, 235), Couleur2 = Color3.fromRGB(110, 190, 90),
	  Oeufs = {
		oeuf("GO_Fossettes", "à Fossettes", 38, 20,  1,   "T1", Color3.fromRGB(245, 245, 240)),
		oeuf("GO_Gazon",     "Gazon",       25, 45,  1.7, "T2", Color3.fromRGB(120, 200, 95)),
		oeuf("GO_Bunker",    "Bunker",      18, 90,  2.6, "T3", Color3.fromRGB(235, 215, 155)),
		oeuf("GO_Drapeau",   "Drapeau",     11, 180, 4,   "T4", Color3.fromRGB(230, 60, 60)),
		oeuf("GO_Birdie",    "Birdie",      6,  330, 6.5, "T5", Color3.fromRGB(90, 180, 255)),
		oeuf("GO_TrouEnUn",  "Trou en un",  2,  780, 15,  "T6", Color3.fromRGB(255, 200, 40)),
	} },

	{ Numero = 3, Sport = "Tennis", ValeurBase = 1600, Taille = 1.6, VitesseGarde = 42, NbGardes = 3,
	  Couleur = Color3.fromRGB(215, 240, 60), Couleur2 = Color3.fromRGB(250, 250, 250),
	  Oeufs = {
		oeuf("TE_Feutree",     "Feutrée",       34, 25,  1,   "T1", Color3.fromRGB(215, 240, 60)),
		oeuf("TE_Terre",       "Terre battue",  24, 50,  1.8, "T2", Color3.fromRGB(200, 105, 60)),
		oeuf("TE_Gazon",       "Gazon anglais", 18, 110, 2.8, "T3", Color3.fromRGB(95, 175, 90)),
		oeuf("TE_Fluo",        "Fluo",          13, 210, 4.2, "T4", Color3.fromRGB(180, 255, 70)),
		oeuf("TE_TieBreak",    "Tie-break",     8,  400, 7,   "T5", Color3.fromRGB(90, 130, 255)),
		oeuf("TE_GrandChelem", "Grand Chelem",  3,  900, 16,  "T6", Color3.fromRGB(255, 205, 60)),
	} },

	{ Numero = 4, Sport = "Baseball", ValeurBase = 13000, Taille = 1.8, VitesseGarde = 68, NbGardes = 3,
	  Couleur = Color3.fromRGB(245, 240, 225), Couleur2 = Color3.fromRGB(210, 50, 50),
	  Oeufs = {
		oeuf("BA_Couture",   "à Coutures", 32, 30,  1,   "T2", Color3.fromRGB(245, 240, 225)),
		oeuf("BA_Poussiere", "Poussière",  23, 65,  1.8, "T3", Color3.fromRGB(190, 150, 110)),
		oeuf("BA_Gant",      "Gant",       18, 130, 2.9, "T4", Color3.fromRGB(150, 95, 50)),
		oeuf("BA_Batte",     "Batte",      13, 260, 4.5, "T4", Color3.fromRGB(215, 175, 110)),
		oeuf("BA_Curveball", "Curveball",  9,  480, 7.5, "T5", Color3.fromRGB(120, 190, 255)),
		oeuf("BA_HomeRun",   "Home Run",   5,  1020, 17, "T6", Color3.fromRGB(255, 120, 60)),
	} },

	{ Numero = 5, Sport = "Rugby", ValeurBase = 110000, Taille = 2.4, VitesseGarde = 110, NbGardes = 4,
	  Couleur = Color3.fromRGB(130, 75, 40), Couleur2 = Color3.fromRGB(245, 245, 245),
	  Oeufs = {
		oeuf("RU_Cuir",     "de Cuir",     28, 40,  1,   "T2", Color3.fromRGB(130, 75, 40)),
		oeuf("RU_Boueuse",  "Boueuse",     22, 80,  1.8, "T3", Color3.fromRGB(105, 90, 60)),
		oeuf("RU_Maillot",  "Maillot",     18, 160, 2.9, "T4", Color3.fromRGB(60, 80, 180)),
		oeuf("RU_Melee",    "Mêlée",       14, 300, 4.6, "T5", Color3.fromRGB(200, 60, 60)),
		oeuf("RU_Drop",     "Drop",        10, 540, 7.5, "T5", Color3.fromRGB(245, 245, 245)),
		oeuf("RU_Essai",    "Essai",       6,  900, 12,  "T6", Color3.fromRGB(90, 220, 140)),
		oeuf("RU_ChelemOr", "Chelem d'Or", 2,  1500, 24, "T7", Color3.fromRGB(255, 205, 60)),
	} },

	{ Numero = 6, Sport = "Basket", ValeurBase = 950000, Taille = 2.8, VitesseGarde = 175, NbGardes = 4,
	  Couleur = Color3.fromRGB(235, 115, 30), Couleur2 = Color3.fromRGB(35, 35, 40),
	  Oeufs = {
		oeuf("BK_Parquet",  "Parquet",     26, 50,  1,   "T3", Color3.fromRGB(205, 150, 95)),
		oeuf("BK_Filet",    "Filet",       21, 100, 1.9, "T4", Color3.fromRGB(245, 245, 245)),
		oeuf("BK_Street",   "Street",      18, 200, 3,   "T4", Color3.fromRGB(70, 70, 80)),
		oeuf("BK_AlleyOop", "Alley-oop",   14, 380, 4.8, "T5", Color3.fromRGB(90, 200, 255)),
		oeuf("BK_Dunk",     "Dunk",        11, 660, 8,   "T6", Color3.fromRGB(235, 115, 30)),
		oeuf("BK_Buzzer",   "Buzzer",      7,  1080, 14, "T7", Color3.fromRGB(255, 70, 90)),
		oeuf("BK_PanierOr", "Panier d'Or", 3,  1800, 30, "JACKPOT1", Color3.fromRGB(255, 200, 40)),
	} },

	{ Numero = 7, Sport = "Football", ValeurBase = 8500000, Taille = 2.6, VitesseGarde = 280, NbGardes = 5,
	  Couleur = Color3.fromRGB(250, 250, 250), Couleur2 = Color3.fromRGB(30, 30, 35),
	  Oeufs = {
		oeuf("FO_Hexagone", "Hexagone",    24, 60,  1,   "T3", Color3.fromRGB(250, 250, 250)),
		oeuf("FO_Nocturne", "Nocturne",    20, 120, 1.9, "T4", Color3.fromRGB(45, 55, 110)),
		oeuf("FO_Stade",    "Stade",       17, 240, 3,   "T5", Color3.fromRGB(80, 190, 95)),
		oeuf("FO_Lucarne",  "Lucarne",     14, 450, 4.8, "T5", Color3.fromRGB(150, 230, 255)),
		oeuf("FO_Penalty",  "Penalty",     11, 780, 8,   "T6", Color3.fromRGB(230, 60, 70)),
		oeuf("FO_Coupe",    "Coupe",       9,  1320, 15, "T7", Color3.fromRGB(190, 240, 255)),
		oeuf("FO_BallonOr", "Ballon d'Or", 5,  2700, 40, "JACKPOT2", Color3.fromRGB(255, 205, 60)),
	} },
}

---------------------------------------------------------------
-- INDEX DES ŒUFS (construit automatiquement)
---------------------------------------------------------------
ConfigJeu.DesignParId = {}
ConfigJeu.ZoneDuDesign = {}
for _, zone in ipairs(ConfigJeu.Zones) do
	for _, design in ipairs(zone.Oeufs) do
		ConfigJeu.DesignParId[design.Id] = design
		ConfigJeu.ZoneDuDesign[design.Id] = zone.Numero
	end
end

---------------------------------------------------------------
-- TIRAGES
---------------------------------------------------------------
function ConfigJeu.TirerDesign(numeroZone)
	local zone = ConfigJeu.Zones[numeroZone] or ConfigJeu.Zones[1]
	local total = 0
	for _, design in ipairs(zone.Oeufs) do
		total += design.Poids
	end
	local tirage = math.random() * total
	for _, design in ipairs(zone.Oeufs) do
		tirage -= design.Poids
		if tirage <= 0 then
			return design
		end
	end
	return zone.Oeufs[1]
end

function ConfigJeu.TirerRarete(idDesign)
	local design = ConfigJeu.DesignParId[idDesign]
	local chances = design and design.Chances or PALIERS.T1
	local total = 0
	for _, r in ipairs(ConfigJeu.Raretes) do
		total += chances[r.Id] or 0
	end
	local tirage = math.random() * total
	for _, r in ipairs(ConfigJeu.Raretes) do
		tirage -= chances[r.Id] or 0
		if tirage <= 0 then
			return r
		end
	end
	return ConfigJeu.Raretes[1]
end

---------------------------------------------------------------
-- VALEURS, NOMS ET APPARENCE
---------------------------------------------------------------
function ConfigJeu.ValeurBalle(numeroZone, idDesign, idRarete)
	local zone = ConfigJeu.Zones[numeroZone] or ConfigJeu.Zones[1]
	local design = ConfigJeu.DesignParId[idDesign]
	local rarete = ConfigJeu.RareteParId[idRarete] or ConfigJeu.Raretes[1]
	return math.max(1, math.round(zone.ValeurBase * (design and design.Bonus or 1) * rarete.Multiplicateur))
end

function ConfigJeu.TempsEclosion(idDesign)
	local design = ConfigJeu.DesignParId[idDesign]
	return design and design.TempsEclosion or 20
end

function ConfigJeu.NomOeuf(numeroZone, idDesign)
	local zone = ConfigJeu.Zones[numeroZone] or ConfigJeu.Zones[1]
	local design = ConfigJeu.DesignParId[idDesign]
	return "Œuf " .. zone.Sport .. (design and (" " .. design.Nom) or "")
end

function ConfigJeu.NomBalle(numeroZone, idDesign, idRarete)
	local zone = ConfigJeu.Zones[numeroZone] or ConfigJeu.Zones[1]
	local design = ConfigJeu.DesignParId[idDesign]
	local rarete = ConfigJeu.RareteParId[idRarete]
	local nom = zone.Sport
	if design then
		nom ..= " " .. design.Nom
	end
	if rarete then
		nom ..= " · " .. rarete.Nom
	end
	return nom
end

function ConfigJeu.CouleurOeuf(numeroZone, idDesign)
	local zone = ConfigJeu.Zones[numeroZone] or ConfigJeu.Zones[1]
	local design = ConfigJeu.DesignParId[idDesign]
	return (design and design.Couleur) or zone.Couleur
end

-- Les plus beaux œufs d'une zone sont un peu plus gros
function ConfigJeu.TailleOeuf(numeroZone, idDesign)
	local zone = ConfigJeu.Zones[numeroZone] or ConfigJeu.Zones[1]
	local rang = 1
	for i, design in ipairs(zone.Oeufs) do
		if design.Id == idDesign then
			rang = i
			break
		end
	end
	return zone.Taille * (1 + (rang - 1) * 0.07)
end

---------------------------------------------------------------
-- OUTILS
---------------------------------------------------------------
local suffixes = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx" }
function ConfigJeu.FormaterNombre(nombre)
	local i = 1
	while nombre >= 1000 and i < #suffixes do
		nombre /= 1000
		i += 1
	end
	if i == 1 then
		return tostring(math.floor(nombre))
	end
	return string.format("%.1f%s", nombre, suffixes[i])
end

function ConfigJeu.FormaterDuree(secondes)
	secondes = math.max(0, math.floor(secondes))
	if secondes >= 3600 then
		return string.format("%dh%02d", secondes // 3600, (secondes % 3600) // 60)
	elseif secondes >= 60 then
		return string.format("%dm%02d", secondes // 60, secondes % 60)
	end
	return secondes .. "s"
end

return ConfigJeu
```

---

## 9. Pour démarrer dans Claude Code

1. Relier Claude Code à Roblox Studio avec le serveur MCP officiel de Roblox (dépôt GitHub `Roblox/studio-rust-mcp-server`) et vérifier que le plugin MCP apparaît dans l'onglet Plugins de Studio.
2. Ouvrir Find the Ball **en ligne** dans Studio, faire `File > Download a Copy`.
3. Lancer Play, vérifier le diagnostic et l'Output.
4. Commencer la **phase 1**, en demandant d'abord à Laurence de trancher : éclosion automatique ou par la touche E.
