#!/bin/bash

prayers=("Fajr" "Dhuhr" "Asr" "Maghrib" "Isha")
prayers_json="$HOME/.local/share/prayers.json"
current_month=$(date +%-m)
current_year=$(date +%Y)
# ----- Parameters ------ #
# Coordinates: https://www.mapcoordinates.net/en
lat='30.001780'
long='31.290419'
# Calculation Method: https://api.aladhan.com/v1/methods
method="5"

check() {
	if [[ -r $prayers_json ]]; then
		available_month=$(jq -r ".data[0].date.gregorian.month.number" "$prayers_json")
	else
		fetch_prayers=1
	fi

	if [[ "$fetch_prayers" || "$available_month" != "$current_month" ]]; then
		echo "-- fetching current month ($current_month) prayer calendar"
		# Documentation: https://aladhan.com/prayer-times-api#GetCalendar
		wget -O "$prayers_json" "http://api.aladhan.com/v1/calendar/$current_year/$current_month?latitude=$lat&longitude=$long&method=$method"
	fi
}

add-jobs() {
	kill_cmd="kill -1 \$(ps aux | grep qatami | awk 'FNR==1{print \$2}')"

	# WARNING: THIS SCRIPTS REMOVES ALL JOBS IN QUEUE "P" SCHEDULED USING AT (ADJUST ACCORDINGLY)
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
}

case "$1" in
check)
	check
	;;
jobs)
	add-jobs
	;;
*)
	check
	add-jobs
	;;
esac
