# Arch Linux *"EASY"* Installation
This is a guide to install Arch Linux on your computer, the Arch way. I have adapted this guide from BrinkerVII on GitHub for my Dell laptop that does not like ext4, and added my prefered configurations.

This guide is reference material for myself, as well as for other people who would like to install Arch for the first time.

## Purpose
* Installing Arch is always portrayed as difficult or frustrating, but it is actually very straightforward once you understand what is going on in the step that you are performing
* I have attempted to explain, in "begginer" level terms, exactly what is happening in each step
* I hope for this to be a learning experience for someone other than myself

## Acknowledgements

>Thank you to [BrinkerVII](brinkervii@gmail.com) for writing the original guide.
>
>Thank you to everyone on the [Arch Wiki](https://wiki.archlinux.org) for the amazing information.

##### Note:
>I **highly** recommend reading through the [Arch Wiki Installation Guide](https://wiki.archlinux.org/index.php/Installation_guide) before begining and any time you get stuck, I will link to specific sections throughout this guide.

## Pre-installation

The installation media and their GnuPG signatures can be acquired from the [download page](https://archlinux.org/download/).

### Verify signature

It is recommended to verify the image signature before use, especially when downloading from an HTTP mirror, where downloads are generally prone to be intercepted to serve malicious images.

On a system with GnuPG installed, do this by downloading the PGP signature (under Checksums) to the ISO directory, and verifying it with:

`$ gpg --keyserver-options auto-key-retrieve --verify archlinux-version-x86_64.iso.sig`

Alternatively, from an existing Arch Linux installation run:

`$ pacman-key -v archlinux-version-x86_64.iso.sig`

You should see
```txt
==> Checking archlinux-2020.02.01-x86_64.iso.sig... (detached)
gpg: Signature made Sat Feb  1 00:57:48 2020 CST
gpg:                using RSA key 4AA4767BBC9C4B1D18AE28B77F2D434B9741E8AC
gpg: Note: trustdb not writable
gpg: Good signature from "Pierre Schmitz <pierre@archlinux.de>" [full]
```
Note the "Good signature" part

##### Note:

>The signature itself could be manipulated if it is downloaded from a mirror site, instead of from [archlinux.org](https://archlinux.org/download/) as above. In this case, ensure that the public key, which is used to decode the signature, is signed by another, trustworthy key. The gpg command will output the fingerprint of the public key.
>
>Another method to verify the authenticity of the signature is to ensure that the public key's fingerprint is identical to the key fingerprint of the [dev's](https://www.archlinux.org/people/developers/) who signed the ISO-file. See [Wikipedia](https://en.wikipedia.org/wiki/Public-key_cryptography) for more information on the public-key process to authenticate keys.


## Boot the live environment

The live environment can be booted from a [USB flash drive](https://wiki.archlinux.org/index.php/USB_flash_installation_media), an [optical disc](https://wiki.archlinux.org/index.php/Optical_disc_drive#Burning) or a network with [PXE](https://wiki.archlinux.org/index.php/PXE). For an alternative means of installation, see [Installation_process](https://wiki.archlinux.org/index.php/Category:Installation_process) at the Arch Wiki.

##### Note:

>Pointing the current boot device to a drive containing the Arch installation media is typically achieved by pressing a key during the POST phase, as indicated on the splash screen. Refer to your motherboard's manual for details. When the Arch menu appears, select Boot Arch Linux and press Enter to enter the installation environment. See [README.bootparams](https://projects.archlinux.org/archiso.git/tree/docs/README.bootparams) for a list of boot parameters, and [packages.x86_64](https://git.archlinux.org/archiso.git/tree/configs/releng/packages.x86_64) for a list of included packages. You will be logged in on the first virtual console as the root user, and presented with a Zsh shell prompt.

To switch to a different console (e.g. to view this guide with ELinks alongside the installation) use the `Alt+arrow` or `Ctrl-Alt-F*` shortcut. 

# The Guide
Or the interesting part!

### Network Config
Assuming our wireless network is `network` and our passphrase is `passphrase`

Start the dhcp client 

`systemctl start dhcpcd`

Find your wireless interface

`ip link`

The result should look like
```txt
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: wlp2s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DORMANT group default qlen 1000
    link/ether 9c:b6:**:**:**:** brd ff:ff:ff:ff:ff:ff
```
Where `wlp2s0` is my wireless interface

Connect to your wireless network

`wpa_supplicant -B -i wlp2s0 -c <(wpa_passphrase network 'passphrase')`

*don't forget the single quotes `'`*

Make sure you recieved an ip address

`ip addr`

Test Connectivity

`ping archlinux.org`

`Ctrl+c` exits ping

##### Note:
> Now you can pull up this guide in another tty (terminal type)
>- `pacman -Sy elinks`
>- `Alt+right-arrow`
>- You are now in tty2
>- `root`
>- `elinks https://github.com/Bluscrn/arch_install/blob/master/ARCH_INSTALLATION_GUIDE.md`
>- Key bindings can be found at [man elinkskeys](https://linux.die.net/man/5/elinkskeys)
>- PgUp and PgDn will suffice for now
>- `Alt+left-arrow` will return you to tty1

### System clock
Your system clock has to be accurate for the setup to work properly. Synchronise the clock with the following command.

`timedatectl set-ntp true`

Additionally, you can verify the clock status with the `timedatectl status` and `date` commands.

## Partitioning
For this portion, we're assuming that the drive we're installing on is `/dev/nvme0n1` and this guide assumes that we want to **overwrite all of the data currently on it**. 

If you would like to save any data on the drive, **NOW** is the time to stop, reboot to your old OS and make backups.

Now that that is out of the way, let's see what your drives look like.

`lsblk`

will give you an output that should look something like
```txt
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda           8:0    1  59.5G  0 disk 
|-sda1        8:1    1   623M  0 part 
`-sda2        8:2    1    64M  0 part 
nvme0n1     259:0    0 238.5G  0 disk 
|-nvme0n1p1 259:1    0   200M  0 part /efi
|-nvme0n1p2 259:2    0    80G  0 part /
`-nvme0n1p3 259:3    0 158.3G  0 part /home
```
We can see that `nvme0n1` is the large drive and the one that we want to install to, sda is the flash drive that I am running the Arch live media off of, so we can ignore that.

Another way to check this is 

`fdisk -l`

where the output looks like
```txt
Disk /dev/nvme0n1: 238.49 GiB, 256060514304 bytes, 500118192 sectors
Disk model: PC300 NVMe SK hynix 256GB               
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: ###########

Device             Start       End   Sectors   Size Type
/dev/nvme0n1p1      2048    411647    409600   200M EFI System
/dev/nvme0n1p2    411648 168183807 167772160    80G Linux root (x86-64)
/dev/nvme0n1p3 168183808 500118158 331934351 158.3G Linux home


Disk /dev/sda: 59.49 GiB, 63864569856 bytes, 124735488 sectors
Disk model: Mass-Storage    
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: ###########

Device     Boot Start     End Sectors  Size Id Type
/dev/sda1  *        0 1275903 1275904  623M  0 Empty
/dev/sda2         164  131235  131072   64M ef EFI (FAT-12/16/32)
```

### Before you start partitioning
Your partition table is not something you can just change on a whim if you change your mind or if you find out you messed up. This guide comes with a partitioning scheme which is pretty flexible.

You should at the very least read the following paragraphs before you start, but I suggest [Partitioning](https://wiki.archlinux.org/index.php/Partitioning) from the Arch Wiki if you would like a better understanding.

#### Your root partition
Your root partition is also the root of your Linux file system tree. This guide has you install your system (/usr, /lib, /var, /etc,...) into this partition. If you follow my partitioning scheme you should make this partition large enough to fit all of the stuff you're going to install. 80GB is quite generous, however, if you are already running another GNU/Linux distribution, you should check how much space your system files are using and use that as a baseline. If you're not running a GNU/Linux distribution or are unfamiliar with the ecosystem, its probably better to go with 80GB to 100GB.

#### The efi partition
If you are running in EFI mode, you need an ESP partition. We will create an `/efi` partition, and bind mount it to /boot, so that when the kernel get updated, your system will still boot.  We will make this large enough for two, maybe three distro's, but if you plan to boot more, or dual-boot Windows, you should probably make this bigger.  Suggested reading - [EFI System Partition](https://wiki.archlinux.org/index.php/EFI_system_partition)

#### The home partition
The home partition is not required to be a seperate partition either, however, having it separate allows you to mount this partition when or if you decide to boot into another distro and still have all your documents and settings in the right place. This partition should also be very large, it is where you will store the majority of your files.

If you decide to skip making a separate home partition, you should make your root partition fill the rest of your disk outside of your boot and swap partitions.

#### The swap partition
Linux uses a swap file or a swap partition for when it runs out of memory for applications. Before the Linux kernel gained support for swap files, it was commonplace to create a swap partition. You can skip making a swap partition and use a swapfile which has the benefit of being able to adjust the size whenever you need and **we will cover this** later in the guide. 

The size of your swap partition or swap file depends on what you want to do with your computer. If you want to be able to use the hibernate functionality, your swap partition or file should at least be the size of your system memory. When you hibernate your computer, Linux uses the swap to store the contents of your memory. If the swap isn't big enough, things will go badly.

You can always be a rebel and run without swap, but don't be surprised when OOM (Out of Memory) hits and running applications start disappearing (the enormous stuttering will be a dead giveaway that you're running out of memory when you don't have any swap space).

#### File system types
This guide uses [xfs](https://wiki.archlinux.org/index.php/XFS) for the root and home partitions. The ESP `/efi` partition _has_ to be FAT32.

You can choose to use [other filesystems](https://wiki.archlinux.org/index.php/File_systems#Create_a_file_system) if you want to, but beware that you can't change your file system without deleting all the files stored on the partition. So changing file systems may be quite the chore if you run into problems with the file system you chose. If you do not know anything about different file systems or do not want to research about the subject and want to get going, just stick with xfs.

#### Example
This is a `df` of my system with Arch, KDE and a couple of small packages installed. 
```txt
Filesystem     Type      Size  Used Avail Use% Mounted on
/dev/nvme0n1p2 xfs        80G   13G   68G  17% /
/dev/nvme0n1p3 xfs       159G   14G  146G   9% /home
/dev/nvme0n1p1 vfat      197M   64M  134M  33% /efi
```

### Partition layout for this guide
We're going for the following layout:
```txt
DEVICE            MOUNTPOINT    FS       SIZE/NOTE
/dev/nvme0n1p1    /boot         FAT32    300M (ESP)
/dev/nvme0n1p2    /             XFS      40G-80G
/dev/nvme0n1p3    /home         XFS      Remainder of the disk (minus SWAP if needed)
```

### Setup
Steps to partition your disk:
- `fdisk /dev/nvme0n1`
- Press `p` to print your current partition table
- Press `m` to list available commands
- Press `g` to create a new partition table
- Press `n` to start creating a new partition
- Press `Return` to accept default partition number 1
- Press `Return` to accept default First Sector
- Enter `+300M` to make the partition 300MB.
- If asked to remove signature Press `y`
- Press `t` to change partition type
- Enter `1` for the partition type, this tells the firmware that this is an EFI system partition (ESP)
- Repeat for the remaining positions. Where you entered `1` before, enter `24` for `/`, `28` for `/home` and `19` for the swap partition. HINT: You can type `+100G` to make a 100GB partition

Press `w` to write your changed to disk, fdisk will ask to confirm your changes and still let you quit without writing anything if you've messed up entering the partition data. After fdisk has exited, run `lsblk` to confirm that what you did was actually correct. If need be, you can start over.

lsblk should report something like
- /dev/nvme0n1p1
- /dev/nvme0n1p2
- /dev/nvme0n1p3
- /dev/nvme0n1p4 (optional, swap)

### Formatting
Before you can use the partitions you set up, you have to format them.

- `mkfs.fat -F32 /dev/nvme0n1p1`
- `mkfs.xfs /dev/nvme0n1p2`
- `mkfs.xfs /dev/nvme0n1p3`
- `mkswap /dev/nvme0n1p4` (optional)

### Mounting
This is how we want to mount the partitions:
- /dev/nvme0n1p1 -> /mnt/efi
- /dev/nvme0n1p2 -> /mnt
- /dev/nvme0n1p3 -> /mnt/home

You can accomplish this by running the following commands in order:
- `mount /dev/nvme0n1p2 /mnt`
- `mkdir /mnt/efi`
- `mount /dev/nvme0n1p1 /mnt/efi`
- `mkdir /mnt/home`
- `mount /dev/nvme0n1p3 /mnt/home`

You can confirm if the commands have succeded 

`mount`

This should yield a result similar to the following:
```txt
/dev/nvme0n1p2 on /mnt type xfs (rw,relatime,stripe=32547,data=ordered)
/dev/nvme0n1p1 on /mnt/efi type vfat (rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,utf8,errors=remount-ro)
/dev/nvme0n1p3 on /mnt/home type xfs (rw,relatime,stripe=32606,data=ordered)
```

## Setting up the system
Now we're ready to actually start installing Arch!

### Select the mirrors

Packages to be installed must be downloaded from mirror servers, which are defined in `/etc/pacman.d/mirrorlist`. On the live system, all mirrors are enabled, and sorted by their synchronization status and speed at the time the installation image was created.

The higher a mirror is placed in the list, the more priority it is given when downloading a package. You may want to edit the file accordingly, and move the geographically closest mirrors to the top of the list, although other criteria should be taken into account.

This file will later be copied to the new system by pacstrap, so it is worth getting right. 

##### Note:
>I use reflector to accomplish this task.
>
>Install reflector 
>- `pacman -Sy reflector`
>
>Sort mirrors by score and write 20 mirrors to /etc/pacman.d/mirrorlist 
>- `reflector --score 20 --save /etc/pacman.d/mirrorlist`
>
>If you prefer, you can limit mirrors to a specific country with 
>- `reflector -c 'United States' 20 --save /etc/pacman.d/mirrorlist`

[More reading](https://wiki.archlinux.org/index.php/Reflector)


##### Note:
>Since this is a live system, the mirrorlist will not pesist through reboots on the live media, it will however write this as the mirrorlist on your installed system.


### Bootstrapping the system
Bootstrapping is the process of installing the base packages needed for a functioning system
-  pacstrap is Arch's bootstrapping system, it will download and install all of the packages you put after the pacstrap command
- `pacstrap /mnt base base-devel linux linux-firmware fwupd man-db man-pages texinfo networkmanager plasma plasma-wayland-session konsole sddm sddm-kcm vim reflector networkmanager-qt`
-  That will take a while, the next command will generate a File System Table, the -p is default behavior and avoids printing psuedofs mounts, its here for completeness, the -U is so that the fstab uses UUID and we are going to write to /mnt/etc/fstab with the `>`
- `genfstab -pU /mnt > /mnt/etc/fstab`
-  chroot will gain you root access to you shiny new system, you are changing root from the live media to the mounts you just created
- `arch-chroot /mnt`

You can omit everything past networkmanager in the `pacstrap` command if you want different packages, these are just my prefered applications.  [More reading](https://wiki.archlinux.org/index.php/Installation_guide#Install_essential_packages)

**Congratulations**, you've now installed Arch on your hard drive and you're technically 'booted' into it!

## Installing Processor Microcode
### Microcode
Processor manufacturers release stability and security updates to the processor microcode. These updates provide bug fixes that can be critical to the stability of your system. Without them, you may experience spurious crashes or unexpected system halts that can be difficult to track down.

All users with an AMD or Intel CPU should install the microcode updates to ensure system stability.

Microcode updates are usually shipped with the motherboard's firmware and applied during firmware initialization. Since OEMs might not release firmware updates in a timely fashion and old systems do not get new firmware updates at all, the ability to apply CPU microcode updates during boot was added to the Linux kernel. The Linux microcode loader supports three loading methods:

* **Early loading** updates the microcode very early during boot, before the initramfs stage, so it is the preferred method. This is mandatory for CPUs with severe hardware bugs, like the Intel Haswell and Broadwell processor families. (This is the method we will use)

* **Late loading** updates the microcode after booting which could be too late since the CPU might have already tried to use a bugged instruction set. Even if already using early loading, late loading can still be used to apply a newer microcode update without needing to reboot.

* **Built-in microcode** can be compiled into the kernel that is then applied by the early loader.

#### Install the microcode
Determine what processor you have

`lscpu`

If Intel

`pacman -Sy intel-ucode` 

If AMD 

`pacman -Sy amd-ucode`

## Installing the boot loader
I personally recommend choosing between either SystemD-boot or GRUB. GRUB is commonly used and you are going to find a lot of help online like [Arch Wiki GRUB](https://wiki.archlinux.org/index.php/GRUB), therefore I will leave this topic for a later date.

### SystemD-boot
SystemD-boot comes installed with Arch. You just have to run 

`bootctl --path=/efi install`

to install it into your EFI partition.

##### Note:
>If you get a warning or error about not being able to set EFI variables, you'll have to install the `efivar` 
and `efibootmgr` packages.
>
> `pacman -Sy efivar efibootmgr`
>
>This will allow bootctl to tell your motherboard firmware where its boot image is located

Now we will bind mount our /boot to /efi/EFI/arch

`mkdir /efi/EFI/arch`
`vim /etc/fstab`

Now we're getting into vim.
- Press ESC to make sure you are in NORMAL mode
- Type`//efi` and press ENTER the first / is a regex search
- Press `Shift+A` to enter INSERT mode at the end of the line
- Press ENTER twice to get some space
- Type `/efi/EFI/arch    /boot    none    defaults,bind    0 0`
- Press ESC to return to NORMAL mode
- Type `:wq` to write and quit

For a full explanation visit [Arch Wiki Systemd-boot](https://wiki.archlinux.org/index.php/Systemd-boot)

#### Creating a new boot entry
The easiest way of getting the boot entry file correct in the terminal is through vim. Vim does not come with Arch, so you're going to have to install it if you didn't include it with your `pacstrap`. Run `pacman -S vim`

We will create a boot entry file at `/efi/loader/entries/arch.conf` 

`vim /efi/loader/entries/arch.conf`

More vim goodness.
- Press ESC to make sure you are in NORMAL mode
- Type `:r !blkid` to run the `blkid` command and print its output into the file
- We want to copy the UUID for our root partition, which should be at `/dev/nvme0n1p2`
- Type `/nvme0n1p2` to jump to the line which has the UUID for our root partition
- Exit to NORMAL mode by pressing ENTER 
- Type `vi"` to enter VISUAL mode and highlight everything between the quotes
- Press `y` to copy the UUID
- Using your arrow keys, move your cursor to the first line in the file and press `p` to paste the UUID
- Press `Shift+A` to enter INSERT mode at the end of the line
- Press ENTER a few times to get some space
- Press ESC to return to NORMAL mode
- Type `vapd` to enter VISUAL mode, highlight the block of text from blank-line to blank-line and delete it.
- Now enter INSERT mode by pressing `i` and edit the file to look like the example below. Typing `:wq` will write your changes and exit vim.

```txt
title Arch Linux
linux /EFI/arch/vmlinuz-linux-lts
initrd /intel-ucode.img
initrd /EFI/arch/initramfs-linux-lts.img
options root=UUID="THE_UUID_YOU_COPIED" rw quiet splash
```
##### Note:
>The `/` in `/vmlinuz-linux /*-ucode.img /initramfs-linux.img` is in reference to the ESP, on our system that is `/efi`.  
>If you `ls /efi` the files should be listed in that directory, otherwise your system will not boot.
>
>Replace `REPLACEME` with `intel` or `amd`, depending on your processor and the ucode that you installed.
>
>Take note of the `root=UUID=` and `""` in `options root=UUID="THE_UUID_YOU_COPIED"` line

#### Setting the default boot entry
Open an editor to edit `/efi/loader/loader.conf`.

`vim /efi/loader/loader.conf`

The file should look like the snippet below before you save it.
```txt
timeout 3
default arch
editor no
```

## Enable Services
Enable the GUI

`systemctl enable sddm`

Enable networkmanager

`systemctl enable NetworkManager`

Congratulations, NetworkManager is now enabled. You should not have to mess with networking from this point on. If you experience issues reconnecting you can use `nmtui` (The NetworkManager Text User Interface).

## Set a Root password
Set a root password 

`passwd` 

then enter your super secret password twice.

## Adding a user
I will add an administrator account that is not root. You have to enable the wheel group. You do this by uncommenting the line in `/etc/sudoers` where the wheel group is defined. 

Edit `/etc/sudoers` through `visudo` (Never edit `/etc/sudoers` directly, it'll get you in trouble!).

`EDITOR=vim visudo`
- Make sure you're in NORMAL mode by pressing `ESC`.
- Type `/#%whe` then press `Enter`
- Press `i` to enter INSERT mode
- Press `del` to delete the `#`
- Press `esc` to enter NORMAL mode
- Type `:wq` to write changes and quit

The result should look like this.
```txt
## Uncomment to allow members of group wheel to execute any command
%wheel ALL=(ALL) ALL
```

Add the user account.

`useradd -m -G wheel your_username`

Set a password for your user account.

`passwd your_username`

#### Select timezone
By running the `tzselect` command, you are dropped into a basic utility which lets you choose your timezone. 

Select your desired timezone and remember its exact name. 

You'll want to make this change permanent by running 

- `timedatectl set-timezone 'Europe/Amsterdam'`, where `Europe/Amsterdam` is the timezone you selected.

- `timedatectl set-ntp true`

#### Set up hardware clock
Setting up the hardware clock is extremely straightforward.

- `hwclock --systohc --utc`

### Setting your locale
GNU/Linux supports multiple languages and locales. You need your locale to be set up correctly for the system to function correctly (in the desired language).

#### Language settings
Start of by editing `etc/locale.gen` 

`vim /etc/locale.gen`. 

Uncomment the languages you want your system to be able to support. 
##### Note:
>Remember the **_exact_** name of the locale you want to be your main locale, you're going to need that in a bit.

Now you've configured the supported locales, its time to generate them. 

`locale-gen` 

You'll also want to set a system wide locale.

`localectl set-locale LANG="en_US.UTF-8"`

Where `en_US.UTF8` is the locale you want.

**Congratulations, you have installed Arch the Arch way!!**

Exit the chroot environment

`exit`

Shutdown your computer.

`poweroff`

Now is the time to remove your installation media and turn your computer back on.

##### Note:
>If anything fails at this point, you can always reboot to the live media, mount your partitions in the same order as earlier and correct the problems.

## Configure basic system settings
When you boot up your computer now, you should be greeted by the boot loader you've installed and you should be be presented with an sddm log in screen! Log in with your username and password. From here on, you'll be logging in as a regular user. For most of the setup you want to run commands as `sudo`.

From here on out, commands will either have a dollar sign or a hash in front of it. Commands prefixed with a hash have to be run as root, commands prefixed with a dollar sign have to be run as a regular user.

## Connect to a Network
You can use the networkmanager-qt applet in the system tray if you installed it during bootstrapping.

### Swapfile
If you haven't set up a swap partition earlier, it might be helpful to set up a swap file instead. Swap is used instead of RAM when RAM is (getting) full. It more or less prevents your system from completely crashing when your memory fills up. If you don't think you'll need this, you can skip this step.

Commands for setting up a swapfile:
```sh
# fallocate -l 2G /swapfile
# chmod 600 /swapfile
# mkswap /swapfile
# vim /etc/fstab
```
Add a new file system entry

`/swapfile none swap defaults 0 0`
```sh
# vim /etc/sysctl.d/99-sysctl.conf
```
- Add or change this line

`vm.swappiness=10`

### Edit pacman settings
Edit `/etc/pacman.conf` 
```sh
# vim /etc/pacman.conf
```

You'll probably want to uncomment the `multilib` section for 32-bit library support. You'll need 32 bit libraries for some applications.

You can enable color by uncommenting `Color` under `Misc options`. 

### Finishing up
You're almost done with this section. Run 
```sh
# pacman -Syyu
```
to sync the pacman repositories and 
```sh
# reboot
```
to reboot the system.

#### Note: 
>When you are installing software later on in this process, if pacman cannot find packages, your repositories may have updated while you were installing software. You can fix this by resynchronising your pacman databases 
with:
```sh
# pacman -Syy
```
>All parts of the guide beyond this point are to make your system more enjoyable.

### Installing graphics drivers
You're going to need a graphics driver specific to your graphics card. Listed below are major GPU vendors and their associated driver packages.

- AMD
	- xf86-video-amdgpu
	- xf86-video-ati (older cards only)
- Intel
	- xf86-video-intel
- nVidia
	- xf86-video-nouveau
	- nvidia (properietary)

#### Not sure which card(s) you have?

You can run the following command to run all of the cards installed in your system. If you have multiple graphics card installed, for example if you have a laptop with two GPUs, you'll want to install the driver for every card.
```sh
lspci -k | grep -A 2 -E "(VGA|3D)"
```

#### Decision time for nVidia users

There are two sets of drivers, the open-source drivers and the proprietary drivers. You should install either one of the drivers, but not both. The proprietary drivers generally perform better, but there's also this Stallman guy who says they're evil.

Install the packages with `pacman` and you're on your way. nVidia drivers as an example.
```sh
# pacman -Sy nvidia 
```
If you have hybrid graphics scroll down to [Installing an AUR helper](#user-content-installing-an-aur-helper) and complete that, then come back. 
```sh
$ yay -Sy optimus-manager optimus-manager-qt
# systemctl enable optimus-manager
# systemctl start optimus-manager
```
Use below commands to switch graphics:
```sh
$ optimus-manager --switch intel    # Use Intel graphics
$ optimus-manager --switch nvidia   # Use NVIDIA graphics
$ optimus-manager --switch hybrid   # Use hybrid graphics (Requires a patch to xorg-server)
$ optimus-manager --switch auto     # Switch to different graphics (from what is used now)
```
Also specify which graphics to use on boot:
```sh
$ optimus-manager --set-startup intel
$ optimus-manager --set-startup nvidia
$ optimus-manager --set-startup hybrid   # Use hybrid graphics (Requires a patch to xorg-server)
```

### Audio
Install `alsa-utils`. This package provides basic management tools for ALSA (Advanced Linux Sound Architecture)
```sh
# pacman -S alsa-utils
```

To start off, you should unmute your system before you start meddling with audio. By default, audio is muted.
```sh
$ amixer sset Master unmute
```

Pulseaudio is the sound server supported by most applications and it tends to work pretty well. If it is not already installed, install it now.
```sh
# pacman -S pulseaudio pulseaudio-alsa pavucontrol
```

`pavucontrol` is one of the better pulseaudio volume mixers, it is way better than most audio widgets and settings panels included with most desktop environments.

### Extra security
Now you have a GUI, you can open a terminal and lock password access to the root account. The command for this is `sudo passwd -l root`, if you do this you will not be able to log in as root.

#### Installing a firewall
Its good staying secure. Installing a firewall helps with this.
```sh
# pacman -S firewalld
# systemctl enable firewalld
# systemctl start firewalld
```
The `firewalld` package also contains a nifty system tray applet `firewall-applet`. You can add it to your desktop startup if you want to be notified of firewall changes or have a quick shortcut to your firewall settings.

### Printers
Sometimes you just gotta go old school!
``` 
# pacman -S cups cups-filters cups-pdf ghostscript gsfonts foomatic-db-engine foomatic-db foomatic-db-ppds foomatic-db-nonfree foomatic-db-nonfree-ppds gutenprint foomatic-db-gutenprint-ppds system-config-printer print-manager --needed
# systemctl start org.cups.cupsd.socket
# systemctl enable org.cups.cupsd.socket
# systemctl start avahi-daemon
# systemctl enable avahi-daemon
```

### Installing an alternative desktop environment
The guide installs KDE in the `pacstrap` command, but if you would prefer, below are most of the popular desktop environments and their associated packages.  We installed Wayland in this guide also, but you may prefer the X Window Manager for your desktop.  Visit the link for information on each of these [Desktop Environments](https://wiki.archlinux.org/index.php/Desktop_environment)

- XFCE
	- xfce4
	- xfce4-goodies
- GNOME
	- gnome
	- gnome-extra
- Cinnamon
	- cinnamon
- MATE
	- mate
	- mate-extra
- LXDE
	- lxde
- LXQt
	- lxqt

##### Note: 
>For the GTK-based desktops (XFCE, GNOME, Cinnamon, MATE and LXDE), you'll want to install `gvfs` alongside the desktop to get wastebasket and mounting support for regular users. Install `gvfs-mtp` as well if you're planning to connect your Android phone.

XFCE as an example
```sh
# pacman -S xfce4 xfce4-goodies gvfs
```

### Changing the Display Manager
We installed sddm with `pacstrap`, however if you change DE's...

You don't _need_ a display manager, but most normal people want a nice shiny clicky thing when their computer boots up. Desktop environments should be paired with an appropriate display manager. Below is a list of pairings. LightDM generally works well with every desktop environment, except for KDE.

- XFCE
	- lightdm
	- gdm
- GNOME
	- gdm
	- lightdm
- LXDE
	- lightdm
- LXQt
	- sddm

Here's an example for installing LightDM. LightDM is also the special one in the bunch because you have to install the greeter seperately.
```sh
# pacman -S lightdm
# pacman -S lightdm-gtk-greeter lightdm-gtk-greeter-settings
```

To enable your display manager you just run. Substitute lightdm with the display manager you've installed.
```sh
# systemctl enable lightdm
```

Side-note: I personally prefer GDM over LightDM in combination with XFCE. LightDM does pretty badly out of the box with multi-monitor setups when you have to connect your computer to a bunch of random monitors. GDM still does a mediocre job, but it works better.

### XDG directories
With some desktop environments you might notice that there are no folders named like Documents, Desktop, Music, etc. If you make them yourself you might also notice that your file manager does not recognise them as folders that contain music or videos or whatever. You can fix this by installing the `# pacman -Sy xdg-user-dirs` package and running `$ xdg-user-dirs-update`. You might want to log out and back in again if your software does not immediately respond to the change.

### Terminal tools
Arch Linux by default does _not_ include some of the nicer and more useful commandline tools. You're going to have to install them yourself. Here are a few that I find mandatory.
- `aria2` CLI Download Manager
- `uGet` Frontend for curl and aria2
- `wget` Download web content
- `curl` Download web content to stdout
- `git`  Download files from the AUR and GitHub

### Installing an AUR helper
The AUR is a pretty awesome perk of running Arch, it contains a lot of user provided software in all flavours. However, it kind of sucks without an AUR helper. I prefer to use `yay`, after `pacaur` was deprecated. So this is the AUR helper I'll show you how to install. I've heard good things about `trizen` as well. You can always install that alongside `yay` to find out what you like.

For starters, you're going to need `git` to download AUR packages, so start off by installing git.
```sh
# pacman -S git
```

You should have a folder to store your loose AUR packages, go make one! I prefer to store mine in my downloads folder. After that you'll want to clone the yay git repository.
```sh
$ mkdir -p ~/Downloads/aur && cd ~/Downloads/aur
$ git clone https://aur.archlinux.org/yay.git
$ cd yay
```
After that you'll want to build and install the package.
```sh
$ makepkg -sric
```
When you've got yay installed, installing other AUR packages becomes quite simple.
```sh
$ yay -Sy package_name
```
Return to [Hybrid Graphics](#user-content-decision-time-for-nvidia-users)

### ZSH
ZSH is another shell, like bash or sh, with some added functunality, its better with add ons like oh-my-zsh installed. This section will show you how to get ZSH with a set of fancy themes.

First off, start by installing zsh
```sh
# pacman -S zsh
```

Then install oh-my-zsh!
```sh
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```
Oh my zsh automatically switches your shell, but its better to just re-open the terminal. You can switch themes by editing `~/.zshrc`.

### Steam
Playing games is a boatload of fun. Steam is proprietary (and popular!), it is trusted by a lot of users and it makes installing and managing games easy. However it needs some help to get going. You should start off by installing Steam.
```sh
# pacman -S steam steam-native-runtime
```
You'll notice that the command installs `steam-native-runtime` as well. By default Steam runs on an Ubuntu runtime. It 'works' on Arch, but it runs and looks like garbage. After you've installed steam, you'll either want to edit the Steam launcher to use the native runtime, or create a new launcher. The launcher should run `/usr/bin/steam-native %U`.

### Working with Smartcards (CAC)
In order to login to US Goverment sites you need a CAC Reader and DOD Certificates (I use firefox for accessing this)
```sh
# pacman -S pcsc-tools opensc ccid firefox ark
# systemctl enable pcscd
# systemctl start pcscd
```
In firefox
- Click on the hamburger menu then `Preferences > Privacy & Security`
- Scroll to the bottom of the page and click on `Security Devices`
- Click on `Load`
- Enter `/usr/lib/pkcs11/opensc-pkcs11.so` in the `Module filename` field
- Click `OK`
- In a New Tab, Navigate to `https://public.cyber.mil/pki-pke/end-users/getting-started/`
- Download and Extract the `certificates_pkcs**_dod.zip` file
- On the `Preferences > Privacy & Security` Tab, Click `View Certificates`
- Click `Import`
- Navigate to the folder that you just extracted and install each cert in turn

You should now have a working CAC Reader

