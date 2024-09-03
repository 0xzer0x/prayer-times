#!/bin/bash
set -eu -o pipefail

# colors
CDEF="\033[0m"      # default color
b_CCIN="\033[1;36m" # bold info color
b_CGSC="\033[1;32m" # bold success color
b_CRER="\033[1;31m" # bold error color
b_CWAR="\033[1;33m" # bold warning color

# variable declarations
declare bar=""
declare print_lang=""
declare daemon=""
declare lat=""
declare long=""
declare method=""
declare dist=""
declare systemd_unit="timer"
declare -a dep_list=("curl" "at" "yad" "mpv" "jq")
declare -A methods=(
  [3]="Muslim World League"
  [2]="Islamic Society of North America (ISNA)"
  [5]="Egyptian General Authority of Survey"
  [4]="Umm Al-Qura University, Makkah"
  [1]="University of Islamic Sciences, Karachi"
  [7]="Institute of Geophysics, University of Tehran"
  [0]="Shia Ithna-Ashari, Leva Institute, Qum"
  [8]="Gulf Region"
  [9]="Kuwait"
  [10]="Qatar"
  [11]="Majlis Ugama Islam Singapura, Singapore"
  [12]="Union Organization Islamic de France"
  [13]="Diyanet İşleri Başkanlığı, Turkey (experimental)"
  [14]="Spiritual Administration of Muslims of Russia"
  [15]="Moonsighting Committee Worldwide (Moonsighting.com)"
  [16]="Dubai (experimental)"
  [17]="Jabatan Kemajuan Islam Malaysia (JAKIM)"
  [18]="Tunisia"
  [19]="Algeria"
  [20]="Kementerian Agama Republik Indonesia"
  [21]="Morocco"
  [22]="Comunidade Islamica de Lisboa"
  [23]="Ministry of Awqaf, Islamic Affairs and Holy Places, Jordan"
)

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

select_method() {
  local choice=""
  while [[ -z "$choice" ]]; do
    for k in "${!methods[@]}"; do
      echo -e "${b_CGSC}id:${CDEF} ${k} - ${b_CGSC}name:${CDEF} ${methods[$k]}"
    done
    prompt -i "Select calculation method: "
    read -r choice
    # reset choice if method does not exist
    [[ -z "${methods[${choice:-null}]:+exists}" ]] && prompt -w "Chosen method does not exist.\n" && choice=""
  done
  method="$choice"
}

select_bar() {
  local PS3="Choose statusbar: "
  local choice=""
  select choice in waybar polybar; do
    if [[ -n "$choice" ]]; then
      printf "%s" "$choice"
      break
    fi
  done
}

select_notification() {
  local PS3="Choose notification daemon: "
  local choice=""
  select choice in dunst mako; do
    if [[ -n "$choice" ]]; then
      printf "%s" "$choice"
      break
    fi
  done
}

select_unit() {
  local PS3="Choose systemd unit: "
  select choice in boot timer; do
    if [[ -n "$choice" ]]; then
      printf "%s" "$choice"
      break
    fi
  done
}

select_lang() {
  local PS3="Choose language: "
  select choice in en ar; do
    if [[ -n "$choice" ]]; then
      printf "%s" "$choice"
      break
    fi
  done
}

set_coordinates() {
  while [[ -z "$lat" ]]; do
    read -r -p "Enter latitude: " lat
  done
  while [[ -z "$long" ]]; do
    read -r -p "Enter longitude: " long
  done
}

print_opts() {
  prompt -s "-- options --\n"
  cat <<EOF
Statusbar: $bar
Notifications: $daemon
Unit: $systemd_unit
Language: $print_lang
Coordinates: $lat - $long
Method: $method - ${methods[$method]}
EOF
}

set_opts() {
  while true; do
    prompt -i "-- statusbar --\n"
    bar=$(select_bar)
    dep_list+=("$bar")

    prompt -i "-- notification daemon --\n"
    daemon=$(select_notification)
    dep_list+=("$daemon")

    prompt -i "-- systemd unit --\n"
    systemd_unit=$(select_unit)

    prompt -i "-- prayer times language --\n"
    print_lang=$(select_lang)

    prompt -i "-- calculation method (https://api.aladhan.com/v1/methods) --\n"
    select_method

    prompt -i "-- coordinates (https://www.mapcoordinates.net/en) --\n"
    set_coordinates

    print_opts
    prompt -w "Confirm? [Y/n] "
    local confirm
    read -r confirm
    [[ "$confirm" =~ ^([nN][oO]|[nN])$ ]] && continue
    break
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
  prompt -s "[+] installing scripts\n"
  mkdir -p "/home/$USER/.local/bin"
  for sc in ./.local/bin/*; do
    prompt -i "installing $sc to ~/.local/bin\n"
    chmod 755 "$sc"
    cp "$sc" ~/.local/bin/
  done
}

install_systemd_unit() {
  prompt -s "[+] installing systemd unit\n"
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
  prompt -s "[+] setting script parameters\n"
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
    prompt -s "[+] Add the following module to your polybar config\n"
    cat <<EOF
[module/prayers]
type = custom/script
exec = \$HOME/.local/bin/prayer-times status
interval = 60
label = %{A:\$HOME/.local/bin/prayer-times yad:}%{F#83CAFA}󱠧 %{F-} %output%%{A}
EOF
    ;;
  waybar)
    prompt -s "[+] Add the following module to your waybar config\n"
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
    prompt -s "[+] Add the following criteria/rule to your mako config\n"
    cat <<EOF
[summary="Prayer Times"]
on-notify=exec \$HOME/.local/bin/toggle-athan
on-button-left=exec \$HOME/.local/bin/toggle-athan
EOF
    ;;
  dunst)
    prompt -s "[+] Add the following criteria/rule to your dunst config\n"
    cat <<EOF
[play_athan]
summary = "Prayer Times"
script = "\$HOME/.local/bin/toggle-athan"
EOF
    ;;
  *) ;;
  esac
}

trap 'prompt -e "script failed at line $LINENO"' ERR

detect_os
set_opts
install_deps
install_scripts
set_script_params
install_systemd_unit
print_statusbar_config
print_daemon_config
