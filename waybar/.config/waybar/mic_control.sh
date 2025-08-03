#!/bin/bash

# Check for microphone presence
check_mic() {
  wpctl status | grep -E 'Sources:|Filters:' -A 10 | grep -q '\[Audio/Source\]'
  return $?
}

# Get volume percentage
get_volume_percent() {
  local vol
  vol=$(wpctl get-volume @DEFAULT_SOURCE@ | grep -oE '[0-1]\.[0-9]{2}' | head -1)
  if [ -n "$vol" ]; then
    awk -v vol="$vol" 'BEGIN {print int(vol * 100)}'
  else
    echo 0
  fi
}

# Main logic
case "$1" in
  --action)
    case "$2" in
      display)
        if check_mic; then
          vol_percent=$(get_volume_percent)
            if wpctl get-volume @DEFAULT_SOURCE@ | grep -q '[MUTED]'; then
              echo "{\"text\": \"$vol_percent\", \"class\": \"muted\", \"percentage\": $vol_percent, \"alt\": \"muted\"}"
            else
              echo "{\"text\": \"$vol_percent\", \"class\": \"unmuted\", \"percentage\": $vol_percent, \"alt\": \"unmuted\"}"
            fi
        else
          echo "{\"text\": \"0\", \"class\": \"inactive\", \"percentage\": 0, \"alt\": \"\"}"
        fi
        ;;
      increase)
        if check_mic; then
          vol_percent=$(get_volume_percent)
          if [ "$vol_percent" -lt 100 ]; then
            wpctl set-volume @DEFAULT_SOURCE@ 0.05+
          fi
        fi
        ;;
      decrease)
        if check_mic; then
          wpctl set-volume @DEFAULT_SOURCE@ 0.05-
        fi
        ;;
      toggle)
        if check_mic; then
          wpctl set-mute @DEFAULT_SOURCE@ toggle
        fi
        ;;
      *)
        echo "Usage: $0 --action {display|increase|decrease|toggle}"
        exit 1
        ;;
    esac
    ;;
  *)
    echo "Usage: $0 --action {display|increase|decrease|toggle}"
    exit 1
    ;;
esac
