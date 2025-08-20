#!/usr/bin/env bash
# Usage: volctl-notify up|down|mute [step]
# Example: volctl-notify up 5%

sink="@DEFAULT_AUDIO_SINK@"
step="${2:-5%}"

case "$1" in
  up)   wpctl set-volume "$sink" "${step}+" ;;
  down) wpctl set-volume "$sink" "${step}-" ;;
  mute) wpctl set-mute   "$sink" toggle     ;;
  *)    echo "usage: $0 up|down|mute [step]"; exit 1 ;;
esac

# Query current volume/mute
out="$(wpctl get-volume "$sink")"           # e.g. "Volume: 0.34" or "Volume: 0.34 [MUTED]"
vol="$(printf '%s' "$out" | awk '{print $2}')"   # 0.34
perc="$(awk -v v="$vol" 'BEGIN{printf("%d", v*100+0.5)}')"
muted=""
echo "$out" | grep -q MUTED && muted=" (muted)"

# Pick an icon
icon="audio-volume-high"
if [ -n "$muted" ] || [ "$perc" -eq 0 ]; then
  icon="audio-volume-muted"
elif [ "$perc" -lt 30 ]; then
  icon="audio-volume-low"
elif [ "$perc" -lt 70 ]; then
  icon="audio-volume-medium"
fi

# Send a replaceable, stacked notification with a progress hint
dunstify -a "Volume" -i "$icon" -u low \
  -r 7777 \
  -h string:x-dunst-stack-tag:volume \
  -h int:value:"$perc" \
  "Volume: ${perc}%${muted}"
