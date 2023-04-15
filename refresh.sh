#!/usr/bin/env bash

set -e
set -o xtrace

source ./vars.sh

psql $DB_NAME << EOF
drop schema public cascade;
create schema public;
EOF

pg_restore -d $DB_NAME $DUMP_FILE_NAME
