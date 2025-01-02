# Guide d'installation de NixOS

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
```
# lsblk
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
