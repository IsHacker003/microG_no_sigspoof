#!/system/bin/sh

MODULE_DIR=${0%/*}
[ "$MODULE_DIR" != "$0" ] || MODULE_DIR=.
export MODULE_DIR

. "$MODULE_DIR/common.sh"

echo "[P] Module self-check..."

echo
remove_package_updates google

echo
echo
grant_microg_permissions

echo
echo
echo "[I] Done fixing module."
