#!/bin/bash

prayers="$HOME/.local/share/prayers.json"
kill_cmd="kill -1 \$(ps aux | grep qatami | awk 'FNR==1{print \$2}')"

# WARNING: THIS SCRIPTS REMOVES ALL JOBS IN QUEUE "P" SCHEDULED USING AT
# ADJUST ACCORDINGLY
echo "-- removing all jobs in queue 'p'"
if [[ "$(at -q p -l | wc -l)" != "0" ]]; then
	for i in $(at -q p -l | awk '{ print $1 }'); do
		atrm "$i"
	done
fi

day_idx=$(($(date +%-d) - 1))

declare -A ptimes
ptimes["Fajr"]=$(date -d "$(jq -r ".data[$day_idx].timings.Fajr" "$prayers")" '+%H:%M %F')
ptimes["Dhuhr"]=$(date -d "$(jq -r ".data[$day_idx].timings.Dhuhr" "$prayers")" '+%H:%M %F')
ptimes["Asr"]=$(date -d "$(jq -r ".data[$day_idx].timings.Asr" "$prayers")" '+%H:%M %F')
ptimes["Maghrib"]=$(date -d "$(jq -r ".data[$day_idx].timings.Maghrib" "$prayers")" '+%H:%M %F')
ptimes["Isha"]=$(date -d "$(jq -r ".data[$day_idx].timings.Isha" "$prayers")" '+%H:%M %F')

for prayer in "${!ptimes[@]}"; do
	echo "-- creating at job for $prayer prayer"
	printf '[ "$(dunstify --icon="clock-applet-symbolic" --action="Reply,reply" "Prayer Times" "It is time for %s prayer 🕌" -t 30000)" = "2" ] && %s' "$prayer" "$kill_cmd" | at -q p "${ptimes[$prayer]}"
done
