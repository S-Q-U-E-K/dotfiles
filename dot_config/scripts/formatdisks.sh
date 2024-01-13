#!/bin/bash

## A small script to setup a testing vm for disk scripts
echo "Installing tools"
nix-env -iA nixos.cryptsetup nixos.btrfs-progs nixos.gptfdisk

##Variables:
echo "Setting Variables"
INST_TZ=Europe/London
INST_HOST='NixLaptop'
INST_LINVAR='linux'
DISK=/dev/vda
DISK2=/dev/vda2
DISK1=/dev/vda1
boot_partuuid=$(blkid -s PARTUUID -o value $DISK2)
boot_mapper_name=cryptroot-luks1-partuuid-$boot_partuuid
boot_mapper_path=/dev/mapper/$boot_mapper_name
INST_MNT=$(mktemp -d)

## Disks
#Wiping disks
echo "Wiping Disks"
read -p "Are you sure you wish to continue?"
if [ "$REPLY" != "yes" ]; then
    exit
fi

sgdisk --zap-all $DISK

#Partioning Disks
echo "Partitioning disks"
read -p "Are you sure you wish to continue?"
if [ "$REPLY" != "yes" ]; then
    exit
fi

sgdisk -n1:1M:+1G -t1:EF00 $DISK
sgdisk -n2:0:0 $DISK

#Encryption
echo "Encrypting disks"
read -p "Are you sure you wish to continue?"
if [ "$REPLY" != "yes" ]; then
    exit
fi

cryptsetup luksFormat --type luks1 $DISK2
cryptsetup open $DISK2 $boot_mapper_name

#Formatting disks
echo "Formatting disks"
read -p "Are you sure you wish to continue?"
if [ "$REPLY" != "yes" ]; then
    exit
fi

mkfs.btrfs $boot_mapper_path
mount $boot_mapper_path $INST_MNT

## Subvolume time!
#creating subvols
echo "changing to temp mount"
read -p "Are you sure you wish to continue?"
if [ "$REPLY" != "yes" ]; then
    exit
fi

cd $INST_MNT

echo "creating subvols"
read -p "Are you sure you wish to continue?"
if [ "$REPLY" != "yes" ]; then
    exit
fi

btrfs subvolume create @
mkdir @/0
btrfs subvolume create @/0/snapshot

for i in {home,root,srv,usr,usr/local,swap,var}; do
    btrfs subvolume create @$i
done

for i in {tmp,spool,log}; do
    btrfs subvolume create @var/$i
done

#Mounting Subvolumes
echo "Mounting Subvols"
read -p "Are you sure you wish to continue?"
if [ "$REPLY" != "yes" ]; then
    exit
fi

cd ~
umount $INST_MNT
mount $boot_mapper_path $INST_MNT -o subvol=/@/0/snapshot,compress-force=zstd,noatime,space_cache=v2

mkdir -p $INST_MNT/{.snapshots,home,root,srv,tmp,usr/local,swap}

mkdir -p $INST_MNT/var/{tmp,spool,log}
mount $boot_mapper_path $INST_MNT/.snapshots/ -o subvol=@,compress-force=zstd,noatime,space_cache=v2

for i in {home,root,srv,swap,usr/local}; do
    mount $boot_mapper_path $INST_MNT/$i -o subvol=@$i,compress-force=zstd,noatime,space_cache=v2
done

for i in {tmp,spool,log}; do
    mount $boot_mapper_path $INST_MNT/var/$i -o subvol=@var/$i,compress-force=zstd,noatime,space_cache=v2
done

#Disable Copy-on-Write
echo "disable copy-on-write"
read -p "Are you sure you wish to continue?"
if [ "$REPLY" != "yes" ]; then
    exit
fi

for i in {swap,}; do
    chattr +C $INST_MNT/$i
done

#EFI Partition
echo "EFI partition"
read -p "Are you sure you wish to continue?"
if [ "$REPLY" != "yes" ]; then
    exit
fi

mkfs.vfat -n EFI $DISK1
mkdir -p $INST_MNT/boot
mount $DISK1 $INST_MNT/boot
