#!/bin/bash

IN_VIRT=false

handle() {
  local line="$1"
  local event="${line%%>>*}"
  local data="${line#*>>}"

  [[ "$event" != "activewindow" ]] && return

  IFS=',' read -r class title <<< "$data"

  if [[ "$class" == "virt-manager" && "$title" =~ on\ QEMU/KVM$ ]]; then
    $IN_VIRT && return
    IN_VIRT=true
    hyprctl dispatch submap reset
  else
    $IN_VIRT || return
    IN_VIRT=false
    hyprctl dispatch submap global
  fi
}

socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" \
| while read -r line; do
  handle "$line"
done
