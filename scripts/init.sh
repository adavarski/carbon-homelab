#!/usr/bin/env bash

echo ""
echo "░ This script will boot and provision the       "
echo "░ delivery and management clusters, and deploy  "
echo "░ the delivery apps.                            "
echo ""

cd delivery
source init.sh

cd ..

cd management
source init.sh

exit 0
