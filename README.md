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

4. **Partitionnement, formatage et montage :**

> [!IMPORTANT]
> Nous avons 2 options au niveau du partitionnement :
> - Option#1 : `GPT/UEFI`,
> - Option#2 : `MBR/BIOS`.
> 
> Je vous recommande de choisir l'option#2 `MBR/BIOS` uniquement si vous avez un très vieux ordinateur (non compatible UEFI) ou si vous utilisez une machine virtuelle (VM).
>
> Si ce n'est pas le cas, choisissez l'option#1 `GPT/UEFI`.

> [!TIP]
> Il est possible de partir sur l'option#1 `GPT/UEFI` dans une VM sur `VirtualBox` en activant l'option `Activer EFI (OS spéciaux seulement)` dans l'onglet `System` du menu de configuration de la VM.

  1. **Option#1 (GPT/UEFI) :**
      1. **Identifiez le disque à partitionner :**
          ```bash
          [root@nixos:~]# lsblk 
          NAME  MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
          loop0   7:0    0  1.1G  1 loop /nix/.ro-store
          sda     8:0    0   60G  0 disk 
          sr0    11:0    1  1.1G  0 rom  /iso
          ```

      > [!NOTE]
      > Ici, nous utiliserons le disque `/dev/sda` de 60GB.

      2. **Pour réinitialiser le disque, lancez `gdisk` et utilisez successivement les options `x` et `z` :**
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

          > [!NOTE]
          > Un redémarrage du système est nécessaire.

      3. **Schéma de partitionnement UEFI/GPT souhaité avec 4G de RAM :**
          ```
          Number  Start (sector)    End (sector)  Size       Code  Name
          1            2048         1050623   512.0 MiB   EF00  EFI system partition
          2         1050624       125827071   59.5 GiB    8E00  Linux LVM
          ```

          > Idéalement, créez une partition `swap` égale à la quantité de RAM disponible
          > sur votre machine. Utilisez la commande `free -m` pour en savoir plus.

      4. **Procédure de partionnement avec `gdisk` :**
          ```bash
          [root@nixos:~]# gdisk /dev/sda
          GPT fdisk (gdisk) version 1.0.10

          Partition table scan:
            MBR: protective
            BSD: not present
            APM: not present
            GPT: present

          Found valid GPT with protective MBR; using GPT.

          Command (? for help): n
          Partition number (1-128, default 1):
          First sector (34-125829086, default = 2048) or {+-}size{KMGTP}:
          Last sector (2048-125829086, default = 125827071) or {+-}size{KMGTP}: +512M
          Current type is 8300 (Linux filesystem)
          Hex code or GUID (L to show codes, Enter = 8300): ef00
          Changed type of partition to 'EFI system partition'

          Command (? for help): p
          Disk /dev/sda: 125829120 sectors, 60.0 GiB
          Model: VBOX HARDDISK
          Sector size (logical/physical): 512/512 bytes
          Disk identifier (GUID): C17E33F5-1772-4FD8-B271-2F3308695414
          Partition table holds up to 128 entries
          Main partition table begins at sector 2 and ends at sector 33
          First usable sector is 34, last usable sector is 125829086
          Partitions will be aligned on 2048-sector boundaries
          Total free space is 124780477 sectors (59.5 GiB)

          Number  Start (sector)    End (sector)  Size       Code  Name
            1            2048         1050623   512.0 MiB   EF00  EFI system partition

          Command (? for help): n
          Partition number (2-128, default 2):
          First sector (34-125829086, default = 1050624) or {+-}size{KMGTP}:
          Last sector (1050624-125829086, default = 125827071) or {+-}size{KMGTP}:
          Current type is 8300 (Linux filesystem)
          Hex code or GUID (L to show codes, Enter = 8300): 8e00
          Changed type of partition to 'Linux LVM'

          Command (? for help): p
          Disk /dev/sda: 125829120 sectors, 60.0 GiB
          Model: VBOX HARDDISK
          Sector size (logical/physical): 512/512 bytes
          Disk identifier (GUID): C17E33F5-1772-4FD8-B271-2F3308695414
          Partition table holds up to 128 entries
          Main partition table begins at sector 2 and ends at sector 33
          First usable sector is 34, last usable sector is 125829086
          Partitions will be aligned on 2048-sector boundaries
          Total free space is 4029 sectors (2.0 MiB)

          Number  Start (sector)    End (sector)  Size       Code  Name
            1            2048         1050623   512.0 MiB   EF00  EFI system partition
            2         1050624       125827071   59.5 GiB    8E00  Linux LVM

          Command (? for help): w

          Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
          PARTITIONS!!

          Do you want to proceed? (Y/N): Y
          OK; writing new GUID partition table (GPT) to /dev/sda.
          Warning: The kernel is still using the old partition table.
          The new table will be used at the next reboot or after you
          run partprobe(8) or kpartx(8)
          The operation has completed successfully.
          ```

          On vérifie que notre partionnement est correct :
          ```bash
          [root@nixos:~]# fdisk -l /dev/sda
          Disk /dev/sda: 60 GiB, 64424509440 bytes, 125829120 sectors
          Disk model: VBOX HARDDISK
          Units: sectors of 1 * 512 = 512 bytes
          Sector size (logical/physical): 512 bytes / 512 bytes
          I/O size (minimum/optimal): 512 bytes / 512 bytes
          Disklabel type: gpt
          Disk identifier: C17E33F5-1772-4FD8-B271-2F3308695414

          Device       Start       End   Sectors  Size Type
          /dev/sda1     2048   1050623   1048576  512M EFI System
          /dev/sda2  1050624 125827071 124776448 59.5G Linux LVM
          ```

      5. **LVM : `root` & `swap`**
          1. Création du volume physique PV :
              ```bash
              [root@nixos:~]# pvcreate /dev/sda2
              Physical volume "/dev/sda2" successfully created.

              [root@nixos:~]# pvdisplay 
              "/dev/sda2" is a new physical volume of "<59.50 GiB"
              --- NEW Physical volume ---
              PV Name               /dev/sda2
              VG Name               
              PV Size               <59.50 GiB
              Allocatable           NO
              PE Size               0   
              Total PE              0
              Free PE               0
              Allocated PE          0
              PV UUID               ExXNqK-QFPO-FRug-pzxT-3CBP-XspI-RX1sCF
              ```

          2. Création du groupe de volume VG :
              ```bash
              [root@nixos:~]# vgcreate nixos /dev/sda2
              Volume group "nixos" successfully created

              [root@nixos:~]# vgdisplay
              --- Volume group ---
              VG Name               nixos
              System ID
              Format                lvm2
              Metadata Areas        1
              Metadata Sequence No  3
              VG Access             read/write
              VG Status             resizable
              MAX LV                0
              Cur LV                0
              Open LV               0
              Max PV                0
              Cur PV                1
              Act PV                1
              VG Size               <59.50 GiB
              PE Size               4.00 MiB
              Total PE              15231
              Alloc PE / Size       0 / 0
              Free  PE / Size       14975 / <58.50 GiB
              VG UUID               BKmUCc-fRTp-Gpdl-kTM3-CL7K-c9aU-ZsPTKX
              ```
          
          3. Création du volume logique LV `swap` :
              ```bash
              [root@nixos:~]# lvcreate --name swap --size 4G nixos
              Logical volume "swap" created.

              [root@nixos:~]# lvdisplay 
              --- Logical volume ---
              LV Path                /dev/nixos/swap
              LV Name                swap
              VG Name                nixos
              LV UUID                tnYcg8-lHyG-qrfs-7UpM-qJ9A-Pp9w-8d6y9T
              LV Write Access        read/write
              LV Creation host, time nixos, 2025-01-03 23:14:15 +0000
              LV Status              available
              # open                 0
              LV Size                4.00 GiB
              Current LE             1024
              Segments               1
              Allocation             inherit
              Read ahead sectors     auto
              - currently set to     256
              Block device           254:0
              ```

          4. Création du volume logique LV `root` :
              ```bash
              [root@nixos:~]# lvcreate --name root --extents 100%FREE nixos
              Logical volume "root" created.

              [root@nixos:~]# lvdisplay 
              --- Logical volume ---
              LV Path                /dev/nixos/swap
              LV Name                swap
              VG Name                nixos
              LV UUID                tnYcg8-lHyG-qrfs-7UpM-qJ9A-Pp9w-8d6y9T
              LV Write Access        read/write
              LV Creation host, time nixos, 2025-01-03 23:14:15 +0000
              LV Status              available
              # open                 0
              LV Size                4.00 GiB
              Current LE             1024
              Segments               1
              Allocation             inherit
              Read ahead sectors     auto
              - currently set to     256
              Block device           254:0
              
              --- Logical volume ---
              LV Path                /dev/nixos/root
              LV Name                root
              VG Name                nixos
              LV UUID                NyIVfq-Cdrn-bZhj-xabr-cWuI-ev5x-awp7F5
              LV Write Access        read/write
              LV Creation host, time nixos, 2025-01-03 23:16:43 +0000
              LV Status              available
              # open                 0
              LV Size                <54.50 GiB
              Current LE             13951
              Segments               1
              Allocation             inherit
              Read ahead sectors     auto
              - currently set to     256
              Block device           254:1
              ```

      6. Formatage des partitions :
          1. Boot `EFI` :                  
              La spécification UEFI impose la prise en charge des systèmes de fichiers FAT12, FAT16 et FAT32 (voir [UEFI specification version 2.9, section 13.3.1.1](https://uefi.org/sites/default/files/resources/UEFI_Spec_2_9_2021_03_18.pdf#G17.1019485)). 
          
              Pour éviter les problèmes potentiels avec d'autres systèmes d'exploitation et puisque la spécification UEFI dit que l'UEFI "englobe l'utilisation de FAT32 pour une partition système, et FAT12 ou FAT16 pour les supports amovibles", il est recommandé d'utiliser FAT32 :

              ```bash
              [root@nixos:~]# mkfs.fat -F 32 -n EFI /dev/sda1
              ```
          2. Formatage des 2 volumes logique `root` & `swap` :
              ```bash
              [root@nixos:~]# mkfs.ext4 -L root /dev/nixos/root
              mke2fs 1.47.1 (20-May-2024)
              Creating filesystem with 14285824 4k blocks and 3571712 inodes
              Filesystem UUID: 258885ee-3f90-4331-a984-6dd3df328fd0
              Superblock backups stored on blocks: 
                32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
                4096000, 7962624, 11239424

              Allocating group tables: done                            
              Writing inode tables: done                            
              Creating journal (65536 blocks): done
              Writing superblocks and filesystem accounting information: done  
              ```

              Initialiser le volume logique `swap` en tant que partition d'échange :

              ```bash
              [root@nixos:~]# mkswap -L swap /dev/nixos/swap
              Setting up swapspace version 1, size = 4 GiB (4294963200 bytes)
              LABEL=swap, UUID=941a645d-718c-4307-8ba6-bd63c5726bcd
              ```

      7. **Montage des partitions :**

          **Montage de la partition `root` :**
          ```bash
          [root@nixos:~]# mount /dev/nixos/root /mnt
          ```

          **Création des répertoires nécessaires :**
          ```bash
          [root@nixos:~]# mkdir -p /mnt/boot
          ```

          **Montage de la partition `boot` :**
          ```bash
          [root@nixos:~]# mount /dev/disk/by-label/EFI /mnt/boot
          ```

          **Montage de la partition `home` (si séparée) :**
          ```bash
          [root@nixos:~]# mount /dev/nixos/home /mnt/home
          ```

          **Activation de la Swap :**
          ```bash
          [root@nixos:~]# swapon /dev/nixos/swap
          ```

          **Vérification :**
          ```bash
            [root@nixos:~]# lsblk -o NAME,LABEL,TYPE,LABEL,MOUNTPOINT,FSTYPE,SIZE,FSAVAIL
            NAME           LABEL                      TYPE LABEL                      MOUNTPOINT     FSTYPE       SIZE FSAVAIL
            loop0                                     loop                            /nix/.ro-store squashfs     1.1G       0
            sda                                       disk                                                         60G
            ├─sda1         EFI                        part EFI                        /mnt/boot      vfat         512M  488.3M
            └─sda2                                    part                                           LVM2_member 59.5G
              ├─nixos-swap swap                       lvm  swap                       [SWAP]         swap           4G
              └─nixos-root root                       lvm  root                       /mnt           ext4        55.5G   48.2G
            sr0            nixos-minimal-24.11-x86_64 rom  nixos-minimal-24.11-x86_64 /iso           iso9660      1.1G       0
          ```



    2. **Option#2 (MBR/BIOS) :**

        Coming soon


## CONFIGURATION NixOS ET INSTALLATION

  1. **Option#1 (GPT/UEFI) :**
      1. Fichier de configuration NixOS :        
          1. Générer le fichier de configuration NixOS pour une installation standard en mode serveur :
              ```bash
              [root@nixos:~]# nixos-generate-config --root /mnt
              ```

          2. Récupérartion de mon fichier de configuration NixOS :
              ```bash
              [root@nixos:~]# curl -o /mnt/etc/nixos/configuration.nix https://github.com/allfab/nixos-installation-guide/main/configuration.nix
              ```

      3. Installation de NixOS :
        ```bash
        [root@nixos:~]# nixos-install
        ```

      4. Redémarrage du système :
        ```bash
        [root@nixos:~]# reboot
        ```

  2. **Option#2 (MBR/BIOS) :**
      1. Fichier de configuration NixOS :        
          1. Générer le fichier de configuration NixOS pour une installation standard en mode serveur :
              ```bash
              [root@nixos:~]# nixos-generate-config --root /mnt
              ```

          2. Récupérartion de mon fichier de configuration NixOS :
              ```bash
              [root@nixos:~]# curl -o /mnt/etc/nixos/configuration.nix https://github.com/allfab/nixos-installation-guide/main/configuration.nix
              ```

      3. Installation de NixOS :
        ```bash
        [root@nixos:~]# nixos-install
        ```

      4. Redémarrage du système :
        ```bash
        [root@nixos:~]# reboot
        ```