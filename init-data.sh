#!/usr/bin/env bash

set -e

mkdir -p data/.cache
cp config.yml data
chown -R 1001:1001 data/config.yml
chown -R 1001:1001 data
chmod 775 data/.cache
chmod g+s data/.cache
