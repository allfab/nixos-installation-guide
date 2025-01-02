# Guide d'installation de NixOS

## Introduction

**Prérequis :**

- **Partitionnement de disque LVM** pour plus de flexibilité dans la gestion du stockage,
- **Chargeur de démarrage UEFI** et **partition de démarrage**,
- **Installation via clé USB**,
- **Connexion à Internet via WiFi** (en particulier WPA) si on n'a pas la possibilité de se connecter via Ethernet,
- **Installation complète sur un disque** (pas de dual boot).

**Important :** Toutes les commandes doivent être exécutées en tant qu'utilisateur `root` :
```sh
sudo -i
```

---

## Préparations

### Support d'installation

1. **Téléchargez le CD d'installation minimal 64 bits** depuis la [page de téléchargement de NixOS](https://nixos.org/download.html),
2. **Vérifiez l'intégrité de l'ISO** :

    - Téléchargez le fichier de somme de contrôle SHA256 depuis la même page.
    - Placez le fichier ISO et le fichier de somme de contrôle dans le même dossier.
    - Exécutez :
    
    ```sh
    sha256sum -c <checksum-file>
    ```
  
    - Assurez-vous que la sortie indique que le fichier ISO est `OK`. Si la vérification échoue, téléchargez à nouveau les fichiers ISO et de somme de contrôle et répétez le processus de vérification.

3. **Créer une clé USB bootable**

  - Pensez à utiliser [Ventoy](https://www.ventoy.net/en/index.html "Installez simplement Ventoy sur votre clé USB et copiez-y n'importe quel nombre de fichiers ISO. Vous pouvez ensuite facilement démarrer à partir de n'importe lequel d'entre eux.") pour plus de flexibilité.
  - Vous pouvez également utiliser la ligne de commande :

  1. Identifiez votre clé USB :
  
  ```sh
  lsblk
  ```

  2. Copiez l'ISO sur la clé USB (remplacez `$DISK` par votre clé USB) :
  
  ```sh
  sudo dd if=<ISO_FILE> of=$DISK bs=1M status=progress
  ```

  **Remarque :** cette commande effacera toutes les données de la clé USB. Remplacez `<ISO_FILE>` par le nom de votre fichier ISO.

---

### Configuration du système

Certains paramètres système UEFI doivent être ajustés pour l'installation de NixOS. Pour trouver les étapes exactes pour votre machine, effectuez une recherche rapide sur le Web pour votre modèle. Par exemple, sur mon Framework, vous appuyez sur « F12 » au démarrage pour accéder au menu UEFI.

Une fois dans le menu :

1. **Assurez-vous que le démarrage sécurisé est désactivé**.
2. **Assurez-vous que le démarrage rapide est désactivé**.
3. **Assurez-vous que le mode UEFI est activé**.
4. **Assurez-vous que le démarrage à partir de l'USB est activé**.

---

## Processus d'installation

Changer la disposition du clavier (passer d'un clavier QWERTY à un clavier AZERTY) :
```bash
sudo loadkeys fr-latin1
```

## Partitionnement

Pour réinitialiser le disque, lancez `gdisk` et utilisez successivement les options `x` et `z` :
```bash
[root@nixos:~]# gdisk /dev/sda
GPT fdisk (gdisk) version 1.0.10

Partition table scan:
  MBR: protective
  BSD: not present
  APM: not present
  GPT: present

Found valid GPT with protective MBR; using GPT.

Command (? for help): x

Expert command (? for help): z
About to wipe out GPT on /dev/sda. Proceed? (Y/N): Y
GPT data structures destroyed! You may now partition the disk using fdisk or
other utilities.
Blank out MBR? (Y/N): Y
```

Identifiez le disque à partitionner :
```bash
[root@nixos:~]# lsblk 
NAME  MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
loop0   7:0    0  1.1G  1 loop /nix/.ro-store
sda     8:0    0   60G  0 disk 
sr0    11:0    1  1.1G  0 rom  /iso
```

Option 1°) BIOS/MBR (`fdisk`) :
```
  Device     Boot    Start       End   Sectors  Size Id Type
  /dev/sda1  *        2048   2099199   2097152    1G 83 Linux
  /dev/sda2        2099200  10487807   8388608    4G 82 Linux swap
  /dev/sda3       10487808 117231407 106743600 50.9G 83 Linux
```

Option 2°)  BIOS/GPT (`gdisk`) :
```
  Device        Start       End   Sectors  Size Type
  /dev/sda1      2048      4095      2048    1M BIOS boot
  /dev/sda2      4096   2101247   2097152    1G Linux filesystem
  /dev/sda3   2101248  10489855   8388608    4G Linux swap
  /dev/sda4  10489856 117229567 106739712 50.9G Linux filesystem
```

Option 3°)  UEFI/GPT (`gdisk`) :
```
  Device        Start       End   Sectors  Size Type
  /dev/sda1      2048    206847    204800  100M EFI System
  /dev/sda2    206848   2303999   2097152    1G Linux filesystem
  /dev/sda3   2304000  10692607   8388608    4G Linux swap
  /dev/sda4  10692608 117229567 106536960 50.8G Linux filesystem
```

> Idéalement, créez une partition `swap` égale à la quantité de RAM disponible
> sur votre machine. Utilisez la commande `free -m` pour en savoir plus.
