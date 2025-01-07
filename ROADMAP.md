# ROADMAP

Feuille de route pour un poste de travail sous NixOS.


## Préparatifs

- [x] Support d'installation
- [x] Configuration du BIOS/UEFI

## Préréglages / Configuration du système

- [x] Changer la disposition du clavier (passer d'un clavier QWERTY à un clavier AZERTY)
- [x] Changement des mots de passe des utilisateurs `nixos` et `root` afin de pouvoir établir une connexion `ssh`
- [x] Configuration d'une connexion Wifi
- [x] Partitionnement LVM via `gdisk`
- [x] Connection WIFI
- [x] Configuration SSH + Changement des mots de passe

## Installation et configuration des utilitaires
- [x] Installation d'`htop`
- [ ] Configuration d'`htop` (faire apparaître la métrique `zram` par défaut sur le tableau de bord),
- [x] Installation de vim
- [ ] Configuration de `vim` (personnalisation via ~/.vimrc),

## Configuration Nix

- [x] Configuration du système par défaut
- [x] Environnemnt de bureau GNOME :
    - Installation des extensions,
    - Est-ce qu'il est possible d'activer/paramétrer les extensions via Nix ?
- [ ] Environnemnt de bureau KDE

