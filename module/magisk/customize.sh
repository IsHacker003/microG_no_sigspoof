gms_dir=system/product/priv-app/GmsCoreMG
gms_path=$gms_dir/GmsCoreMG.apk

source "$MODPATH/common.sh"

remove_package_updates google

echo
echo "[P] Processing files to remove..."
echo "-------------------------------------------"
echo "[M] FILE/DIR                         STATUS"
echo "-------------------------------------------"
for file in $remove_files; do
	printf "%-40s %s\n" "[I] .../$(basename "$file")" "OK"
	mkdir -p "$(dirname "$MODPATH/$file")"
	mknod "$MODPATH/$file" c 0 0
done
echo "-------------------------------------------"
echo "[I] Done processing files."

echo
echo "[P] Extracting libraries..."
unzip -q -o "$MODPATH/$gms_path" 'lib/*' -d "$MODPATH/$gms_dir"
[ ! -d "$MODPATH/$gms_dir/lib/arm64-v8a" ] || mv "$MODPATH/$gms_dir/lib/arm64-v8a" "$MODPATH/$gms_dir/lib/arm64"
[ ! -d "$MODPATH/$gms_dir/lib/armeabi-v7a" ] || mv "$MODPATH/$gms_dir/lib/armeabi-v7a" "$MODPATH/$gms_dir/lib/arm"
[ ! -d "$MODPATH/$gms_dir/lib/x86_64" ] || mv "$MODPATH/$gms_dir/lib/x86_64" "$MODPATH/$gms_dir/lib/x64"
echo "-------------------------------------------"
echo "[M] FILE                             STATUS"
echo "-------------------------------------------"
if [ -d "$MODPATH/$gms_dir/lib/$ARCH" ]; then
	find "$MODPATH/$gms_dir/lib/$ARCH" -type f | while read -r file; do
		printf "%-40s %s\n" "[I] $(basename "$file")" "OK"
	done
else
	echo "[W] No native libraries found for $ARCH"
fi
echo "-------------------------------------------"
echo "[I] Done extracting libraries."
echo
echo "============================================"
echo "[W] If this is a fresh installation (not update),"
echo "after reboot, click Action to grant permissions."
echo "============================================"
