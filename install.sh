#!/bin/bash
set -eu -o pipefail

# colors
CDEF="\033[0m"      # default color
b_CCIN="\033[1;36m" # bold info color
b_CGSC="\033[1;32m" # bold success color
b_CRER="\033[1;31m" # bold error color
b_CWAR="\033[1;33m" # bold warning color

# variable declarations
declare systemd_unit="timer"
declare bar=""
declare print_lang=""
declare daemon=""
declare lat=""
declare long=""
declare method=""
declare dist=""
declare -a dep_list=("curl" "at" "yad" "mpv" "findutils" "jq")

prompt() {
	case ${1} in
	"-s" | "--success")
		echo -en "${b_CGSC}${2/-s\ /}${CDEF}"
		;; # print success message
	"-e" | "--error")
		echo -en "${b_CRER}${2/-e\ /}${CDEF}"
		;; # print error message
	"-w" | "--warning")
		echo -en "${b_CWAR}${2/-w\ /}${CDEF}"
		;; # print warning message
	"-i" | "--info")
		echo -en "${b_CCIN}${2/-i\ /}${CDEF}"
		;; # print info message
	*)
		echo -en "$@"
		;;
	esac
}

command_exists() {
	command -v "$1" &>/dev/null
}

detect_os() {
	if [[ "$OSTYPE" == "linux-gnu" ]]; then
		if command_exists apt-get; then
			dist="debian"
		elif command_exists pacman; then
			dist="arch"
		elif command_exists dnf; then
			dist="fedora"
		fi
	else
		prompt -e "Unsupported OS. Exiting.\n"
		exit 1
	fi
}

set_opts() {
	prompt -s "-- statusbar --\n"
	local PS3="choose statusbar: "
	select choice in waybar polybar; do
		dep_list+=("$choice")
		bar="$choice"
		break
	done

	prompt -s "-- notification daemon --\n"
	PS3="choose notification daemon: "
	select choice in dunst mako; do
		dep_list+=("$choice")
		daemon="$choice"
		break
	done

	prompt -s "-- systemd unit --\n"
	PS3="choose systemd unit: "
	select choice in boot timer; do
		systemd_unit="$choice"
		break
	done

	prompt -s "-- prayer times language --\n"
	PS3="choose language: "
	select choice in en ar; do
		print_lang="$choice"
		break
	done

	prompt -s "-- calculation method (https://api.aladhan.com/v1/methods) --\n"
	while [[ -z "$method" ]]; do
		prompt -i "Enter calculation method: "
		read -r method
	done

	prompt -s "-- coordinates (https://www.mapcoordinates.net/en) --\n"
	while [[ -z "$lat" ]]; do
		prompt -i "Enter latitude: "
		read -r lat
	done
	while [[ -z "$long" ]]; do
		prompt -i "Enter longitude: "
		read -r long
	done

}

install_deps() {
	if [[ -z "$dist" ]]; then
		prompt -w "Could not detect distribution. Dependencies will not be installed, do you want to continue? [y/N] "
		read -r response
		if [[ "$response" =~ ^([nN][oO]|[nN])+$ ]]; then
			exit 1
		fi
	fi

	case "$dist" in
	debian)
		sudo apt-get update -y
		sudo apt-get install "${dep_list[@]}"
		;;
	arch)
		sudo pacman -Sy --noconfirm --needed "${dep_list[@]}"
		;;
	fedora)
		sudo dnf update -y
		sudo dnf install -y "${dep_list[@]}"
		;;
	*)
		prompt -w "Unsupported distro. Skipping dependencies installation.\n"
		;;
	esac
}

install_scripts() {
	prompt -s "-- installing scripts --\n"
	mkdir -p "/home/$USER/.local/bin"
	for sc in ./.local/bin/*; do
		prompt -i "installing $sc to ~/.local/bin\n"
		chmod 755 "$sc"
		cp "$sc" ~/.local/bin/
	done
}

install_systemd_unit() {
	prompt -s "-- installing systemd unit --\n"
	mkdir -p "/home/$USER/.config/systemd/user"
	cp ./.config/systemd/user/prayer-times.service ~/.config/systemd/user/

	case "$systemd_unit" in
	boot)
		systemctl --user daemon-reload
		systemctl --user enable --now prayer-times.service
		prompt -i "-> enabled systemd service (sync on boot)\n"
		;;
	timer)
		cp ./.config/systemd/user/prayer-times.timer ~/.config/systemd/user/
		systemctl --user daemon-reload
		systemctl --user enable --now prayer-times.timer
		prompt -i "-> enabled systemd timer (sync on boot + every 8 hours)\n"
		;;
	*) ;;
	esac
}

set_script_params() {
	prompt -s "-- setting script parameters --\n"
	sed -i "s/^lat='.*'$/lat='$lat'/" ~/.local/bin/prayer-times
	prompt -i "-> changed latitude\n"
	sed -i "s/^long='.*'$/long='$long'/" ~/.local/bin/prayer-times
	prompt -i "-> changed longitude\n"
	sed -i "s/^method='.*'$/method='$method'/" ~/.local/bin/prayer-times
	prompt -i "-> changed calculation method\n"
	sed -i "s/^print_lang='.*'$/print_lang='$print_lang'/" ~/.local/bin/prayer-times
	prompt -i "-> changed prayer schedule language\n"
	sed -i "s/^notify='.*'$/notify='$daemon'/" ~/.local/bin/prayer-times
	prompt -i "-> changed notification daemon\n"
}

print_statusbar_config() {
	case "$bar" in
	polybar)
		prompt -i "Add the following module to your polybar config\n"
		cat <<EOF
[module/prayers]
type = custom/script
exec = \$HOME/.local/bin/prayer-times status
interval = 60
label = %{A:\$HOME/.local/bin/prayer-times yad:}%{F#83CAFA}󱠧 %{F-} %output%%{A}
EOF
		;;
	waybar)
		prompt -i "Add the following module to your waybar config\n"
		cat <<EOF
"custom/prayers": {
  "interval": 60,
  "return-type": "json",
  "exec": "\$HOME/.local/bin/prayer-times waybar",
  "on-click": "\$HOME/.local/bin/prayer-times yad",
  "format": "󱠧  {}",
}
EOF
		;;
	*) ;;
	esac
}

print_daemon_config() {
	case "$daemon" in
	mako)
		prompt -i "Add the following criteria/rule to your mako config\n"
		cat <<EOF
[summary="Prayer Times"]
on-notify=exec \$HOME/.local/bin/play-athan
on-button-left=exec bash -c "ps --no-headers -C mpv -o pid:1,args:1 | grep 'qatami' | cut -d' ' -f1 | xargs -r kill -1"
EOF
		;;
	dunst)
		prompt -i "Add the following criteria/rule to your dunst config\n"
		cat <<EOF
[play_athan]
summary = "Prayer Times"
script = "\$HOME/.local/bin/play-athan"
EOF
		;;
	*) ;;
	esac
}

trap 'prompt -e "script failed at line $LINENO"' ERR

# detect_os
set_opts
# install_deps
# install_scripts
# set_script_params
# install_systemd_unit
print_statusbar_config
print_daemon_config
