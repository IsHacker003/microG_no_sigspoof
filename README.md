**NOTE:** Currently, I'm **NOT** working on this project, as I'm busy and I don't have devices to test it on. Expect the Magisk module to have bugs. Android 16 is **NOT** supported, it will cause bootloop. I will only provide updates when a new version of microG is released, no other changes will be made. I will resume development when I'm free.

# MicroG Installer (no signature spoofing)
Install [microG](https://microg.org), even if your ROM doesn't support [signature spoofing](https://github.com/microg/GmsCore/wiki/Signature-Spoofing)!

The Magisk module can replace the core Google services already included in a stock ROM. You no longer need to remove GApps manually before installing it.

## Installer features

1. Does not require signature spoofing, Xposed, or framework patches
2. Replaces Google Play Services, Play Store, and Google Services Framework through a systemless Magisk overlay
3. Removes conflicting Google package updates during installation while preserving microG updates
4. Uses the modern `system/product` module layout and extracts GmsCore native libraries for the current device architecture
5. Includes a Magisk Action script that repairs runtime, app-op, and hard-restricted permissions for the active Android user
6. Supports both systemless and non-systemless installation; the recovery package remains experimental

## How does it work?

The microG APKs used are signed* using Google's official signature for Google Play Services and Play Store, thus eliminating the need to "spoof" the signature. This is done with the `apksigcopier` tool.

The signature blocks, which were extracted from the official, untampered Google Play Store and Google Play Services APKs, can be found in [sigs/signatures-google](https://github.com/IsHacker003/microg_no_sigspoof/tree/master/sigs/signatures-google).

*It isn't actually "signed" using those keys, if you look into how `apksigcopier` works, you will find that it just copies the binary signature block from one apk to another, without extracting the private key itself. As a result, these microG apks CANNOT be installed as user apps, as they fail signature verification. (Had to add this explanation because people on Reddit are a bit too ignorant)

The Magisk package installs the patched APKs under `system/product/priv-app`, masks conflicting stock GApps directories, adds the required permission and sysconfig files, and extracts the GmsCore native libraries during installation. Its Action script uses a small Java-to-DEX helper to allowlist hard-restricted permissions before granting them.

## Building

**Prerequisites:** `apksigcopier`, `wget`, `zip`, JDK 8 or newer, Android SDK Platform 35, and Android SDK Build Tools 36.0.0 (`zipalign` and `d8`).

1. Clone this repo:

   ```bash
   git clone https://github.com/IsHacker003/microg_no_sigspoof && cd microg_no_sigspoof
   ```

2. Build Magisk module:

   ```bash
   make module-magisk
   ```

3. Build recovery-flashable zip:

   ```bash
   make module-recovery
   ```

To build individual APKs (these **cannot** be installed as user apps):

```bash
make android-package
```

To safely remove generated APKs, ZIPs, the permission-helper build directory, and populated module application directories:

```bash
make clean
```

During every build, the Makefile resolves the current latest GmsCore release through the GitHub API and downloads the matching GMSCore and Companion assets. GSFProxy uses its `releases/latest/download` URL. The downloaded APKs are then patched with the stored signatures. Generated APK, ZIP, and DEX files are intentionally excluded from Git.

## Installation

1. Remove or disable other microG/GApps replacement Magisk modules.
2. Install `microG-nosigspoof-systemless.zip` through Magisk, KernelSU, or APatch.
3. Reboot the device.
4. Open the module manager and run this module's **Action** once.
5. Open microG Settings and confirm that the Self-Check items and required permissions are enabled.

The Action script preserves installed microG user updates, removes conflicting Google updates, targets the active Android user, allowlists `ACCESS_BACKGROUND_LOCATION` and `RECEIVE_SMS`, and then grants the supported runtime permissions. `SYSTEM_ALERT_WINDOW` is handled through AppOps.

## Download

1. Systemless (Magisk/KernelSU/Apatch module): [microG-nosigspoof-systemless.zip](https://github.com/IsHacker003/microg_no_sigspoof/releases/latest/download/microG-nosigspoof-systemless.zip)

~~2. Non-systemless (Recovery-flashable zip, supports all modern custom recoveries such as TWRP, OrangeFox, etc.): [microG-nosigspoof-recovery.zip](https://github.com/IsHacker003/microg_no_sigspoof/releases/latest/download/microG-nosigspoof-recovery.zip)~~ (Not stable yet)

3. Manual installation (APK):
   <br>[microG GMSCore](https://github.com/IsHacker003/microg_no_sigspoof/releases/latest/download/GmsCore.apk)
   <br>[microG Companion](https://github.com/IsHacker003/microg_no_sigspoof/releases/latest/download/Phonesky.apk)
   <br>[microG GSFProxy](https://github.com/IsHacker003/microg_no_sigspoof/releases/latest/download/GsfProxy.apk)
<br>(The APKs can only be installed as system apps)

## Why did I make this?
The first reason is obvious: while installing microG, the step where most beginners face problems is enabling signature spoofing. So, why keep something which causes problems? With microG_no_sigspoof, you can just flash a single zip file to have a fully working microG setup!

And....

To enable signature spoofing even with root, you need Xposed, which most people don't want to install. microG_no_sigspoof is also useful for creating stock roms with microG preinstalled, because all "signature spoofing patchers" have now become outdated. So it's virtually impossible to create a stock rom with microG preinstalled and working unless you get rid of the signature spoofing requirement completely. Moreover signature spoofing creates vulnerabilities in the device, and this is why some people refuse to install microG in the first place by saying it's "insecure". And of course it's still way more convenient to be able to install microG by flashing a single zip, even if you are willing to install Xposed.


## Credits

1. microG developers (for microG)
2. obfusk (for apksigcopier)
3. ale500 (for fixing bootloop issues related to permissions and contributing to this repo in general)
4. [SelfRef/noogle-magisk](https://github.com/SelfRef/noogle-magisk) (for the modern Magisk module structure and installation scripts)
5. me (for the module)

## Future plans

1. Add Android 16 support after it can be tested safely
2. Optionally install other FOSS apps such as Aurora Store and F-droid

## License

```
microG_no_SigSpoof: Install microG without signature spoofing!

Copyright (C) 2025  IsHacker

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
```
