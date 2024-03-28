#!/bin/bash

# Get some parameters like the location and the school to be used
# when calculating the fajr and isha angle
lat='30.001780'
long='31.290419'
city="Cairo"
country="Egypt"
method="5" # https://api.aladhan.com/v1/methods
adjustment="0"
prayers="$HOME/.local/share/prayers.json"
available_month=""
current_month=$(date +%m | awk '/^0.*/ {sub("0","")}{print}')
current_year=$(date +%Y)
fetch_prayers=""

if [[ -f $prayers ]]; then
	available_month=$(jq ".data[0].date.gregorian.month.number" "$prayers")
else
	fetch_prayers=1
fi

if [[ "$fetch_prayers" || "$available_month" != "$current_month" ]]; then
	# Documentation: https://aladhan.com/prayer-times-api#GetCalendar
	wget -O "$prayers" "http://api.aladhan.com/v1/calendar/$current_year/$current_month?latitude=$lat&longitude=$long&method=$method"
fi

echo "Creating at jobs for prayer notification..."
"$HOME/.local/bin/add-prayers-at-jobs.sh"
