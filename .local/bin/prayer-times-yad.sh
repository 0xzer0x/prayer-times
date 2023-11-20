#!/bin/bash

if [[ "$XDG_SESSION_TYPE" == "x11" ]]; then
  yad_pid=$(xprop _NET_WM_PID -name Prayers 2>/dev/null | awk '{print $3}')
else
  yad_pid=$(hyprctl clients | awk '/title: Prayers/ {found=1} found && $0 ~ /pid/ {print $2}')
fi

if [[ -z "$yad_pid" ]]; then
	yad --no-buttons --text "<span font-size='large'>$($HOME/.local/bin/prayers.sh)</span>" --title "Prayers"
else
	kill $yad_pid
fi
