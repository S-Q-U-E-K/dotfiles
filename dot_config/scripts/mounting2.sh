#!/bin/bash

## Setup ##

##Variables:
echo "Setting Variables"
DISK=/dev/disk/by-id/nvme-HFM001TD3JX013N_CYA3N053410403J2F
boot_partuuid=$(blkid -s PARTUUID -o value $DISK-part8)
boot_mapper_name=cryptroot-luks1-partuuid-$boot_partuuid
boot_mapper_path=/dev/mapper/$boot_mapper_name
INST_MNT=$(mktemp -d)

#Unlock Disk
echo "Unlocking Disk"
read -p "Are you sure you wish to continue?"
if [ "$REPLY" != "yes" ]; then
    exit
fi

cryptsetup open $DISK-part8 $boot_mapper_name


#Properly mounting newly created subvolumes
echo "creating mountpoints"
read -p "Are you sure you wish to continue?"
if [ "$REPLY" != "yes" ]; then
    exit
fi

cd ~
mount $boot_mapper_path $INST_MNT -o subvol=/@/0/snapshot,compress-force=zstd,noatime,space_cache=v2


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

