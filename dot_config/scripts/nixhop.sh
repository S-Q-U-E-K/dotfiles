#!/bin/bash

## Setup ##
exit
#Install Tools:
echo "Installing tools"
nix-env -iA nixos.cryptsetup nixos.btrfs-progs nixos.gptfdisk nixos.vim

##Variables:
echo "Setting Variables"
DISK=/dev/nvme1n1
boot_partuuid=$(blkid -s PARTUUID -o value $DISK-part8)
boot_mapper_name=cryptroot-luks1-partuuid-$boot_partuuid
boot_mapper_path=/dev/mapper/$boot_mapper_name
INST_MNT=$(mktemp -d)

## Erasing Disks ##
#Unlock Disk
echo "Unlocking Disk"
read -p "Are you sure you wish to continue?"
if [ "$REPLY" != "yes" ]; then
    exit
fi

cryptsetup open $DISK-part8 $boot_mapper_name

#Mounting root
echo "Mounting root subvolumes"
read -p "Are you sure you wish to continue?"
if [ "$REPLY" != "yes" ]; then
    exit
fi

mount $boot_mapper_path $INST_MNT

#Deleting root
echo "deleting root subvolumes"
read -p "Are you sure you wish to continue?"
if [ "$REPLY" != "yes" ]; then
    exit
fi

for i in {tmp,spool,log}; do
    btrfs subvolume delete $INST_MNT/@var/$i
done

for i in {root,srv,swap,usr/local,usr,var}; do
    btrfs subvolume delete $INST_MNT/@$i
done

btrfs subvolume delete $INST_MNT/@/*/snapshot

rm -rf $INST_MNT/@/*

btrfs subvolume delete $INST_MNT/@

cd ~

#creating new subvolumes
echo "creating new subvolumes"
read -p "Are you sure you wish to continue?"
if [ "$REPLY" != "yes" ]; then
    exit
fi

cd $INST_MNT

btrfs subvolume create @
mkdir @/0
btrfs subvolume create @/0/snapshot

for i in {root,srv,usr,usr/local,swap,var}; do
    btrfs subvolume create @$i
done

# exclude these dirs under /var from system snapshot
for i in {tmp,spool,log}; do
    btrfs subvolume create @var/$i
done

#Properly mounting newly created subvolumes
echo "creating mountpoints"
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

# mount subvolumes
echo "mounting subvolumes"
# separate /{home,root,srv,swap,usr/local} from root filesystem
for i in {home,root,srv,swap,usr/local}; do
    mount $boot_mapper_path $INST_MNT/$i -o subvol=@$i,compress-force=zstd,noatime,space_cache=v2
done

# separate /var/{tmp,spool,log} from root filesystem
for i in {tmp,spool,log}; do
    mount $boot_mapper_path $INST_MNT/var/$i -o subvol=@var/$i,compress-force=zstd,noatime,space_cache=v2
done

#disable copy-on-write
echo "disabling copy on write"
read -p "Are you sure you wish to continue?"
if [ "$REPLY" != "yes" ]; then
    exit
fi

for i in {swap,}; do
    chattr +C $INST_MNT/$i
done

#Boot partition
echo "formatting and mounting boot partition"
read -p "Are you sure you wish to continue?"
if [ "$REPLY" != "yes" ]; then
    exit
fi

mkfs.vfat -n EFI $DISK-part9
mkdir -p $INST_MNT/boot/
mount $DISK-part9 $INST_MNT/boot/

##NixOS install
#generate nix config
echo "generate nix config"
read -p "Are you sure you wish to continue?"
if [ "$REPLY" != "yes" ]; then
    exit
fi

nixos-generate-config --root $INST_MNT

vim $INST_MNT/etc/nixos/configuration.nix

nixos-install --root $INST_MNT

#>IF(want to boot Ubuntu) = (boot Ubuntu)
