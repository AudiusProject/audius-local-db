#!/usr/bin/env bash

set -e
set -o xtrace

rm -f discProfProduction.dump
wget https://audius-pgdump.s3.us-west-2.amazonaws.com/discProvProduction.dump
