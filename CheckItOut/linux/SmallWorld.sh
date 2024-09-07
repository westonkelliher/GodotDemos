#!/bin/sh
echo -ne '\033c\033]0;SmallWorld\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/SmallWorld.x86_64" "$@"
