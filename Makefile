module-magisk:
	wget -O apks/Phonesky_o.apk https://github.com/microg/GmsCore/releases/download/v0.3.9.250932/com.android.vending-84022618.apk
	wget -O apks/GmsCore_o.apk https://github.com/microg/GmsCore/releases/download/v0.3.9.250932/com.google.android.gms-250932018.apk
	wget -O apks/GsfProxy.apk https://github.com/microg/GsfProxy/releases/download/v0.1.0/GsfProxy.apk
	zip -d apks/GmsCore_o.apk META-INF/MANIFEST.MF
	zip -d apks/GmsCore_o.apk META-INF/CERT.SF
	zip -d apks/GmsCore_o.apk META-INF/CERT.RSA
	zip -d apks/Phonesky_o.apk META-INF/MANIFEST.MF
	zip -d apks/Phonesky_o.apk META-INF/CERT.SF
	zip -d apks/Phonesky_o.apk META-INF/CERT.RSA
	zipalign -v 4 apks/Phonesky_o.apk apks/Phonesky_oz.apk
	zipalign -v 4 apks/GmsCore_o.apk apks/GmsCore_oz.apk
	apksigcopier patch sigs/signatures-google/phonesky apks/Phonesky_oz.apk apks/Phonesky.apk
	apksigcopier patch sigs/signatures-google/gms apks/GmsCore_oz.apk apks/GmsCore.apk
	mkdir module/magisk/system/priv-app
	mkdir module/magisk/system/priv-app/GmsCore
	mkdir module/magisk/system/priv-app/Phonesky
	mkdir module/magisk/system/priv-app/GsfProxy
	cp apks/GmsCore.apk module/magisk/system/priv-app/GmsCore
	cp apks/Phonesky.apk module/magisk/system/priv-app/Phonesky
	cp apks/GsfProxy.apk module/magisk/system/priv-app/GsfProxy
	cd module/magisk && zip -r -9 microG-nosigspoof-systemless.zip * && mv microG-nosigspoof-systemless.zip ../..
	rm apks/*
	@echo "Done! Now install microG-nosigspoof-systemless.zip as a Magisk module on your phone."

module-recovery:
	wget -O apks/Phonesky_o.apk https://github.com/microg/GmsCore/releases/download/v0.3.9.250932/com.android.vending-84022618.apk
	wget -O apks/GmsCore_o.apk https://github.com/microg/GmsCore/releases/download/v0.3.9.250932/com.google.android.gms-250932018.apk
	wget -O apks/GsfProxy.apk https://github.com/microg/GsfProxy/releases/download/v0.1.0/GsfProxy.apk
	zip -d apks/GmsCore_o.apk META-INF/MANIFEST.MF
	zip -d apks/GmsCore_o.apk META-INF/CERT.SF
	zip -d apks/GmsCore_o.apk META-INF/CERT.RSA
	zip -d apks/Phonesky_o.apk META-INF/MANIFEST.MF
	zip -d apks/Phonesky_o.apk META-INF/CERT.SF
	zip -d apks/Phonesky_o.apk META-INF/CERT.RSA
	zipalign -v 4 apks/Phonesky_o.apk apks/Phonesky_oz.apk
	zipalign -v 4 apks/GmsCore_o.apk apks/GmsCore_oz.apk
	apksigcopier patch sigs/signatures-google/phonesky apks/Phonesky_oz.apk apks/Phonesky.apk
	apksigcopier patch sigs/signatures-google/gms apks/GmsCore_oz.apk apks/GmsCore.apk
	mkdir module/recovery/system/priv-app
	mkdir module/recovery/system/priv-app/GmsCore
	mkdir module/recovery/system/priv-app/Phonesky
	mkdir module/recovery/system/priv-app/GsfProxy
	cp apks/GmsCore.apk module/recovery/system/priv-app/GmsCore
	cp apks/Phonesky.apk module/recovery/system/priv-app/Phonesky
	cp apks/GsfProxy.apk module/recovery/system/priv-app/GsfProxy
	cd module/recovery && zip -r -9 microG-nosigspoof-recovery.zip * && mv microG-nosigspoof-recovery.zip ../..
	rm apks/*
	@echo "Done! Now flash microG-nosigspoof-recovery.zip through a custom recovery on your phone."

clean:
	@if [ -e microG-nosigspoof-recovery.zip ]; then\
		rm microG-nosigspoof-recovery.zip;\
	fi
	@if [ -e microG-nosigspoof-systemless.zip ]; then\
		rm microG-nosigspoof-systemless.zip; \
	fi
	@if [ -e module/magisk/system/priv-app ]; then\
		rm -rf module/magisk/system/priv-app; \
	fi
	@if [ -e module/recovery/system/priv-app ]; then\
		rm -rf module/recovery/system/priv-app; \
	fi

android-package:
	wget -O apks/Phonesky_o.apk https://github.com/microg/GmsCore/releases/download/v0.3.9.250932/com.android.vending-84022618.apk
	wget -O apks/GmsCore_o.apk https://github.com/microg/GmsCore/releases/download/v0.3.9.250932/com.google.android.gms-250932018.apk
	wget -O apks/GsfProxy.apk https://github.com/microg/GsfProxy/releases/download/v0.1.0/GsfProxy.apk
	zip -d apks/GmsCore_o.apk META-INF/MANIFEST.MF
	zip -d apks/GmsCore_o.apk META-INF/CERT.SF
	zip -d apks/GmsCore_o.apk META-INF/CERT.RSA
	zip -d apks/Phonesky_o.apk META-INF/MANIFEST.MF
	zip -d apks/Phonesky_o.apk META-INF/CERT.SF
	zip -d apks/Phonesky_o.apk META-INF/CERT.RSA
	zipalign -v 4 apks/Phonesky_o.apk apks/Phonesky_oz.apk
	zipalign -v 4 apks/GmsCore_o.apk apks/GmsCore_oz.apk
	apksigcopier patch sigs/signatures-google/phonesky apks/Phonesky_oz.apk apks/Phonesky.apk
	apksigcopier patch sigs/signatures-google/gms apks/GmsCore_oz.apk apks/GmsCore.apk
	mv apks/GmsCore.apk .
	mv apks/Phonesky.apk .
	mv apks/GsfProxy.apk .
	@echo "APKs successfully generated!"
	rm apks/*
