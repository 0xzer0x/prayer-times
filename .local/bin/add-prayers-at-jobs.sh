#!/bin/sh

prayers="$HOME/.local/share/prayers.json"

# WARNING: THIS SCRIPTS REMOVES ALL JOBS SCHEDULED USING AT
# ADJUST ACCORDINGLY
if [[ "$(at -q p -l | wc -l)" != "0" ]]; then
    for i in $(at -l | awk '{ print $1 }'); do
        atrm $i
    done
fi

fajr=$(date -d $(jq ".data.timings.Fajr" $prayers | bc | awk '{$1=$1};1') '+%H:%M %F')
dhuhr=$(date -d $(jq ".data.timings.Dhuhr" $prayers | bc | awk '{$1=$1};1') '+%H:%M %F')
asr=$(date -d $(jq ".data.timings.Asr" $prayers | bc | awk '{$1=$1};1') '+%H:%M %F')
maghrib=$(date -d $(jq ".data.timings.Maghrib" $prayers | bc | awk '{$1=$1};1') '+%H:%M %F')
isha=$(date -d $(jq ".data.timings.Isha" $prayers | bc | awk '{$1=$1};1') '+%H:%M %F')


fajr_cmd='[[ "$(dunstify --action="Reply,reply" "Prayer Times" "It is time for Fajr prayer 🕌" -t 30000)" == "2" ]] && killall mpv'
dhuhr_cmd='[[ "$(dunstify --action="Reply,reply" "Prayer Times" "It is time for Dhuhr prayer 🕌" -t 30000)" == "2" ]] && killall mpv'
asr_cmd='[[ "$(dunstify --action="Reply,reply" "Prayer Times" "It is time for Asr prayer 🕌" -t 30000)" == "2" ]] && killall mpv'
maghrib_cmd='[[ "$(dunstify --action="Reply,reply" "Prayer Times" "It is time for Maghrib prayer 🕌" -t 30000)" == "2" ]] && killall mpv'
isha_cmd='[[ "$(dunstify --action="Reply,reply" "Prayer Times" "It is time for Isha prayer 🕌" -t 30000)" == "2" ]] && killall mpv'

echo "$fajr_cmd" | at -q p "$fajr"
echo "$dhuhr_cmd" | at -q p "$dhuhr"
echo "$asr_cmd" | at -q p "$asr"
echo "$maghrib_cmd" | at -q p "$maghrib"
echo "$isha_cmd" | at -q p "$isha"
