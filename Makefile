ANDROID_SDK_ROOT ?= $(HOME)/Library/Android/sdk
ANDROID_PLATFORM ?= android-35
ANDROID_BUILD_TOOLS ?= 36.0.0
ANDROID_JAR ?= $(ANDROID_SDK_ROOT)/platforms/$(ANDROID_PLATFORM)/android.jar
D8 ?= $(ANDROID_SDK_ROOT)/build-tools/$(ANDROID_BUILD_TOOLS)/d8
PERMISSION_HELPER_BUILD_DIR ?= .build/restricted-permission-tool

.PHONY: permission-helper
permission-helper:
	rm -rf $(PERMISSION_HELPER_BUILD_DIR)
	mkdir -p $(PERMISSION_HELPER_BUILD_DIR)/classes $(PERMISSION_HELPER_BUILD_DIR)/dex
	javac -source 8 -target 8 -cp $(ANDROID_JAR) \
		-d $(PERMISSION_HELPER_BUILD_DIR)/classes tools/RestrictedPermissionTool.java
	jar cf $(PERMISSION_HELPER_BUILD_DIR)/restricted-permission-tool-java.jar \
		-C $(PERMISSION_HELPER_BUILD_DIR)/classes .
	$(D8) --min-api 29 --output $(PERMISSION_HELPER_BUILD_DIR)/dex \
		$(PERMISSION_HELPER_BUILD_DIR)/restricted-permission-tool-java.jar
	cp $(PERMISSION_HELPER_BUILD_DIR)/dex/classes.dex \
		module/magisk/restricted-permission-tool.jar

module-magisk: permission-helper download-apks
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
	mkdir -p module/magisk/system/product/priv-app/GmsCoreMG
	mkdir -p module/magisk/system/product/priv-app/PhoneskyMG
	mkdir -p module/magisk/system/product/priv-app/GoogleServicesFrameworkMG
	cp apks/GmsCore.apk module/magisk/system/product/priv-app/GmsCoreMG/GmsCoreMG.apk
	cp apks/Phonesky.apk module/magisk/system/product/priv-app/PhoneskyMG/PhoneskyMG.apk
	cp apks/GsfProxy.apk module/magisk/system/product/priv-app/GoogleServicesFrameworkMG/GoogleServicesFrameworkMG.apk
	cd module/magisk && zip -r -9 microG-nosigspoof-systemless.zip * && mv microG-nosigspoof-systemless.zip ../..
	rm apks/*
	@echo "Done! Now install microG-nosigspoof-systemless.zip as a Magisk module on your phone."

module-recovery: download-apks
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
	mkdir -p module/recovery/system/priv-app/GmsCore
	mkdir -p module/recovery/system/priv-app/Phonesky
	mkdir -p module/recovery/system/priv-app/GsfProxy
	cp apks/GmsCore.apk module/recovery/system/priv-app/GmsCore
	cp apks/Phonesky.apk module/recovery/system/priv-app/Phonesky
	cp apks/GsfProxy.apk module/recovery/system/priv-app/GsfProxy
	cd module/recovery && zip -r -9 microG-nosigspoof-recovery.zip * && mv microG-nosigspoof-recovery.zip ../..
	rm apks/*
	@echo "Done! Now flash microG-nosigspoof-recovery.zip through a custom recovery on your phone."

.PHONY: clean
clean:
	rm -f microG-nosigspoof-recovery.zip microG-nosigspoof-systemless.zip
	rm -f GmsCore.apk Phonesky.apk GsfProxy.apk apks/*.apk
	rm -rf module/magisk/system/product/priv-app module/magisk/system/priv-app
	rm -rf module/recovery/system/priv-app
	rm -rf $(PERMISSION_HELPER_BUILD_DIR)

android-package: download-apks
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

.PHONY: download-apks
download-apks:
	@set -eu; \
	release_json="$$(wget -qO- https://api.github.com/repos/microg/GmsCore/releases/latest)"; \
	phonesky_url="$$(printf '%s\n' "$$release_json" | sed -n 's/.*"browser_download_url": "\(https:[^"]*\/com\.android\.vending-[0-9][0-9]*\.apk\)".*/\1/p')"; \
	gmscore_url="$$(printf '%s\n' "$$release_json" | sed -n 's/.*"browser_download_url": "\(https:[^"]*\/com\.google\.android\.gms-[0-9][0-9]*\.apk\)".*/\1/p')"; \
	test -n "$$phonesky_url"; \
	test -n "$$gmscore_url"; \
	wget -O apks/Phonesky_o.apk "$$phonesky_url"; \
	wget -O apks/GmsCore_o.apk "$$gmscore_url"; \
	wget -O apks/GsfProxy.apk https://github.com/microg/GsfProxy/releases/latest/download/GsfProxy.apk
