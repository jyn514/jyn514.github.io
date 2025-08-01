#!/bin/sh
set -u
if [ $# -eq 0 ]; then
        echo "Usage: $(basename "$0") title"
        exit 1
fi
realpath() { readlink -f "$@"; }

date=$(date -I)
title=$(echo "$@" | tr - ' ')
path=$(echo "$@" | tr '\t \r' '---' | tr -d '\n!,?:')
dst=content/$path.md

if ! [ -e "$dst" ]; then
    echo "creating new post at $(realpath "$dst")"
    echo "---
title: \"$title\"
date: $date
draft: true
#description: \"\"
#taxonomies:
#  tags: []
#  computer-of-the-future: [\"0\"]
extra:
  draft: true
#  category: \"tools\"
#  audience: \"everyone\"
#  toc: true
#  unlisted: true
#  stub: true
---
" > "$dst"
else
    echo "updating date for existing post $(realpath "$dst")"
	sed -i "s/date:	.*/date:	$date/" "$dst"
fi
