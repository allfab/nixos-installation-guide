# Guide d'installation de NixOS

## INTRODUCTION

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

## PRÉPARATIONS

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

### Configuration du BIOS/UEFI

Certains paramètres système UEFI doivent être ajustés pour l'installation de NixOS. Pour trouver les étapes exactes pour votre machine, effectuez une recherche rapide sur le Web pour votre modèle. Par exemple, sur mon Framework, vous appuyez sur « F12 » au démarrage pour accéder au menu UEFI.

Une fois dans le menu du UEFI :

1. **Assurez-vous que le démarrage sécurisé est désactivé**.
2. **Assurez-vous que le démarrage rapide est désactivé**.
3. **Assurez-vous que le mode UEFI est activé**.
4. **Assurez-vous que le démarrage à partir de l'USB est activé**.


## PRÉRÉGLAGES / CONFIGURATION DU SYSTÈME

> [!NOTE]
> On effectue cette configuration tout de suite après avoir démarrez/bootez la machine via le support d'installation de NixOS.

```bash
<<< Welcome to NixOS 24.11.712148.edf04b75c13c (x86_x64) - tty1 >>>
The "nixos" and "root" accounts have empty passwords.

To log in over ssh you must set a password for either "nixos" or "root"
with `passwd` (prefix with `sudo` for "root"), or add your public key to
/home/nixos/.ssh/authorized_keys or /root/.ssh/authorized_keys.

If you need a wireless connection, type
`sudo systemctl start wpa_supplicant` and configure a
network using `wpa_cli`. See the NixOS manual for details.


Run 'nixos-help' for the NixOS manual.

nixos login: nixos (automatic login)

[nixos@nixos:~]$
```

1. **Changer la disposition du clavier (passer d'un clavier QWERTY à un clavier AZERTY) :**

    ```bash
    [nixos@nixos:~]$ sudo loadkeys fr-latin1
    ```

2. **Changement des mots de passe des utilisateurs `nixos` et `root` afin de pouvoir établir une connexion `ssh`** :

    Pour `nixos` :
    ```bash
    [nixos@nixos:~]$ passwd 
    New password: 
    Retype new password:
    passwd: password updated successfully
    ```

    Pour `root`:
    ```bash
    [nixos@nixos:~]$ sudo su -

    [root@nixos:~]# passwd 
    New password: 
    Retype new password: 
    passwd: password updated successfully

    [root@nixos:~]#
    ```

3. **Configuration d'une connexion Wifi :**

    Si vous avez besoin d'une connexion sans fil, tapez :

    ```bash
    [nixos@nixos:~]$ sudo systemctl start wpa_supplicant
    ```

    Ensuite, configurez un réseau à l'aide de `wpa_cli` :

    ```bash
    [nixos@nixos:~]$ wpa_cli

    add_network
    0
    set_network 0 ssid "myhomenetwork"
    OK
    set_network 0 psk "mypassword"
    OK
    set_network 0 key_mgmt WPA-PSK
    OK
    enable_network 0
    OK
    ```

    Ensuite, quittez `wpa_cli` :
    ```bash
    quit
    ```

4. **Partitionnement LVM via `gdisk` :**

    Identifiez le disque à partitionner :
    ```bash
    [root@nixos:~]# lsblk 
    NAME  MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
    loop0   7:0    0  1.1G  1 loop /nix/.ro-store
    sda     8:0    0   60G  0 disk 
    sr0    11:0    1  1.1G  0 rom  /iso
    ```

    > [!NOTE]
    > Ici, nous utiliserons le disque `/dev/sda` de 60GB.

    Pour réinitialiser le disque, lancez `gdisk` et utilisez successivement les options `x` et `z` :
    ```bash
    [nixos@nixos:~]$ sudo su -
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

    Schéma de partitionnement UEFI/GPT souhaité :
    ```
      Device        Start       End   Sectors  Size Type
      /dev/sda1      2048    206847    204800  100M EFI System
      /dev/sda2    206848   2303999   2097152    1G Linux filesystem
      /dev/sda3   2304000  10692607   8388608    4G Linux swap
      /dev/sda4  10692608 117229567 106536960 50.8G Linux filesystem
    ```

    > Idéalement, créez une partition `swap` égale à la quantité de RAM disponible
    > sur votre machine. Utilisez la commande `free -m` pour en savoir plus.
