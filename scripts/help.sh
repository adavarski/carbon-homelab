#!/usr/bin/env bash

source scripts/header.sh

# Print help message with available commands
echo ""
echo "Usage: ./homelab-carbon <command>"
echo ""
echo "Available commands:"
echo ""
ls scripts | grep -v "header.sh\|help.sh" | sed 's/^/- /' | sed 's/\.sh//'
echo ""

exit 0
