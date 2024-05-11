#!/bin/bash

# Get the Proxmox node name
node=$hostname

# Get a list of all devices with the "night-sleep" tag for VMs
devices_to_suspend=$(pvesh get /nodes/$node/qemu --output-format json | jq -r '.[] | select(.tags | contains(["night-sleep"])) | .vmid')
containers_to_suspend=$(pvesh get /nodes/$node/lxc --output-format json | jq -r '.[] | select(.tags | contains(["night-sleep"])) | .vmid')

# Exclude devices with the "always-on" tag for VMs
devices_to_exclude=$(pvesh get /nodes/$node/qemu --output-format json | jq -r '.[] | select(.tags | contains(["always-on"])) | .vmid')
containers_to_exclude=$(pvesh get /nodes/$node/lxc --output-format json | jq -r '.[] | select(.tags | contains(["always-on"])) | .vmid')

# Suspend VMs
for vmid in $devices_to_suspend; do
    if [[ ! "$devices_to_exclude" =~ "$vmid" ]]; then
        echo "Suspending VM $vmid"
        qm suspend $vmid || echo "Failed to suspend VM $vmid"
    fi
done

# Suspend LXC containers
for ctid in $containers_to_suspend; do
    if [[ ! "$containers_to_exclude" =~ "$ctid" ]]; then
        echo "Suspending LXC container $ctid"
        pct suspend $ctid || echo "Failed to suspend LXC container $ctid"
    fi
done

echo "Devices suspended successfully."
