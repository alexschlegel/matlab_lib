#!/bin/bash

cd "$(dirname "$0")" || exit 1

OPTS="-nodesktop -nodisplay -nosplash"
if [[ $# -eq 0 ]]; then
  matlab $OPTS
else
  [[ $# -eq 1 ]] || { echo "$(basename "$0"): Too many arguments"; exit 1; }
  MBASE="$(basename "$1" .m)"
  MNAME="$MBASE".m
  [[ -f "$MNAME" ]] || {
    echo "Not found in $(basename "$(pwd)"): $MNAME"
    exit 1
  }
  TS=$(date +%Y%m%d_%H%M%S)
  OBASE="$TS-$MBASE"
  nohup matlab $OPTS -r "$MBASE" > "$OBASE.out" 2> "$OBASE.err" &
fi
