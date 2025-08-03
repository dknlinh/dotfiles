#!/bin/sh
# Check if a microphone (source) exists
if wpctl status | grep -E 'Sources:|Filters:' -A 10 | grep -q '\[Audio/Source\]'; then
  # Get volume and mute status
  vol=$(wpctl get-volume @DEFAULT_SOURCE@ | grep -o '[0-1]\.[0-9]\{2\}' | head -1)
  vol_percent=$(awk "BEGIN {print int($vol * 100)}")
  # Check mute status
  if wpctl get-volume @DEFAULT_SOURCE@ | grep -q '[MUTED]'; then
    echo "{\"text\": \"$vol_percent\",\"alt\": \"muted\", \"class\": \"muted\", \"percentage\": $vol_percent}"
  else
    echo "{\"text\": \"$vol_percent\", \"alt\": \"unmuted\",\"class\": \"unmuted\", \"percentage\": $vol_percent}"
  fi
else
  # Output empty JSON to hide the module
  echo "{\"text\": \"0\", \"alt\": \"\", \"class\":\"inactive\", \"percentage\": 0}"
fi
