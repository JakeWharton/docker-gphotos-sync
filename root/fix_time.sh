#!/bin/sh

set -e

if [ -z "$1" ];then
  echo "File argument required"
  exit 1
fi

EXTENSION=$(echo "${1##*.}" | tr '[:upper:]' '[:lower:]')
if [ "$EXTENSION" = "jpg" ] || [ "$EXTENSION" = "jpeg" ]; then
  jhead -ft "$1"
else
  echo "Unable to set file mtime. Unsupported file extension: $EXTENSION"
fi
