#!/bin/bash

nextprayer=""
currentprayer=""
prayers="$HOME/.local/share/prayers.json"

# Get the current time
currenttime=$(date +%s)
day=$(date +%a)
day_idx=$(( $(date +%d | awk '/^0.*/{sub("0","")}{print}') - 1 ))

# Parsing the.datafor the five salawat
# use epoch seconds in order to calculate time difference
# date -d $(jq ".data[DAY - 1].timings.PRAYER" $prayers | bc) +%s
fajr=$(date -d "$(jq ".data[$day_idx].timings.Fajr" $prayers | bc)" +%s)
dhuhr=$(date -d "$(jq ".data[$day_idx].timings.Dhuhr" $prayers | bc)" +%s)
asr=$(date -d "$(jq ".data[$day_idx].timings.Asr" $prayers | bc)" +%s)
maghrib=$(date -d "$(jq ".data[$day_idx].timings.Maghrib" $prayers | bc)" +%s)
isha=$(date -d "$(jq ".data[$day_idx].timings.Isha" $prayers | bc)" +%s)


if [ $currenttime -ge $fajr ] && [ $currenttime -lt $dhuhr ]; then
    nexttime=$dhuhr
    currentprayer="Fajr"
    if [[ "$day" == "Fri" ]]; then
    	nextprayer="Jumuaa"
    else
	nextprayer="Dhuhr"
    fi

elif [ $currenttime -ge $dhuhr ] && [ $currenttime -lt $asr ]; then
    nexttime=$asr
    nextprayer="Asr"
    currentprayer="Dhuhr"

elif [ $currenttime -ge $asr ] && [ $currenttime -lt $maghrib ]; then
    nexttime=$maghrib
    nextprayer="Maghrib"
    currentprayer="Asr"

elif [ $currenttime -ge $maghrib ] && [ $currenttime -lt $isha ]; then
    nexttime=$isha
    nextprayer="Isha"
    currentprayer="Maghrib"

elif [ $currenttime -ge $isha ] || [ $currenttime -lt $fajr ]; then
    nexttime=$fajr
    nextprayer="Fajr"
    currentprayer="Isha"
fi

# Calculate the remaining time to the next prayer (or iftar in ramadan and the fast duration is ramadan)
remain=$(date -u -d "@$(( "$nexttime" - "$currenttime" ))" "+%H:%M")

# Ramadan timings
# fast=$(date -u -d "@$(( "$maghrib" - "$fajr" ))" '+%H:%M')
# Tofast=$(date -u -d "@$(( "$maghrib" - "$currenttime" ))" '+%H:%M')

# ======================= OUTPUT ======================= #

# Get the current fard
#printf "$currentprayer ($remain)"

# Get the next fard
printf "$nextprayer in $remain"
