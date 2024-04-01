#!/bin/bash

prayers="$HOME/.local/share/prayers.json"
current_month=$(date +%-m)
current_year=$(date +%Y)
# ----- Parameters ------ #
# Coordinates: https://www.mapcoordinates.net/en
lat='30.001780'
long='31.290419'
# Calculation Method: https://api.aladhan.com/v1/methods
method="5"

if [[ -r $prayers ]]; then
	available_month=$(jq -r ".data[0].date.gregorian.month.number" "$prayers")
else
	fetch_prayers=1
fi

if [[ "$fetch_prayers" || "$available_month" != "$current_month" ]]; then
	# Documentation: https://aladhan.com/prayer-times-api#GetCalendar
	wget -O "$prayers" "http://api.aladhan.com/v1/calendar/$current_year/$current_month?latitude=$lat&longitude=$long&method=$method"
fi

"$HOME/.local/bin/add-prayers-at-jobs.sh"
