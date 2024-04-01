#!/bin/bash

prayers=("Fajr" "Dhuhr" "Asr" "Maghrib" "Isha")
prayers_json="$HOME/.local/share/prayers.json"
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
for prayer in "${prayers[@]}"; do
	echo "-- creating at job for $prayer prayer"
	ptime=$(date -d "$(jq -r ".data[$day_idx].timings.$prayer" "$prayers_json")" '+%H:%M %F')
	printf '[ "$(dunstify --icon="clock-applet-symbolic" --action="Reply,reply" "Prayer Times" "It is time for %s prayer 🕌" -t 30000)" = "2" ] && %s' "$prayer" "$kill_cmd" | at -q p "$ptime"
done
