#!/usr/bin/env bash

echo ""
echo "░ This script will destroy all resources created"
echo "░ by the scripts in this repo.                  "
echo ""

kind delete clusters delivery
kind delete clusters management
docker system prune -f

exit 0
