#!/usr/bin/env bash

set -e
set -o xtrace

source ./vars.sh

rm -f $DUMP_FILE_NAME
wget $DUMP_URL
