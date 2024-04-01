#!/bin/bash

prayers_json="$HOME/.local/share/prayers.json"
day_idx=$(($(date +%-d) - 1))
declare -A hijri
hijri=(
	['today_ar']=$(jq -r ".data[$day_idx].date.hijri.weekday.ar" "$prayers_json")
	['daynumber']=$(jq -r ".data[$day_idx].date.hijri.day" "$prayers_json")
	['month_ar']=$(jq -r ".data[$day_idx].date.hijri.month.ar" "$prayers_json")
	['year']=$(jq -r ".data[$day_idx].date.hijri.year" "$prayers_json")
)

timeof() {
	[[ "$#" -ne "1" ]] && echo "exactly 1 argument is needed" && return 1
	echo -n "$(date -d "$(jq -r ".data[$day_idx].timings.$1" "$prayers_json")" '+%I:%M')"
}

print() {
	printf "📅 %s،%s\n۞ الفجر\t%s\n۞ الشروق\t%s\n۞ الظهر\t%s\n۞ العصر\t%s\n۞ المغرب\t%s\n۞ العشاء\t%s" \
		"${hijri[today_ar]}" \
		"${hijri[daynumber]}-${hijri[month_ar]}-${hijri[year]}" \
		"$(timeof Fajr)" \
		"$(timeof Sunrise)" \
		"$(timeof Dhuhr)" \
		"$(timeof Asr)" \
		"$(timeof Maghrib)" \
		"$(timeof Isha)"
}

yad-text() {
	printf "<span font-size='large'>📅 <b>%s،%s</b>\n۞ الفجر\t\t%s\n۞ الشروق\t%s\n۞ الظهر\t\t%s\n۞ العصر\t\t%s\n۞ المغرب\t%s\n۞ العشاء\t\t%s</span>" \
		"${hijri[today_ar]}" \
		"${hijri[daynumber]}-${hijri[month_ar]}-${hijri[year]}" \
		"$(timeof Fajr)" \
		"$(timeof Sunrise)" \
		"$(timeof Dhuhr)" \
		"$(timeof Asr)" \
		"$(timeof Maghrib)" \
		"$(timeof Isha)"
}

yad-toggle() {
	if [[ "$XDG_SESSION_TYPE" == "x11" ]]; then
		yad_pid=$(xprop _NET_WM_PID -name Prayers 2>/dev/null | awk '{print $3}')
	elif [[ "$XDG_CURRENT_DESKTOP" == "Hyprland" ]]; then
		yad_pid=$(hyprctl clients | awk '/title: Prayers/ {found=1} found && $0 ~ /pid/ {print $2}')
	fi

	if [[ -z "$yad_pid" ]]; then
		yad --no-buttons --text-width=10 --text "$(yad-text)" --title "Prayers"
	else
		kill "$yad_pid"
	fi
}

case "$1" in
yad)
	yad-toggle
	;;
*)
	print
	;;
esac
