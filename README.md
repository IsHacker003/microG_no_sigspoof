# MicroG Installer (no signature spoofing)
Install [microG](https://microg.org), even if your ROM doesn't support signature spoofing!
**NOTE**: You will need to remove GApps from your ROM first.
## Installer features:
1. No native code: only shell scripts and Makefile
2. Does not install unnecessary, extra apps
3. Supports both systemless and non-systemless installation
4. No modifications made to the ROM except for installing a few system apps
## How does it work?
The microG APKs used are signed using Google's official signature for Google Play Services and Play Store, thus eliminating the need to "spoof" the signature. It is done with the help of `apksigcopier` tool.
## Building
1. Clone this repo: `git clone https://github.com/IsHacker003/microg_no_sigspoof && cd microg_no_sigspoof`
2. Build Magisk module: `make module-magisk`
3. Build recovery-flashable zip: `make module-recovery`

To clean, just use `make clean`.
