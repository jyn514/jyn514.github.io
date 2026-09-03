#!/bin/sh
tr < "${1:-README.md}" -cs '[:alpha:]' '\n' \
  | tr A-Z a-z \
  | sort \
  | uniq --count \
  | sort --reverse --numeric-sort
