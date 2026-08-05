remove_files="
/system/product/priv-app/GmsCore
/system/product/priv-app/PrebuiltGmsCore
/system/product/priv-app/GoogleServicesFramework
/system/product/priv-app/Phonesky
/system/system_ext/priv-app/GoogleServicesFramework
/system/product/etc/permissions/split-permissions-google.xml
"

microg_package="com.google.android.gms"
restricted_permissions="ACCESS_BACKGROUND_LOCATION RECEIVE_SMS"

get_current_user_id() {
	user_id=$(am get-current-user 2>/dev/null)
	case "$user_id" in
		''|*[!0-9]*) user_id=0 ;;
	esac
	printf '%s\n' "$user_id"
}

permission_is_granted() {
	package=${1}
	permission=${2}
	user_id=${3}

	if [ "$permission" = "SYSTEM_ALERT_WINDOW" ]; then
		appop_state=$(cmd appops get --user "$user_id" "$package" \
			SYSTEM_ALERT_WINDOW 2>/dev/null)
		case "$appop_state" in
			*"SYSTEM_ALERT_WINDOW: allow"*) return 0 ;;
		esac

		if [ "$user_id" = "0" ]; then
			dumpsys package "$package" 2>/dev/null |
				grep -Eq '^[[:space:]]*android.permission.SYSTEM_ALERT_WINDOW: granted=true$'
		else
			dumpsys package "$package" 2>/dev/null |
				grep -Fq "android.permission.SYSTEM_ALERT_WINDOW: granted=true, userId=$user_id"
		fi
		return
	fi

	dumpsys package "$package" 2>/dev/null |
		sed -n "/^[[:space:]]*User $user_id:/,/^[[:space:]]*User [0-9][0-9]*:/p" |
		grep -Fq "android.permission.$permission: granted=true"
}

grant_microg_permission() {
	permission=${1}
	user_id=${2}

	if [ "$permission" = "SYSTEM_ALERT_WINDOW" ]; then
		cmd appops set --user "$user_id" "$microg_package" \
			SYSTEM_ALERT_WINDOW allow >/dev/null 2>&1
	else
		pm grant --user "$user_id" "$microg_package" \
			"android.permission.$permission" >/dev/null 2>&1
	fi
}

allowlist_restricted_permission() {
	permission=${1}
	user_id=${2}
	module_dir=${MODULE_DIR:-$MODPATH}
	helper="$module_dir/restricted-permission-tool.jar"

	if [ ! -r "$helper" ]; then
		echo "[W] Restricted-permission helper not found: $helper"
		return 1
	fi

	CLASSPATH="$helper" app_process / RestrictedPermissionTool \
		add "$microg_package" "android.permission.$permission" "$user_id" >/dev/null
}

prepare_restricted_permissions() {
	user_id=${1}
	echo "[P] Allowlisting restricted permissions for user $user_id..."
	for permission in $restricted_permissions; do
		printf "%-40s" "[I] $permission"
		if allowlist_restricted_permission "$permission" "$user_id"; then
			echo "SYSTEM ALLOWLISTED"
		else
			echo "FAILED"
		fi
	done
}

remove_package_updates() {
	filter=${1}
	echo "[P] Checking package updates..."
	echo "-------------------------------------------"
	echo "[M] PACKAGE WITH UPDATE                TYPE"
	echo "-------------------------------------------"
	packages="com.google.android.gms com.android.vending com.google.android.gsf"
	for package in $packages; do
		path=$(pm path "$package" | grep "/data/app/" | sed -E 's/package:(\/data\/app\/[^/]+).*/\1/' | uniq)
		microg_type=$(pm dump "$package" | grep -q 'FAKE_PACKAGE_SIGNATURE' && echo "true" || echo "false")
		if [ -n "$path" ]; then
			if [ "$microg_type" = "true" ]; then
				if [ "$filter" = "google" ]; then
					printf "%-32s %s\n" "[I] $package" "MICROG, OK"
				else
					printf "%-36s %s\n" "[W] $package" "MICROG"
				fi
			else
				printf "%-36s %s\n" "[W] $package" "GOOGLE"
			fi

			if [ "$filter" != "google" ] || [ "$microg_type" != "true" ]; then
				echo -n "|-[P] Removing package update...    "
				pm uninstall -k --user all "$package"
			fi
		else
			printf "%-29s %s\n" "[I] $package" "NOT FOUND, OK"
		fi
	done
	echo "-------------------------------------------"
	echo "[I] Done checking package updates."
}

grant_microg_permissions() {
	permissions="ACCESS_COARSE_LOCATION ACCESS_FINE_LOCATION ACCESS_BACKGROUND_LOCATION READ_EXTERNAL_STORAGE WRITE_EXTERNAL_STORAGE GET_ACCOUNTS POST_NOTIFICATIONS READ_PHONE_STATE RECEIVE_SMS SYSTEM_ALERT_WINDOW"
	user_id=$(get_current_user_id)

	prepare_restricted_permissions "$user_id"
	echo
	echo "[P] Checking microG Services permissions..."
	echo "[I] Android user: $user_id"
	echo "-------------------------------------------"
	echo "[M] PERMISSION                       STATUS"
	echo "-------------------------------------------"

	warn=""

	for perm in $permissions; do
		if permission_is_granted "$microg_package" "$perm" "$user_id"; then
			printf "%-35s %s\n" "[I] $perm" "GRANTED"
		else
			printf "%-31s %s\n" "[W] $perm" "NOT GRANTED"
			echo -n "|-[P] Granting...                   "
			grant_microg_permission "$perm" "$user_id"
			if permission_is_granted "$microg_package" "$perm" "$user_id"; then
				echo "SUCCESS"
			else
				echo "FAILED"
				warn="true"
			fi
		fi
	done

	echo "-------------------------------------------"
	echo "[P] Checking microG Services permissions done."

	if [ "$warn" ]; then
		echo "[W] Some permissions were not granted."
		echo "[W] You can grant them from the microG app."
	else
		echo "[I] All permissions granted!"
	fi
}
