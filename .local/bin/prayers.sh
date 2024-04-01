#!/bin/bash

prayers="$HOME/.local/share/prayers.json"

# Parsing the data for the five salawat
day_idx=$(($(date +%-d) - 1))
fajr=$(date -d "$(jq -r ".data[$day_idx].timings.Fajr" "$prayers")" '+%I:%M')
sunrise=$(date -d "$(jq -r ".data[$day_idx].timings.Sunrise" "$prayers")" '+%I:%M')
dhuhr=$(date -d "$(jq -r ".data[$day_idx].timings.Dhuhr" "$prayers")" '+%I:%M')
asr=$(date -d "$(jq -r ".data[$day_idx].timings.Asr" "$prayers")" '+%I:%M')
maghrib=$(date -d "$(jq -r ".data[$day_idx].timings.Maghrib" "$prayers")" '+%I:%M')
isha=$(date -d "$(jq -r ".data[$day_idx].timings.Isha" "$prayers")" '+%I:%M')
# Hijri date
day=$(jq -r ".data[$day_idx].date.hijri.weekday.en" "$prayers")
day_ar=$(jq -r ".data[$day_idx].date.hijri.weekday.ar" "$prayers")
daynumber=$(jq -r ".data[$day_idx].date.hijri.day" "$prayers")
month=$(jq -r ".data[$day_idx].date.hijri.month.en" "$prayers")
month_ar=$(jq -r ".data[$day_idx].date.hijri.month.ar" "$prayers")
year=$(jq -r ".data[$day_idx].date.hijri.year" "$prayers")

# ============================== YAD dialog text ============================== #

# --- AR --- #
printf "📅 %s،%s\n۞ الفجر\t\t%s\n۞ الشروق\t%s\n۞ الظهر\t\t%s\n۞ العصر\t\t%s\n۞ المغرب\t%s\n۞ العشاء\t\t%s" \
	"$day_ar" \
	"$daynumber-$month_ar-$year" \
	"$fajr" \
	"$sunrise" \
	"$dhuhr" \
	"$asr" \
	"$maghrib" \
	"$isha"

# --- EN --- #
# printf "📅 %s،%s\n۞ Fajr\t\t%s\n۞ Sunrise\t%s\n۞ Dhuhr\t\t%s\n۞ Asr\t\t%s\n۞ Maghrib\t%s\n۞ Isha\t\t%s" \
# 	"$day_ar" \
# 	"$daynumber-$month_ar-$year" \
# 	"$fajr" \
# 	"$sunrise" \
# 	"$dhuhr" \
# 	"$asr" \
# 	"$maghrib" \
# 	"$isha"
