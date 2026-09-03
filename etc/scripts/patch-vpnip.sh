#!/bin/sh
[ "$(id -u)" -eq 0 ] || exec sudo "$0" "$@"
S=/usr/share/kali-themes/xfce4-panel-genmon-vpnip.sh
patch -b -l -F3 "$S" <<'EOF'
--- a
+++ b
@@ -3 +3,2 @@
-[ -z "$interface" ] && interface="$(ip tuntap show | cut -d : -f1 | head -n 1)"
+[ -z "$interface" ] && interface="$(ip -o link show up \
+        | awk '/link\/none/ {sub(/:$/,"",$2); print $2; exit}')"
EOF
