#!/bin/bash

## Setup ##
#Install Tools:
echo "Installing tools"
pacman -S --needed cryptsetup btrfs-progs vim gparted

##Variables:
echo "Setting Variables"
DISK=/dev/disk/by-id/nvme-HFM001TD3JX013N_CYA3N053410403J2F
boot_partuuid=$(blkid -s PARTUUID -o value $DISK-part8)
boot_mapper_name=cryptroot-luks1-partuuid-$boot_partuuid
boot_mapper_path=/dev/mapper/$boot_mapper_name
INST_MNT=$(mktemp -d)
INST_LINVAR=linux
INST_HOST=ArchLaptop
INST_TZ=Europe/London

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

##Arch install
echo "Installing Arch"
read -p "Are you sure you wish to continue?"
if [ "$REPLY" != "yes" ]; then
    exit
fi

pacstrap $INST_MNT base vi mandoc grub cryptsetup btrfs-progs snapper snap-pac grub grub-btrfs networkmanager dhcpcpp git base-devel
chmod 750 $INST_MNT/root
chmod 1777 $INST_MNT/var/tmp/

pacstrap $INST_MNT $INST_LINVAR
pacstrap $INST_MNT linux-firmware
pacstrap $INST_MNT dosfstools efibootmgr
pacstrap $INST_MNT amd-ucode
genfstab -U $INST_MNT >> $INST_MNT/etc/fstab
sed -i 's|,subvolid=258,subvol=/@/0/snapshot,subvol=@/0/snapshot||g' $INST_MNT/etc/fstab
mkdir -p $INST_MNT/lukskey
dd bs=512 count=8 if=/dev/urandom of=$INST_MNT/lukskey/crypto_keyfile.bin
chmod 600 $INST_MNT/lukskey/crypto_keyfile.bin
cryptsetup luksAddKey $DISK-part2 $INST_MNT/lukskey/crypto_keyfile.bin
chmod 700 $INST_MNT/lukskey

touch $INST_MNT/swap/swapfile
truncate -s 0 $INST_MNT/swap/swapfile
chattr +C $INST_MNT/swap/swapfile
btrfs property set $INST_MNT/swap/swapfile compression none
dd if=/dev/zero of=$INST_MNT/swap/swapfile bs=1M count=8192 status=progress
chmod 700 $INST_MNT/swap
chmod 600 $INST_MNT/swap/swapfile
mkswap $INST_MNT/swap/swapfile
echo /swap/swapfile none swap defaults 0 0 >> $INST_MNT/etc/fstab

echo $INST_HOST > $INST_MNT/etc/hostname

ln -sf $INST_TZ $INST_MNT/etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" >> $INST_MNT/etc/locale.gen
echo "LANG=en_US.UTF-8" >> $INST_MNT/etc/locale.conf


#>IF(want to boot Ubuntu) = (boot Ubuntu)
