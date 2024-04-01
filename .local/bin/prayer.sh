#!/bin/bash

nextprayer=""
currentprayer=""
prayers="$HOME/.local/share/prayers.json"

# Get the current time
currenttime=$(date +%s)
day=$(date +%a)
day_idx=$(($(date +%-d) - 1))

# Parsing the data for the five salawat
# use epoch seconds in order to calculate time difference
# date -d $(jq -r ".data[DAY - 1].timings.PRAYER" $prayers) +%s
fajr=$(date -d "$(jq -r ".data[$day_idx].timings.Fajr" "$prayers")" +%s)
dhuhr=$(date -d "$(jq -r ".data[$day_idx].timings.Dhuhr" "$prayers")" +%s)
asr=$(date -d "$(jq -r ".data[$day_idx].timings.Asr" "$prayers")" +%s)
maghrib=$(date -d "$(jq -r ".data[$day_idx].timings.Maghrib" "$prayers")" +%s)
isha=$(date -d "$(jq -r ".data[$day_idx].timings.Isha" "$prayers")" +%s)

if [[ "$currenttime" -ge "$fajr" && "$currenttime" -lt "$dhuhr" ]]; then
	nexttime=$dhuhr
	currentprayer="Fajr"
	if [[ "$day" == "Fri" ]]; then
		nextprayer="Jumuaa"
	else
		nextprayer="Dhuhr"
	fi

elif [[ $currenttime -ge $dhuhr && $currenttime -lt $asr ]]; then
	nexttime=$asr
	nextprayer="Asr"
	currentprayer="Dhuhr"

elif [[ $currenttime -ge $asr && $currenttime -lt $maghrib ]]; then
	nexttime=$maghrib
	nextprayer="Maghrib"
	currentprayer="Asr"

elif [[ $currenttime -ge $maghrib && $currenttime -lt $isha ]]; then
	nexttime=$isha
	nextprayer="Isha"
	currentprayer="Maghrib"

elif [[ $currenttime -ge $isha || $currenttime -lt $fajr ]]; then
	nexttime=$fajr
	nextprayer="Fajr"
	currentprayer="Isha"
fi

# Calculate the remaining time to the next prayer
remain=$(date -u -d "@$((nexttime - currenttime))" "+%H:%M")
# ------ Ramadan Timings ------ #
# fast=$(date -u -d "@$(( maghrib - fajr ))" '+%H:%M')
# Tofast=$(date -u -d "@$(( maghrib - currenttime ))" '+%H:%M')

# ======================= OUTPUT ======================= #
#current_out="$currentprayer ($remain)"
next_out="$nextprayer in $remain"

# Get the next fard
if [[ "$XDG_SESSION_TYPE" == "x11" ]]; then
	echo -n "$next_out"
else
	printf '{ "text": "%s", "class": "%s" }\n' "$next_out" "$nextprayer"
fi
