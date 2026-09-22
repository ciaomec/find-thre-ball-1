# Appairer Claude Code et Roblox Studio (Mac)

Objectif : que Claude puisse **écrire directement dans ton Studio** — créer les
scripts, lire l'Output, lancer Play — au lieu de te donner du code à copier-coller.

## Pourquoi il faut le faire sur ton Mac

Roblox Studio tourne **sur ton ordinateur**. Le pont qui relie Claude à Studio
(le « serveur MCP ») doit donc tourner sur ce même ordinateur, à côté de Studio.

La session Claude que tu utilises en ce moment (claude.ai/code, dans le
navigateur) tourne **dans le cloud**, sur une machine distante. Elle ne peut
pas voir ton Studio. C'est comme demander à un plombier au téléphone de tourner
le robinet lui-même : il faut qu'il soit dans la pièce.

Donc : on installe Claude Code **sur ton Mac**, et c'est là qu'on travaillera le jeu.
Cette session-ci reste utile pour réfléchir, décider et préparer les documents.

---

## Les 5 étapes

### Étape 1 — Installer l'application Claude sur le Mac

1. Télécharger : https://claude.ai/api/desktop/darwin/universal/dmg/latest/redirect
2. Ouvrir le `.dmg`, glisser **Claude** dans le dossier Applications.
3. Lancer Claude, se connecter avec ton compte.
4. Cliquer sur l'onglet **Code** en haut. **Lancer l'app au moins une fois** avant l'étape 3.

### Étape 2 — Fermer Claude et Roblox Studio

L'installateur de l'étape 3 refuse de travailler si les deux tournent.
Quitter complètement les deux (Pomme > Quitter, pas juste fermer la fenêtre).

### Étape 3 — Installer le pont Roblox ↔ Claude

1. Aller sur https://github.com/Roblox/studio-rust-mcp-server/releases
2. Télécharger la dernière version **macOS** (fichier `.zip`).
3. Dézipper, puis **double-cliquer sur l'installateur**.
   - Si le Mac dit « développeur non identifié » : clic droit sur l'installateur >
     **Ouvrir** > **Ouvrir**.
4. L'installateur fait deux choses tout seul :
   - il pose le **plugin** dans Roblox Studio,
   - il inscrit le pont dans la configuration de Claude.

### Étape 4 — Vérifier que ça marche

1. Rouvrir **Roblox Studio** et ouvrir **Find the Ball en ligne**
   (Home > My Games, pas un fichier du Mac — sinon pas d'accès aux DataStores).
2. Onglet **Plugins** : le plugin MCP doit apparaître.
3. Dans la fenêtre **Output** de Studio, tu dois lire :
   `The MCP Studio plugin is ready for prompts.`
4. Rouvrir **Claude**, onglet **Code**.
5. Taper : `Quel est le mode actuel de Roblox Studio ?`
   Si Claude répond en utilisant l'outil `get_studio_mode`, **c'est appairé**. 🎉

### Étape 5 — Récupérer le dossier du projet

Dans Claude (onglet Code), sur le Mac, demander :

> Clone le dépôt https://github.com/ciaomec/find-thre-ball-1 dans mon dossier Documents,
> puis lis `docs/passation.md` et `CLAUDE.md`.

Comme ça le Claude de ton Mac connaît tout le projet dès la première seconde.

---

## Ce que Claude pourra faire une fois appairé

| Outil | Ce que ça veut dire concrètement |
|---|---|
| `run_code` | Créer, lire et modifier les scripts dans Studio |
| `get_console_output` | Lire les erreurs de l'Output à ta place |
| `start_stop_play` | Lancer et arrêter le test Play |
| `run_script_in_play_mode` | Tester un bout de code en conditions réelles |
| `insert_model` | Insérer un modèle du Creator Store (décors) |
| `get_studio_mode` | Savoir si Studio est en édition ou en test |

---

## Si ça ne marche pas

| Symptôme | Solution |
|---|---|
| Le plugin n'apparaît pas dans Plugins | Studio était ouvert pendant l'installation : tout fermer et relancer l'installateur. |
| Claude ne voit pas les outils Roblox | Quitter **complètement** l'app Claude (Pomme > Quitter) et la rouvrir. |
| « Failed to fetch place info » / « User is not authenticated » | Se déconnecter puis reconnecter dans Roblox Studio. |
| « You must publish this place to the web » | Le fichier ouvert vient du Mac. Rouvrir le jeu **en ligne**. |
| Le Mac bloque l'installateur | Clic droit > **Ouvrir**, ou Réglages Système > Confidentialité et sécurité > **Ouvrir quand même**. |

### Configuration manuelle (seulement si l'installateur a échoué)

Dans Claude : **Réglages > Développeur > Modifier la configuration**, ajouter :

```json
{
  "mcpServers": {
    "Roblox_Studio": {
      "command": "/Applications/RobloxStudioMCP.app/Contents/MacOS/rbx-studio-mcp",
      "args": ["--stdio"]
    }
  }
}
```

Puis quitter et rouvrir Claude.

---

## Le rituel de chaque séance

1. Roblox Studio → ouvrir **Find the Ball en ligne**.
2. `File > Download a Copy` (copie de secours sur le Mac).
3. Vérifier dans l'Output : `The MCP Studio plugin is ready for prompts.`
4. Ouvrir Claude, onglet **Code**, dans le dossier du projet.
5. Travailler, **tester avec Play**, et ne publier **qu'avec ton accord**.
