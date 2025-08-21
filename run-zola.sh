#!/bin/sh
exec zola serve --drafts --base-url / -i 0.0.0.0 -p 1111 "$@"
