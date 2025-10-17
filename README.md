# ben-fradj_adam_tp1

## Run Rabbit Run

### 🧠 Description du concept

Le joueur progresse dans un univers en 2D, de type arena platformer, avec une vue latérale. À chaque instant, des pièges surgissent, et l’environnement change subtilement pour piéger le joueur.

Forêt vivante : les plateformes, champignons et arbres semblent changer de forme. Certains éléments disparaissent ou deviennent hostiles.

Carottes maudites : chaque carotte ramassée attire davantage l’attention de la forêt, augmentant la difficulté et les illusions visuelles.

Obstacles et dangers :

Pièges vivants : lianes qui claquent, champignons explosifs, pics surgissant du sol.

Entités fantomatiques : silhouettes apparaissant soudainement, bloquant ou poursuivant brièvement le joueur.

Écran distordu : l’environnement peut vaciller, clignoter ou basculer de teinte pour troubler la perception du joueur.

Carotte spectrale : objet bonus piégé, difficile à atteindre, déclenche un mode cauchemar avec accélération des pièges.

L'expérience est basée sur la rapidité, l’instinct et la gestion de la panique face aux dangers constants dans une atmosphère oppressante.

### 🎮 Choix d'interactions avec le clavier

Les contrôles sont volontairement réduits pour privilégier les réflexes et l’intensité de l’action :

Flèche gauche/droite → déplacement du lapin

Flèche du haut → saut


Échap → pause/menu

L’interface est minimale pour ne pas distraire le joueur de l’ambiance et du danger immédiat.

### 🎨 Choix de médias visuels

Palette de couleurs : teintes sombres (bleu nuit, noir, violet), ponctuées de lumières toxiques (néon vert, cyan, bleu électrique) pour créer un contraste entre nature morte et vie surnaturelle.

Lapin : silhouette blanche ou grise, yeux brillants, parfois taché ou corrompu selon le score ou la difficulté atteinte.

Carottes : éclat étrange, certaines semblent "vivantes" ou pulsantes.

Environnement : forêt dense, arbres aux formes distordues, champignons fluorescents, grottes aux entrées magiques.

Obstacles : forme de rond avec des pics autour

### 🔊 Choix de médias sonores

Ambiance : Son de forêt

Musique : Run Rabbit Run

Carottes : petit son cristallin ou distordu à la collecte.

Obstacles : son du cri du personnage

Saut du lapin : son de lazer retro

# ben-fradj_adam_tp2 (suite du tp1)

Un mini plateformer 2D réalisé avec Godot où le joueur doit ramasser 5 carottes tout en évitant des obstacles qui tombent du ciel.
Au contact d’un obstacle : camera shake + zoom, le personnage joue l’animation die (devient rouge), un son de mort est joué et la partie redémarre après un court délai.
Le jeu inclut des sons pour le saut, la mort, la collecte de carottes, ainsi que deux musiques : menu et niveau.

## Règles & Objectif

Objectif principal : ramasser 5 carottes dispersées dans le niveau et survivre.

Échec : si un obstacle (boule/objet) touche le joueur, la caméra shake + zoom sur le personnage, l’animation die se joue avec son, puis la scène redémarre automatiquement.


## Contrôles (Input Map)

marcher : → (droite)

marcher_2 : ← (gauche)

sauter : ↑ (saut)

esc : Ouvrir / fermer le menu pause

Le personnage se retourne visuellement (flip horizontal) selon la direction (gauche/droite).
Une animation sauter est jouée lors du saut, puis retour à l’état sol (idle / marche).

## Audio & Effets

SFX

Saut : joué à chaque impulsion de saut.

Carotte ramassée : son crunch

Mort : son dédié au moment du die. Crie du personnage

Musiques

Menu : musique de fond dans la scène de menu.

Niveau : musique de fond différente pendant la partie.

FX Caméra

Camera shake au contact d’un obstacle.


## Scènes & Nœuds
1) Scène de jeu (niveau)

Racine : Node2D

Map
Sprite/tilemap du décor (fond du niveau).

StaticBody2D, StaticBody2D2…
Plates-formes / colliders du niveau (sols/murs).

CharacterBody2D
Le joueur.

CollisionShape2D : collision du joueur.

Essai : Sprite (ou AnimatedSprite2D) du perso (flippé gauche/droite via scale.x).

AnimationPlayer : animations marche, sauter, die, RESET (idle).

L’anim die colore le perso en rouge (ou c’est forcé via script), puis relance la scène après délai.

Script joueur :

Gravité manuelle + saut.

Flip visuel gauche/droite.

Détection collision avec RigidBody2D (impulsion).

Gestion mort → joue son + anim → Timer → redémarrage.

Carotte, Carotte2, … Carotte5 (Area2D)
Collectibles dans le groupe carrots.

CollisionShape2D + éventuel sprite.

Script de carotte : émet le signal picked, joue Animation “taken”, se supprime (queue_free()).


Area2D, Area2D2…
Obstacles qui tombent (simulent la gravité).

Script simple : ajoute une vitesse verticale (velocity.y += gravity * delta), supprime hors écran.

Groupés (par ex. obstacles) pour que la caméra et la logique puissent s’y connecter facilement.

PauseMenu (CanvasLayer)

ColorRect (fond semi-transparent)

VBoxContainer

ContinueButton : enlève pause.

RestartButton : reload scène.

QuitButton : quitter le jeu.

Script : process_mode = WHEN_PAUSED pour recevoir l’input en pause.

AudioStreamPlayer2D…
Plusieurs lecteurs audio :

SFX saut (AudioStreamPlayer2D2),

SFX mort (AudioStreamPlayer2D4),

Musiques (niveau et/ou menu), etc.

Caméra : shake quand le joueur entre en collision avec un Area2D d’obstacle, puis revient au zoom normal.

2) Scène de menu

Racine : Node2D

Map : fond du menu.

Logo2 / Logobig / Play : éléments UI/visuels.

Button : bouton “Play” qui charge la scène de jeu.

AudioStreamPlayer2D / …2 : musique du menu & éventuels sons d’UI.

Le menu peut être redirigé vers la scène de jeu via get_tree().change_scene_to_file("res://…").

