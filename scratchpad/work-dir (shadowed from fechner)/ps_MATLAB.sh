#!/bin/bash
if [[ $# -gt 0 ]]; then
  HH8MM=$1
  ps -fu tselab | grep "$HH8MM[^^]*MATLAB" | awk '{print $2}'
else
  ps -fu tselab | fgrep MATLAB
fi
