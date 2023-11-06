#!/bin/bash

prayers="$HOME/.local/share/prayers.json"

# Parsing the data for the five salawat
day_idx=$(( $(date +%d | awk '/^0.*/{sub("0","")}{print}') - 1 ))
fajr=$(date -d "$(jq ".data[$day_idx].timings.Fajr" $prayers | bc)" '+%I:%M')
sunrise=$(date -d "$(jq ".data[$day_idx].timings.Sunrise" $prayers | bc)" '+%I:%M')
dhuhr=$(date -d "$(jq ".data[$day_idx].timings.Dhuhr" $prayers | bc)" '+%I:%M')
asr=$(date -d "$(jq ".data[$day_idx].timings.Asr" $prayers | bc)" '+%I:%M')
maghrib=$(date -d "$(jq ".data[$day_idx].timings.Maghrib" $prayers | bc)" '+%I:%M')
isha=$(date -d "$(jq ".data[$day_idx].timings.Isha" $prayers | bc)" '+%I:%M')
# Hijri date
day=$(jq ".data[$day_idx].date.hijri.weekday.en" $prayers | bc)
day_ar=$(jq ".data[$day_idx].date.hijri.weekday.ar" $prayers | bc)
daynumber=$(jq ".data[$day_idx].date.hijri.day" $prayers | bc)
month=$(jq ".data[$day_idx].date.hijri.month.en" $prayers | bc)
month_ar=$(jq ".data[$day_idx].date.hijri.month.ar" $prayers | bc)
year=$(jq ".data[$day_idx].date.hijri.year" $prayers | bc)


# ============================== YAD dialog text ============================== #

# AR
printf "📅 $day_ar،$daynumber-$month_ar-$year\n۞ الفجر\t\t$fajr\n۞ الشروق\t$sunrise\n۞ الظهر\t\t$dhuhr\n۞ العصر\t\t$asr\n۞ المغرب\t$maghrib\n۞ العشاء\t\t$isha\n"

# EN
#printf "📅 $day,\n$daynumber-$month-$year\n۞ Fajr\t\t$fajr\n۞ Sunrise\t$sunrise\n۞ Dhuhr\t$dhuhr\n۞ Asr\t\t$asr\n۞ Maghrib\t$maghrib\n۞ Isha\t\t$isha\n"
