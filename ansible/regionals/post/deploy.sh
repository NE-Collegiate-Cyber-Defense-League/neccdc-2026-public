#!/bin/bash

# Exit immediately if any command fails
set -e

# List of directories containing playbook.yaml
directories=(
    "pfsense"
    "wordpress"
    # "windows"
    "dns"
    "grafana"
    "kiosk"
    "teleport"
    "semaphore"
)

echo "Starting deployment..."
echo "===================="

# Iterate through each directory and run ansible-playbook
for dir in "${directories[@]}"; do
    if [ -d "$dir" ] && [ -f "$dir/playbook.yaml" ]; then
        echo ""
        echo "Running playbook in $dir..."
        cd "$dir"
        ansible-playbook playbook.yaml
        cd ..
        echo "✓ $dir completed successfully"
    else
        echo "⚠ Warning: $dir/playbook.yaml not found, skipping..."
    fi
done

echo ""
echo "===================="
echo "All deployments completed successfully!"
