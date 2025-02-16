#!/usr/bin/env bash

set -e
set -o xtrace

export DB_NAME=audius_discovery_dump
export DUMP_FILE_NAME=discProvProduction-2025-01-20.dump
export DUMP_URL=https://audius-pgdump.s3.us-west-2.amazonaws.com/discProvProduction-2025-01-20.dump
