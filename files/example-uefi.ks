%pre --interpreter=/bin/bash --log=/tmp/pre.log --erroronfail
logger "Starting anaconda preinstall"

set -x
if [ -e /dev/sda ]; then
  dev_device="sda" 
elif [ -e /dev/vda ]; then
  dev_device="vda" 
else
  echo "ERROR: No disk found!"
  exit 1
fi

# source: https://git.resf.org/sig_core/kickstarts/src/branch/r8/Rocky-8-GenericCloud-Base.ks
# clear the Master Boot Record
dd if=/dev/zero of="/dev/${dev_device}" bs=512 count=1
# create a new GPT partition table
parted -s "/dev/${dev_device}" mklabel gpt
# create a partition for /boot/efi (256MB)
parted -s "/dev/${dev_device}" mkpart primary fat32 1MiB 256MiB
parted -s "/dev/${dev_device}" set 1 boot on
# create a partition for /boot (8192MB)
parted -s "/dev/${dev_device}" mkpart primary xfs 256MiB 8448MiB
# create a partition for prep (4MB)
parted -s "/dev/${dev_device}" mkpart primary 8449MiB 8453MiB
# create a partition for bios_grub (1MB)
parted -s "/dev/${dev_device}" mkpart primary 8454MiB 8455MiB
# create a partition for LVM
parted -s "/dev/${dev_device}" mkpart primary 8455MiB 100%

cat <<EOF >> /tmp/diskpart.cfg
  part /boot/efi --fstype=efi --onpart="${dev_device}1"
  part /boot --fstype=xfs --label=boot --onpart="${dev_device}2"
  part prepboot --fstype="prepboot" --onpart="${dev_device}3"
  part biosboot --fstype="biosboot" --onpart="${dev_device}4"

  part pv.0 --onpart="${dev_device}5"

  volgroup vg_system pv.0
  logvol /               --fstype xfs    --name=lv_root           --vgname=vg_system --size=10240
  logvol /var            --fstype xfs    --name=lv_var            --vgname=vg_system --size=8192   --fsoptions="nodev,nosuid"
  logvol /var/lib/qpidd  --fstype xfs    --name=lv_var_lib_qpidd  --vgname=vg_system --size=3072
  logvol /var/lib/pgsql  --fstype xfs    --name=lv_var_lib_pgsql  --vgname=vg_system --size=24576
  logvol /var/lib/pulp   --fstype xfs    --name=lv_var_lib_pulp   --vgname=vg_system --size=614400
  logvol /var/log        --fstype xfs    --name=lv_var_log        --vgname=vg_system --size=5120   --fsoptions="nodev,nosuid,noexec"
  logvol /var/log/audit  --fstype xfs    --name=lv_var_log_audit  --vgname=vg_system --size=2048   --fsoptions="nodev,nosuid,noexec"
  logvol /var/tmp        --fstype xfs    --name=lv_var_tmp        --vgname=vg_system --size=2048   --fsoptions="nodev,nosuid"
  logvol /usr            --fstype xfs    --name=lv_usr            --vgname=vg_system --size=8192   --fsoptions="nodev"
  logvol /usr/local      --fstype xfs    --name=lv_usr_local      --vgname=vg_system --size=1024   --fsoptions="nodev"
  logvol /openscap       --fstype xfs    --name=lv_openscap       --vgname=vg_system --size=512    --fsoptions="nodev,noexec"
  logvol /home           --fstype xfs    --name=lv_home           --vgname=vg_system --size=1024   --fsoptions="nodev,nosuid"
  logvol /tmp            --fstype xfs    --name=lv_tmp            --vgname=vg_system --size=5120   --fsoptions="nodev,nosuid,noexec"
  logvol /opt            --fstype xfs    --name=lv_opt            --vgname=vg_system --size=4096   --fsoptions="nodev"
  logvol /opt/puppetlabs --fstype xfs    --name=lv_opt_puppetlabs --vgname=vg_system --size=512
  logvol swap            --fstype swap   --name=lv_swap           --vgname=vg_system --size=4096
EOF
%end

%packages
  dhclient
  chrony
  rsync
  @Core
  lsof
  net-tools
  sos
%end

cdrom
lang en_US.UTF-8
selinux --enforcing
keyboard de
skipx
services --disabled gpm,sendmail,cups,pcmcia,isdn,rawdevices,hpoj,bluetooth,openibd,avahi-daemon,avahi-dnsconfd,hidd,hplip,pcscd  
network --bootproto dhcp
firewall --service ssh
authselect --useshadow --passalgo=sha512 --kickstart
timezone Europe/Berlin --utc
bootloader --location=mbr 
%include /tmp/diskpart.cfg
text
shutdown
