#!/bin/bash

# Get a list of all devices with the "night-sleep" tag
devices_to_suspend=$(pvesh get /nodes/<node>/qemu --output-format json | jq -r '.[] | select(.tags | contains(["night-sleep"])) | .vmid')

# Exclude devices with the "always-on" tag
devices_to_exclude=$(pvesh get /nodes/<node>/qemu --output-format json | jq -r '.[] | select(.tags | contains(["always-on"])) | .vmid')

# Suspend devices
for vmid in $devices_to_suspend; do
    if [[ ! "$devices_to_exclude" =~ "$vmid" ]]; then
        echo "Suspending VM $vmid"
        qm suspend $vmid
    fi
done

echo "Devices suspended successfully."
