#!/bin/sh

if [[ -z "$(pgrep yad)" ]]; then
	yad --no-buttons --text "<span font-size='large'>$($HOME/.local/bin/prayers.sh)</span>" --title "Prayers"
else
	killall yad
fi
