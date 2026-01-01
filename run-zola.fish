#!/usr/bin/env fish

argparse -s 'i/interface=?' -- $argv || return

set i 0.0.0.0
set -q _flag_interface && set i $_flag_interface

exec zola serve --drafts --base-url / -i $i -p 1111 $argv
