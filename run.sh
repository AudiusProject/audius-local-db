#!/usr/bin/env bash

set -e
set -o xtrace

source ./vars.sh

psql $DB_NAME -f $1
