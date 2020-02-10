#!/bin/sh

set -e

if [ -z "$1" ];then
  echo "File argument required"
  exit 1
fi

jhead -ft "$1"
