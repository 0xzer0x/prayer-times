#!/bin/bash

yad_pid=$(xprop _NET_WM_PID -name Prayers 2>/dev/null | awk '{print $3}')

if [[ -z "$yad_pid" ]]; then
	yad --no-buttons --text "<span font-size='large'>$($HOME/.local/bin/prayers.sh)</span>" --title "Prayers"
else
	kill $yad_pid
fi
