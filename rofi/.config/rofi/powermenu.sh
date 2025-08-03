#!/usr/bin/env bash

# CMDs
uptime="$(uptime -p | sed -e 's/up //g;s/ minutes/m/g;s/ hours*,/h/g')"
host=$(hostname)

# Options
shutdown=''
reboot='󰑐'
lock='󰌾'
suspend=''
logout='󰍃'
hibernate=''
yes='󰰴'
no='󰰓'

# Rofi CMD
rofi_cmd() {
  rofi -dmenu \
    -p "  $USER@$host" \
    -mesg "Uptime:   $uptime" \
    -theme ~/.config/rofi/powermenu-config.rasi
}

# Confirmation CMD
confirm_cmd() {
  rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
    -theme-str 'mainbox {orientation: vertical; children: [ "message", "listview" ];}' \
    -theme-str 'listview {columns: 2; lines: 1;}' \
    -theme-str 'element-text {horizontal-align: 0.5;}' \
    -theme-str 'textbox {horizontal-align: 0.5;}' \
    -dmenu \
    -p 'Confirmation' \
    -mesg 'Are you Sure?' \
    -theme ~/.config/rofi/powermenu-config.rasi
}

# Ask for confirmation
confirm_exit() {
  echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
  echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown\n$hibernate" | rofi_cmd
}

# Execute Command
run_cmd() {
  selected="$(confirm_exit)"
  if [[ "$selected" == "$yes" ]]; then
    if [[ $1 == '--shutdown' ]]; then
      systemctl poweroff
    elif [[ $1 == '--reboot' ]]; then
      systemctl reboot
    elif [[ $1 == '--suspend' ]]; then
      systemctl suspend
    elif [[ $1 == '--hibernate' ]]; then
      systemctl hibernate
    elif [[ $1 == '--logout' ]]; then
      if [[ "$DESKTOP_SESSION" == 'openbox' ]]; then
        openbox --exit
      elif [[ "$DESKTOP_SESSION" == 'bspwm' ]]; then
        bspc quit
      elif [[ "$DESKTOP_SESSION" == 'i3' ]]; then
        i3-msg exit
      elif [[ "$DESKTOP_SESSION" == 'plasma' ]]; then
        qdbus org.kde.ksmserver /KSMServer logout 0 0 0
      elif [[ "$DESKTOP_SESSION" == 'hyprland' ]]; then
        hyprctl dispatch exit
      fi
    fi
  else
    exit 0
  fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
$shutdown)
  run_cmd --shutdown
  ;;
$reboot)
  run_cmd --reboot
  ;;
$hibernate)
  run_cmd --hibernate
  ;;
$lock)
  hyprlock &
  ;;
$suspend)
  run_cmd --suspend
  ;;
$logout)
  run_cmd --logout
  ;;
esac
