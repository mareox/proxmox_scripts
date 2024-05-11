#!/bin/bash

# Get a list of all devices with the "night-sleep" tag
devices_to_suspend=$(pvesh get /nodes/<node>/qemu --output-format json | jq -r '.[] | select(.tags | contains(["night-sleep"])) | .vmid')
containers_to_suspend=$(pvesh get /nodes/<node>/lxc --output-format json | jq -r '.[] | select(.tags | contains(["night-sleep"])) | .vmid')

# Exclude devices with the "always-on" tag
devices_to_exclude=$(pvesh get /nodes/<node>/qemu --output-format json | jq -r '.[] | select(.tags | contains(["always-on"])) | .vmid')
containers_to_exclude=$(pvesh get /nodes/<node>/lxc --output-format json | jq -r '.[] | select(.tags | contains(["always-on"])) | .vmid')

# Function to handle errors
handle_error() {
    local exit_code=$1
    local message=$2
    echo "Error: $message"
    exit $exit_code
}

# Suspend VMs
for vmid in $devices_to_suspend; do
    if [[ ! "$devices_to_exclude" =~ "$vmid" ]]; then
        echo "Suspending VM $vmid"
        qm suspend $vmid || handle_error 1 "Failed to suspend VM $vmid"
    fi
done

# Suspend LXC containers
for ctid in $containers_to_suspend; do
    if [[ ! "$containers_to_exclude" =~ "$ctid" ]]; then
        echo "Suspending LXC container $ctid"
        pct suspend $ctid || handle_error 1 "Failed to suspend LXC container $ctid"
    fi
done

echo "Devices suspended successfully."
