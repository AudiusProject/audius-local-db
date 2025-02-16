#!/usr/bin/env bash

set -e
set -o xtrace

source ./vars.sh

psql -d $DB_NAME -A -F"," -f $1 > temp.csv

# remove final line of file, move intermediate file to final file
head -n -1 temp.csv > eligible_handles.csv
rm temp.csv
