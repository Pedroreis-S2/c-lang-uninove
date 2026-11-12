#!/bin/sh
# Polling funciona mesmo quando o bind mount nao encaminha eventos inotify.
set -e
cd "$(dirname "$0")/.."
exec python3 -u scripts/dev.py
