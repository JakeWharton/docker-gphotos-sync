#!/bin/sh

set -e

if [ -z "$1" ];then
  echo "File argument required"
  exit 1
fi

if [ "${1: -4}" == ".jpg" ]; then
  jhead -ft "$1"
else
  echo "Unable to set file mtime. Unsupported file extension."
fi
