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
