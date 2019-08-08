#!/bin/bash
for i in `seq 1 600`; do
    output=$(ssh -q -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $1 'echo connected' 2>&1)
    if [ $? -eq 0 ]; then
        echo -e "$output"
        exit 0
    else
        sleep 1
    fi
done

echo "Failed to SSH to $1 after 10 minutes."
exit 1
