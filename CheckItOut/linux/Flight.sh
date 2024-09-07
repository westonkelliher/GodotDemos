#!/bin/sh
echo -ne '\033c\033]0;Flight\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Flight.x86_64" "$@"
