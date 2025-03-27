#!/bin/bash

hyprctl dispatch "$*"

window_id=$(hyprctl activewindow -j | jq -r '.address')

hyprctl keyword decoration:active_opacity 0.9

sleep 0.1

hyprctl keyword decoration:active_opacity 1.0
