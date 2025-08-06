#!/bin/sh

# Define your two sinks
SINK1="alsa_output.pci-0000_28_00.4.analog-stereo"
SINK2="alsa_output.usb-Razer_Razer_Barracuda_X-00.analog-stereo"

# Find the current default sink
CURRENT=$(pactl info | awk -F: '/Default Sink/ { gsub(/^[ \t]+/,"",$2); print $2 }')

# Decide which sink to switch to
if [ "$CURRENT" = "$SINK1" ]; then
  NEW="$SINK2"
else
  NEW="$SINK1"
fi

# Set the new default sink
pactl set-default-sink "$NEW"