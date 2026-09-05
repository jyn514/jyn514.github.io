#!/bin/sh
set -u
if [ $# -eq 0 ]; then
        echo "usage: $(basename "$0") path target"
        exit 1
fi

path=$1
target=$2
dst=content/redirects/$path.md
if ! [ -e "$dst" ]; then
  echo "creating redirect from /$path to $target"
  echo "+++
path = \"$path\"
[extra]
target = \"$target\"
  +++" > "$dst"
fi
