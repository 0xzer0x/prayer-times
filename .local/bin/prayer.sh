#!/bin/sh

nextprayer=""
currentprayer=""
prayers="$HOME/.local/share/prayers.json"

# Parsing the data for the five salawat
# use epoch seconds in order to calculate time difference
# date -d $(jq ".data.timings.PRAYER" $prayers | bc) +%s
fajr=$(date -d "$(jq ".data.timings.Fajr" $prayers | bc)" +%s)
dhuhr=$(date -d "$(jq ".data.timings.Dhuhr" $prayers | bc)" +%s)
asr=$(date -d "$(jq ".data.timings.Asr" $prayers | bc)" +%s)
maghrib=$(date -d "$(jq ".data.timings.Maghrib" $prayers | bc)" +%s)
isha=$(date -d "$(jq ".data.timings.Isha" $prayers | bc)" +%s)

# Get the current time
currenttime=$(date +%s)
day=$(date +%a)

if [ $currenttime -ge $fajr ] && [ $currenttime -lt $dhuhr ]; then
    nexttime=$dhuhr
    currentprayer="Fajr"
    if [[ "$day" == "Fri" ]]; then
    	nextprayer="Jumuaa"
    else
	nextprayer="Dhuhr"
    fi

elif [ $currenttime -ge $dhuhr ] && [ $currenttime -lt $asr ]; then
    currentprayer="Dhuhr"
    nextprayer="Asr"
    nexttime=$asr

elif [ $currenttime -ge $asr ] && [ $currenttime -lt $maghrib ]; then
    currentprayer="Asr"
    nextprayer="Maghrib"
    nexttime=$maghrib

elif [ $currenttime -ge $maghrib ] && [ $currenttime -lt $isha ]; then
    currentprayer="Maghrib"
    nextprayer="Isha"
    nexttime=$isha

elif [ $currenttime -ge $isha ] || [ $currenttime -lt $fajr ]; then
    currentprayer="Isha"
    nextprayer="Fajr"
    nexttime=$fajr
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
