module-magisk:
	cp apks/GmsCore.apk module/magisk/system/priv-app/GmsCore
	cp apks/Phonesky.apk module/magisk/system/priv-app/Phonesky
	cp apks/GsfProxy.apk module/magisk/system/priv-app/GsfProxy
	cd module/magisk && zip -r -9 microG-nosigspoof-systemless.zip * && mv microG-nosigspoof-systemless.zip ../..
	@echo "Done! Now install microG-nosigspoof-systemless.zip as a Magisk module on your phone."

module-recovery:
	cp apks/GmsCore.apk module/recovery/system/priv-app/GmsCore
	cp apks/Phonesky.apk module/recovery/system/priv-app/Phonesky
	cp apks/GsfProxy.apk module/recovery/system/priv-app/GsfProxy
	cd module/recovery && zip -r -9 microG-nosigspoof-recovery.zip * && mv microG-nosigspoof-recovery.zip ../..
	@echo "Done! Now flash microG-nosigspoof-recovery.zip through a custom recovery on your phone."
