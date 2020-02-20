# Arch Linux installation guide on 2017 Dell-XPS 15 core i5
Hi there, this is a guide to install Arch Linux on your computer. I have adapted this guide from BrinkerVII on GitHub for my Nvme laptop that does not like ext4.  I install Plasma w/sddm, WiFi, 

This guide is reference material for myself, as well as for other people who would like to install Arch for the first time.

**General notes**
* This guide does assume that you are somewhat of a technically savvy user. (Hopefully this disclaimer can go away!)
* Have fun! Breaking stuff is part of the process and there's always a way to fix it. Don't be afraid :)

**Thank-you**

Thank you to BrinkerVII brinkervii@gmail.com for writing this guide.
Thanks to the wonderful people on the [Linux Masterrace subreddit](https://www.reddit.com/r/linuxmasterrace/comments/8j1dlb/i_wrote_an_arch_installation_guide_what_do_you/) for reviewing BrinkerVII's version of this guide.
Thank you to everyone on the arch wiki https://wiki.archlinux.org for the amazing information, this is an excellent resouce for learning linux.

## Pre-installation

The installation media and their GnuPG signatures can be acquired from the https://archlinux.org/download/ page.

### Verify signature

It is recommended to verify the image signature before use, especially when downloading from an HTTP mirror, where downloads are generally prone to be intercepted to serve malicious images.

On a system with GnuPG installed, do this by downloading the PGP signature (under Checksums) to the ISO directory, and verifying it with:

`$ gpg --keyserver-options auto-key-retrieve --verify archlinux-version-x86_64.iso.sig`

Alternatively, from an existing Arch Linux installation run:

`$ pacman-key -v archlinux-version-x86_64.iso.sig`


##### Note:
```txt
    The signature itself could be manipulated if it is downloaded from a mirror site,
    instead of from https://archlinux.org/download/ as above. In this case, ensure that the public key, 
    which is used to decode the signature, is signed by another, trustworthy key. The 
    gpg command will output the fingerprint of the public key. Another method to verify 
    the authenticity of the signature is to ensure that the public key's fingerprint is 
    identical to the key fingerprint of the https://www.archlinux.org/people/developers/ who signed the 
    ISO-file. See https://en.wikipedia.org/wiki/Public-key_cryptography for more information on the 
    public-key process to authenticate keys.
```

## Boot the live environment

The live environment can be booted from a USB flash drive, an optical disc or a network with PXE. For an alternative means of installation, see https://wiki.archlinux.org/index.php/Category:Installation_process

##### Note:
```txt
    Pointing the current boot device to a drive containing the Arch installation media is typically 
    achieved by pressing a key during the POST phase, as indicated on the splash screen. Refer to 
    your motherboard's manual for details. When the Arch menu appears, select Boot Arch Linux and 
    press Enter to enter the installation environment. See README.bootparams for a list of boot 
    parameters, and packages.x86_64 for a list of included packages. You will be logged in on the 
    first virtual console as the root user, and presented with a Zsh shell prompt.
```
To switch to a different console (e.g. to view this guide with ELinks alongside the installation) use the Alt+arrow shortcut. 

# The Guide
Let's get rolling!

### Network Config
Assuming our wireless network was `network` and our passphrase was `passphrase`

Start the dhcp client with `systemctl start dhcpd`

Find your wireless interface with `ip link` *probably wlp2s0 or wlan0*

Connect to your wireless network
`wpa_supplicant -B -i <interface> -c <(wpa_passphrase network 'passphrase')`
*if your passphrase is complex, don't forget the single quotes*

Make sure you recieved an ip address `ip addr`

Test Connectivity `ping archlinux.org`

### Pull up this guide in another tty 

`pacman -S elinks`

`ctrl-alt-F2`

`https://github.com/Bluscrn/arch_install/blob/master/ARCH_INSTALLATION_GUIDE.md`

### System clock
Your system clock has to be accurate for the setup to work properly. Synchronise the clock with the following command.
```sh
timedatectl set-ntp true
```
Additionally, you can verify the clock status with the `timedatectl status` and `date` commands.

## Partitioning
We're assuming that the drive we're installing on is /dev/nvme0n1. Of course, you should check which drive you want to install to. `lsblk` Helps you identify disks easily.

NOTE: If you're installing in BIOS/MBR mode, you want to use fdisk instead of gdisk and always follow the GRUB path for the boot loader.

### Before you start partitioning
Your partition table is not something you can just change on a whim if you change your mind or if you find out you messed up. This guide comes with a partitioning scheme which is pretty flexible.

If you don't trust my partition scheme or just want something else, you should read the following paragraphs before you start partitioning

#### Your root partition
Your root partition is also the root of your Linux file system tree. This guide has you install your system into this partition (/usr, /lib, /var, /etc, ...). If you follow my partitioning scheme you should make this partition large enough to fit all of the stuff you're going to install. My root partition is 80GiB in size and 32GiB of that is currently in use. I have quite a lot of packages installed including a bunch of large IDE packages. If you are already running another GNU/Linux distribution, you should check how much space your system files are using and use that as a base line. If you're not running a GNU/Linux distribution or are unfamiliar with the ecosystem, its probably better to go with my upper bound of 80GiB.

#### The boot partition
It is not necessary to have your boot files in a separate partition if you're not using full disk encryption. However, having a separate boot partition allows you to add on recovery tools later on. So if you really break your system, you always have something to fall back on.

The not necessary rule only works for non-EFI setups though, if you're running in EFI mode you need an ESP partition. Ubuntu based distributions mount the ESP partition inside `/boot` at `/boot/efi`, but I find this to be quite messy. Not only that, it is incompatible with SystemD-boot.

#### The home partition
The home partition is another partition which is not required to be its own partition. However, having it separate allows you to mount this partition when or if you decide to boot into another distribution and still have all your documents and settings in the right place. This partition should also be plenty big if you're going to use Steam. Steam likes to install all of your games into your home folder if you do not change the defaults.

If you decide to skip making a separate home partition, you should make your root partition fill the rest of your disk outside of your boot and swap partitions.

#### The swap partition
Linux uses a swap file or a swap partition for when it runs out of memory for applications. Before the Linux kernel gained support for swap files, it was commonplace to create a swap partition. You can skip making a swap partition and use a swapfile instead. The benefit of this is that a swap file is more flexible than a swap partition, you can change the size of a swap file at any time.

The size of your swap partition or swap file depends on what you want to do with your computer. If you want to be able to use the hibernate functionality, your swap partition or file should at least be the size of your system memory. When you hibernate your computer, Linux uses the swap space to store the contents of your memory. If the swap space isn't big enough, things will go badly.

You can always be a rebel and run without swap space, but don't be surprised when the OOM killer comes around the corner and running applications start disappearing (the enormous stuttering will be a dead giveaway that you're running out of memory when you don't have any swap space).

#### File system types
This guide uses xfs for the root and home partitions. The ESP partition _has_ to be FAT32.

You can choose to use other filesystems if you want to, but beware that you can't change your file system without deleting all the files stored on the partition. So changing file systems may be quite the chore if you run into problems with the file system you chose. If you do not know anything about different file systems or do not want to research about the subject and want to get going, just stick with xfs.

### Partition layout for this guide
We're going for the following layout:
```txt
DEVICE       MOUNTPOINT    FS       SIZE/NOTE
/dev/nvme0n1p1    /boot         FAT32    300M (ESP)
/dev/nvme0n1p2    /             XFS     40G-80G
/dev/nvme0n1p3    /home         XFS     Remainder of the disk (minus SWAP)
```

### Setup
Steps to partition your disk:
- Run `fdisk /dev/nvme0n1`
- Press `g` to create a new partition table
- Press `n` to start creating a new partition
- Press `Return` to accept default partition number 1
- Press `Return` to accept default First Sector
- Press `t` to change partition type
- Enter `ef` for the partition type, this tells the firmware that this is an EFI system partition (ESP)
- Press enter to confirm the partition start
- Enter `+300M` to make the partition 300MB.
- Repeat for the remaining positions. Where you entered `ef` before, enter `8300` for `/`, `8302` for `/home` and `8200` for the swap partition. HINT: You can type `+100G` to make a 100GB partition

Press `w` to write your changed to disk. gdisk/fdisk will ask to confirm your changes and still let you quit without writing anything if you've messed up entering the partition data. After gdisk has exited, run `lsblk` to confirm that what you did was actually correct. If need be, you can repeat setting up your partitions with gdisk.

lsblk should report something along the lines of:
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

You can confirm if you've ran the commands correctly by running the `mount` command without any arguments. This should yield a result similar to the following:
```sh
/dev/nvme0n1p2 on /mnt type xfs (rw,relatime,stripe=32547,data=ordered)
/dev/nvme0n1p1 on /mnt/efi type vfat (rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,utf8,errors=remount-ro)
/dev/nvme0n1p3 on /mnt/home type xfs (rw,relatime,stripe=32606,data=ordered)
```

## Setting up the system
Now we're ready to actually start installing Arch!

### Select the mirrors

Packages to be installed must be downloaded from mirror servers, which are defined in /etc/pacman.d/mirrorlist. On the live system, all mirrors are enabled, and sorted by their synchronization status and speed at the time the installation image was created.

The higher a mirror is placed in the list, the more priority it is given when downloading a package. You may want to edit the file accordingly, and move the geographically closest mirrors to the top of the list, although other criteria should be taken into account.

This file will later be copied to the new system by pacstrap, so it is worth getting right. 

I use reflector to accomplish this task.

Install reflector `pacman -Sy reflector`

Sort mirrors by score and write 10 mirrors to /etc/pacman.d/mirrorlist `reflector --score 10`


##### Note:
```txt
Since this is a live system, the mirrorlist will not pesist through reboots on the live media, it will 
however write this as the mirrorlist on your installed system.
```

## Bootstrapping the system
Bootstrapping the system is fairly easy. You just have to run the following commands:
- `pacstrap /mnt base base-devel linux linux-headers plasma plasma-wayland-session sddm sddm-kcm vim reflector NetworkManager NetworkManager-qt fwupd man-db man-pages texinfo`
- `genfstab -pU /mnt > /mnt/etc/fstab`
- `arch-chroot /mnt`

Congratulations, you've now installed Arch on your hard drive and you're technically 'booted' into it!

## Installing Processor Microcode
### Microcode
Processor manufacturers release stability and security updates to the processor microcode. These updates provide bug fixes that can be critical to the stability of your system. Without them, you may experience spurious crashes or unexpected system halts that can be difficult to track down.

All users with an AMD or Intel CPU should install the microcode updates to ensure system stability.

Microcode updates are usually shipped with the motherboard's firmware and applied during firmware initialization. Since OEMs might not release firmware updates in a timely fashion and old systems do not get new firmware updates at all, the ability to apply CPU microcode updates during boot was added to the Linux kernel. The Linux microcode loader supports three loading methods:

* Early loading updates the microcode very early during boot, before the initramfs stage, so it is the preferred method. This is mandatory for CPUs with severe hardware bugs, like the Intel Haswell and Broadwell processor families. (This is the method we will use)

* Late loading updates the microcode after booting which could be too late since the CPU might have already tried to use a bugged instruction set. Even if already using early loading, late loading can still be used to apply a newer microcode update without needing to reboot.

* Built-in microcode can be compiled into the kernel that is then applied by the early loader.

#### Install the microcode
`pacman -Sy intel-ucode` or `pacman -Sy amd-ucode`

## Installing the boot loader
I personally recommend choosing between either GRUB or SystemD-boot. GRUB is fairly commonly used and you're probably going to find a lot of help online like https://wiki.archlinux.org/index.php/GRUB. SystemD-boot comes included with SystemD, Arch uses SystemD as its init system.

### SystemD-boot
SystemD-boot comes installed with Arch. You just have to run `bootctl --path=/efi install` to install it into your EFI partition.

For a full explanation visit https://wiki.archlinux.org/index.php/Systemd-boot

##### Side-note:
```txt
If you get a warning or error about not being able to set EFI variables, you'll have to install the `efivar` 
and `efibootmgr` packages `pacman -S efivar efibootmgr`. This will allow bootctl to tell your motherboard 
firmware where its boot image is located
```

#### Creating a new boot entry
The easiest way of getting the boot entry file correct in the terminal is through vim. Vim does not come with Arch, so you're going to have to install it if you didn't include it with your `pacstrap`. Run `pacman -S vim`

We will create a boot entry file at /efi/loader/entries/arch.conf so run `vim /efi/loader/entries/arch.conf` to create a file at that location.

Now we're getting into vim magic.
- Make sure you're in normal mode by pressing `ESC`.
- Then type `:r !blkid` to run the `blkid` command and get its output.
- We want to copy the UUID for our root partition, which should be at `/dev/nvme0n1p2`. Type `/nvme0n1p2` to jump to the line which has the UUID for our root partition.
- Exit to normal mode by pressing `enter`. Now type `vi"` to select the UUID for the partition. Yes that is correct, you actually have to type the `"`.
- Now press `y` to copy the UUID.
- Move your cursor to the top of the file and press `p` to paste the UUID onto the first line.
- Now enter insert mode at the end of the line by typing `A` (capitalisation matters!)
- Add some newlines after it by pressing enter, we want the UUID to be separated from the rest of the blkid command output.
- Exit to normal mode by pressing ESC and move your cursor over the blkid command output.
- Type `vapd` to get rid of it all.
- Now enter insert mode by pressing `i` and edit the file to look like the example below. Typing `:wq` will write your changes and exit vim.

```txt
title Arch Linux
linux /vmlinuz-linux
initrd /`cpu_manufacturer`-ucode.img
initrd /initramfs-linux.img
options root=UUID=`THE_UUID_YOU_COPIED` rw quiet splash
```

#### Setting the default boot entry
Open an editor to edit `/efi/loader/loader.conf`. Run `vim /efi/loader/loader.conf` The file should look like the snippet below before you save it.
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
Set a root password by typing `passwd` then entering your password twice.

## Add your user
I will add an administrator account that is not root. You have to enable the wheel group. You do this by uncommenting the line in `/etc/sudoers` where the wheel group is defined. Edit `/etc/sudoers` through `visudo` with the following command (Never edit `/etc/sudoers` directly, it'll get you in trouble!).

`EDITOR=vim visudo`
- Make sure you're in normal mode by pressing `ESC`.
- Type `/#%whe` then press `Enter`
- Press `i` to enter insert mode
- Press `del` to delete the `#`
- Press `esc` to enter normal mode
- Type `:wq` to write changes and quit

The result should look like this.
```txt
## Uncomment to allow members of group wheel to execute any command
%wheel ALL=(ALL) ALL
```

Add your user by running the following command.
```sh
useradd -m -G wheel your_username
```

After that is done, you'll want to set a password for you user account. You do this by running the following.
```sh
passwd your_username
```
#### Select timezone
By running the `tzselect` command, you are dropped into a basic utility which lets you choose your timezone. 

Select your desired timezone and remember its exact name. 

You'll want to make this change permanent by running 

`timedatectl set-timezone 'Europe/Amsterdam'`, where `Europe/Amsterdam` is the timezone you selected.

#### Set up hardware clock
Setting up the hardware clock and network clock synchronisation is extremely straightforward. Just run these commands.

- `hwclock --systohc --utc`

### Setting your locale
GNU/Linux supports multiple languages and locales. You need your locale to be set up correctly for the system to function correctly (in the desired language).

#### Language settings
Start of by editing `etc/locale.gen` `vim /etc/locale.gen`. 

Uncomment the languages you want your system to be able to support. Remember the _exact_ name of the locale you want to be your main locale, you're going to need that in a bit.

Now you've configured the supported locales, its time to generate them. Run `locale-gen` to generate your locales. You'll also want to set a system wide locale.
```sh
localectl set-locale LANG="en_US.UTF-8"
```
Where `en_US.UTF8` is the locale you want.

**You're now done setting up your Arch base system. Run `exit` to exit the chroot environment and then `poweroff` to shut down your computer. Now is the time to remove your installation media.**

## Configure basic system settings
When you boot up your computer now, you should be greeted by the boot loader you've installed and you should be be presented with an sddm log in screen! Log in with your username and password. From here on, you'll be logging in as a regular user. For most of the setup you want to run commands as `sudo`.

From here on out, commands will either have a dollar sign or a hash in front of it. Commands prefixed with a hash have to be run as root, commands prefixed with a dollar sign have to be run as a regular user.

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

Enable colour by uncommenting `Color` under `Misc options`. 

You'll also want to uncomment the `multilib` section for 32-bit library support. You'll need 32 bit libraries for some applications.

### Finishing up
You're almost done with this section. Run 
```sh
# pacman -Sy
```
to sync the pacman repositories and 
```sh
# reboot
```
to reboot the system.

#### Side-note: 
```txt
When you're installing software later on in the process and pacman cannot find packages X, Y and Z, you repositories 
probably have updated while you were installing software. You can fix this by resynchronising your pacman databases 
with:
```
```sh
# pacman -Syy
```
All the parts of the guide beyond this point are mostly 'fluff' to make your system nicer.

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

**Not sure which card(s) you have?**

You can run the following command to run all of the cards installed in your system. If you have multiple graphics card installed, for example if you have a laptop with two GPUs, you'll want to install the driver for every card.
```sh
lspci -k | grep -A 2 -E "(VGA|3D)"
```

**Decision time for nVidia users**

There are two sets of drivers, the open-source drivers and the proprietary drivers. You should install either one of the drivers, but not both. The proprietary drivers generally perform better, but there's also this Stallman guy who says they're evil.

Install the packages with `pacman` and you're on your way. nVidia drivers as an example.
```sh
# pacman -Sy nvidia 
```
If you have hybrid graphics scroll down to the Installing an AUR helper section and do that, then come back. 
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
$ optimus-manager --switch hybrid   # Use hybrid graphics (Requires a patch to xorg-server)
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
Now you have a GUI, you can open a terminal and lock password access on the root account. The command for this is `sudo passwd -l root`.

### Printers
``` 
# pacman -S cups cups-filters cups-pdf ghostscript gsfonts foomatic-db-engine foomatic-db foomatic-db-ppds foomatic-db-nonfree foomatic-db-nonfree-ppds gutenprint foomatic-db-gutenprint-ppds system-config-printer print-manager --needed
# systemctl start org.cups.cupsd.socket
# systemctl enable org.cups.cupsd.socket
# systemctl start avahi-daemon
# systemctl enable avahi-daemon
```

### Installing an alternative desktop environment
The guide installs KDE in the `pacstrap` command, but if you would prefer, below are most of the popular desktop environments and their associated packages.  We also do not install X in this guide but the instructions are listed for each of these DE's at 

- XFCE
	- xfce4
	- xfce4-goodies
- GNOME
	- gnome
	- gnome-extra
- KDE
	- plasma
	- kde-applications
- Cinnamon
	- cinnamon
- MATE
	- mate
	- mate-extra
- LXDE
	- lxde
- LXQt
	- lxqt

Side-note: For the GTK-based desktops (XFCE, GNOME, Cinnamon, MATE and LXDE), you'll want to install `gvfs` alongside the desktop to get wastebasket and mounting support for regular users. Install `gvfs-mtp` as well if you're planning to connect your Android phone.

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
- KDE
	- sddm
- LXDE
	- lightdm
- LXQt
	- sddm

Here's an example for installing LightDM. LightDM is also the special one in the bunch because you have to install the so called greeter seperately.
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
With some desktop environments you might notice that there are no folders named like Documents, Desktop, Music, etc. If you make them yourself you might also notice that your file manager does not recognise them as folders that contain music or videos or whatever. You can fix this by installing the `xdg-user-dirs` package and running `$ xdg-user-dirs-update`. You might want to log out and back in again if your software does not immediately respond to the change.

### Terminal tools
Arch Linux by default does _not_ include some of the nicer and more useful commandline tools. You're going to have to install them yourself. Here's some I like to have. (List might not be complete)
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

### ZSH
ZSH is an awesome shell, its even more awesome with packages like oh-my-zsh installed. This section will show you how to get ZSH with a set of fancy themes.

First off, start by installing zsh
```sh
# pacman -S zsh
```

Then install oh-my-zsh!
```sh
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```
Oh my zsh automatically switches your shell, but its better to just re-open the terminal. You can switch themes by editing `~/.zshrc`.

### Installing a firewall
Its good staying secure. Installing a firewall ensures that no other machines are allowed to connect to random software on your machine they're not supposed to connect to. I prefer `firewalld`, its meant for corporate environments, I like its flexibility and strict default policies. Installation is easy.
```sh
# pacman -S firewalld
# systemctl enable firewalld
# systemctl start firewalld
```
The `firewalld` package also contains a nifty system tray applet `firewall-applet`. You can add it to your desktop startup if you want to be notified of firewall changes or have a quick shortcut to your firewall settings.

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

