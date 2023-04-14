#!/usr/bin/env bash

set -e
set -o xtrace

DB_NAME=audius_discovery_dump
FILE_NAME=discProvProduction.dump

psql $DB_NAME << EOF
drop schema public cascade;
create schema public;
EOF

pg_restore -d $DB_NAME $FILE_NAME
