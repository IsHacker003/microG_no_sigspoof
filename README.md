# MicroG Installer (no signature spoofing)
Install [microG](https://microg.org), even if your ROM doesn't support [signature spoofing](https://github.com/microg/GmsCore/wiki/Signature-Spoofing)!
<br><br>**NOTE**: You will need to remove GApps from your ROM first.
## Installer features:
1. No native code: only shell scripts and Makefile
2. Does not install unnecessary, extra apps
3. Supports both systemless and non-systemless installation
4. No modifications made to the ROM except for installing a few system apps
## How does it work?
The microG APKs used are signed using Google's official signature for Google Play Services and Play Store, thus eliminating the need to "spoof" the signature. It is done with the help of `apksigcopier` tool.

The signatures, which were extracted from the official, untampered Google Play Store and Google Play Services APKs, can be found in [sigs/signatures-google](https://github.com/IsHacker003/microg_no_sigspoof/tree/master/sigs/signatures-google).
## Building
<b>Pre-requisites</b>: `apksigcopier`, `wget`, `zipalign`
1. Clone this repo:
   ```
   git clone https://github.com/IsHacker003/microg_no_sigspoof && cd microg_no_sigspoof
   ```
2. Build Magisk module:
   ```
   make module-magisk
   ```
3. Build recovery-flashable zip:
   ```
   make module-recovery
   ```

To clean, just use `make clean`.
## Download
1. Systemless (Magisk/KernelSU/Apatch module): [microG-nosigspoof-systemless.zip
](https://github.com/IsHacker003/microg_no_sigspoof/releases/download/v1.0-prerelease/microG-nosigspoof-systemless.zip)
2. Non-systemless (Recovery-flashable zip, supports all modern custom recoveries such as TWRP, OrangeFox, etc.): [microG-nosigspoof-recovery.zip
](https://github.com/IsHacker003/microg_no_sigspoof/releases/download/v1.0-prerelease/microG-nosigspoof-recovery.zip)
3. Manual installation (APK):
   <br>[microG GMSCore](https://github.com/IsHacker003/microg_no_sigspoof/raw/refs/heads/master/apks/GmsCore.apk?download=)
   <br>[microG Companion](https://github.com/IsHacker003/microg_no_sigspoof/raw/refs/heads/master/apks/Phonesky.apk?download=)
   <br>[microG GSFProxy](https://github.com/IsHacker003/microg_no_sigspoof/raw/refs/heads/master/apks/GsfProxy.apk?download=)
<br>(The APKs can only be installed as system apps)

## Why did I make this?
The first reason is obvious: while installing microG, the step where most beginners face problems is enabling signature spoofing. So, why keep something which causes problems? With microg_no_sigspoof, you can just flash a single zip file to have a fully working microG setup!

And....

To enable signature spoofing even with root, you need Xposed, which most people don't want to install. microg_no_sigspoof is also useful for creating stock roms with microG preinstalled, because all "signature spoofing patchers" have now become outdated. So it's virtually impossible to create a stock rom with microG preinstalled and working unless you get rid of the signature spoofing requirement completely. Moreover signature spoofing creates vulnerabilities in the device, and this is why some people refuse to install microG in the first place by saying it's "insecure". And of course it's still way more convenient to be able to install microG by flashing a single zip, even if you are willing to install xposed.


## Future plans
1. Automatically remove all GApps while installing
2. Optionally install other FOSS apps such as Aurora Store and F-droid
