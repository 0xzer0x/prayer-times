#!/bin/sh

prayers="$HOME/.local/share/prayers.json"

# Parsing the data for the five salawat
fajr=$(date -d $(jq ".data.timings.Fajr" $prayers | bc | awk '{$1=$1};1') '+%I:%M')
sunrise=$(date -d $(jq ".data.timings.Sunrise" $prayers | bc | awk '{$1=$1};1') '+%I:%M')
dhuhr=$(date -d $(jq ".data.timings.Dhuhr" $prayers | bc | awk '{$1=$1};1') '+%I:%M')
asr=$(date -d $(jq ".data.timings.Asr" $prayers | bc | awk '{$1=$1};1') '+%I:%M')
maghrib=$(date -d $(jq ".data.timings.Maghrib" $prayers | bc | awk '{$1=$1};1') '+%I:%M')
isha=$(date -d $(jq ".data.timings.Isha" $prayers | bc | awk '{$1=$1};1') '+%I:%M')
# Hijri date
day=$(jq ".data.date.hijri.weekday.en" $prayers | bc | awk '{$1=$1};1')
day_ar=$(jq ".data.date.hijri.weekday.ar" $prayers | bc | awk '{$1=$1};1')
daynumber=$(jq ".data.date.hijri.day" $prayers | bc | awk '{$1=$1};1')
month=$(jq ".data.date.hijri.month.en" $prayers | bc | awk '{$1=$1};1')
month_ar=$(jq ".data.date.hijri.month.ar" $prayers | bc | awk '{$1=$1};1')
year=$(jq ".data.date.hijri.year" $prayers | bc | awk '{$1=$1};1')


# YAD dialog text
printf "📅 $day_ar، $daynumber-$month_ar-$year\n۞ الفجر\t\t$fajr\n۞ الشروق\t$sunrise\n۞ الظهر\t\t$dhuhr\n۞ العصر\t\t$asr\n۞ المغرب\t$maghrib\n۞ العشاء\t\t$isha\n"

# EN
# printf "📅 $day،\n$daynumber-$month-$year\n۞ Fajr\t\t$fajr\n۞ Sunrise\t$sunrise\n۞ Dhuhr\t\t$dhuhr\n۞ Asr\t\t$asr\n۞ Maghrib\t$maghrib\n۞ Isha\t\t$isha\n"
