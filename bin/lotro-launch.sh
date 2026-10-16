#!/bin/bash
env > /tmp/lotro-launch-env.log

LOTRO_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/lotro/lotro.env"
# shellcheck source=/dev/null
[ -f "$LOTRO_CONF" ] && . "$LOTRO_CONF"
if [ -z "${LOTRO_USERNAME:-}" ]; then
    notify-send "LOTRO Launch Failed" "LOTRO_USERNAME not set in $LOTRO_CONF"
    echo "LOTRO_USERNAME not set in $LOTRO_CONF" >&2
    exit 1
fi

LOTRO_PASS=$(secret-tool lookup service lotro username "$LOTRO_USERNAME" 2>/tmp/lotro-secret-tool.err)
if [ -z "$LOTRO_PASS" ]; then
    notify-send "LOTRO Launch Failed" "Could not retrieve password from secret-tool"
    echo "Failed to retrieve LOTRO password from secret-tool" >&2
    exit 1
fi
exec "$@" -nosplash -username "$LOTRO_USERNAME" -password "$LOTRO_PASS"
