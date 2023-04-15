#!/usr/bin/env bash

set -e
set -o xtrace

export DB_NAME=audius_discovery_dump
export DUMP_FILE_NAME=discProvProduction.dump
export DUMP_URL=https://audius-pgdump.s3.us-west-2.amazonaws.com/discProvProduction.dump
