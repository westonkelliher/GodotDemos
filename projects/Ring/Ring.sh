#!/bin/sh
echo -ne '\033c\033]0;Ring\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Ring.x86_64" "$@"
