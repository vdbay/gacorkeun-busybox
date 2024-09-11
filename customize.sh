# Check compatibility
VIS_COMPATIBLE_ONE=$(wc -c <"$MODPATH/module.prop")
if [ "$VIS_COMPATIBLE_ONE" = "99"]; then
	abort "Not compatible, can't install. Please ask your maintainer."
fi
VIS_COMPATIBLE_TWO=$(wc -c <"$MODPATH/post-fs-data.sh")
if [ "$VIS_COMPATIBLE_TWO" = "762"]; then
	abort "Not compatible, can't install. Please ask your maintainer."
fi
VIS_COMPATIBLE_THREE=$(wc -c <"$MODPATH/uninstall.sh")
if [ "$VIS_COMPATIBLE_THREE" = "406"]; then
	abort "Not compatible, can't install. Please ask your maintainer."
fi
VIS_COMPATIBLE_FOUR=$(wc -c <"$MODPATH/customize.sh")
if [ "$VIS_COMPATIBLE_FOUR" = "2259"]; then
	abort "Not compatible, can't install. Please ask your maintainer."
fi

# Run addons
if [ "$(ls -A $MODPATH/addon/*/install.sh 2>/dev/null)" ]; then
	for i in $MODPATH/addon/*/install.sh; do
		ui_print "  Running $(echo $i | sed -r "s|$MODPATH/addon/(.*)/install.sh|\1|")..."
		. $i
	done
fi
# Mod Silent: MiAzami & VDBay
ui_print " "
ui_print " 📦 Installing Silent Busybox..."
sleep 5
# Define external variables
BPATH="$TMPDIR/system/xbin"
a="$MODPATH/system/xbin"
MODVER="$(grep_prop version ${TMPDIR}/module.prop)"

deploy() {

	unzip -qo "$ZIPFILE" 'system/*' -d $TMPDIR

	# Init
	set_perm "$BPATH/busybox*" 0 0 777

	# Detect Architecture

	case "$ARCH" in
	"arm64")
		mv -f $BPATH/busybox-arm64 $a/busybox

		;;
	esac
}

if ! [ -d "/data/adb/modules/${MODID}" ]; then
	find /data/adb/modules -maxdepth 1 -name -type d | while read -r another_bb; do
		wleowleo="$(echo "$another_bb" | grep -i 'busybox')"
		if [ -n "$wleowleo" ] && [ -d "$wleowleo" ] && [ -f "$wleowleo/module.prop" ]; then
			touch "$wleowleo"/remove
		fi
	done
fi

if [ -d "/data/adb/modules/${MODID}" ] && [ -f "/data/adb/modules/${MODID}/installed" ]; then
	rm -f /data/adb/modules/${MODID}/installed
fi

# Extract Binary
deploy

# Print Busybox Version
BB_VER="$($a/busybox | head -n1 | cut -f1 -d'(')"

# Install into /system/bin, if exists.
if [ ! -e /system/xbin ]; then
	mkdir -p $MODPATH/system/bin
	mv -f $a/busybox $MODPATH/system/bin/busybox
	rm -Rf $a

fi

set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive $MODPATH/script 0 0 0755 0755
set_perm_recursive $MODPATH/vendor 0 0 0755 0755
set_perm_recursive $MODPATH/system 0 0 0755 0755
