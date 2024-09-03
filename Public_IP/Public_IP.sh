#!/bin/bash

# Dependencies: curl notify (require golang)
# https://github.com/projectdiscovery/notify
# This script was created by Sy3Omda

# Function to get the current public IP address
get_public_ip() {
    curl -s http://checkip.amazonaws.com
}

# Initialize previous IP to an empty string
PREVIOUS_IP=""

while true; do
    # Get the current public IP address
    CURRENT_IP=$(get_public_ip)

    # Check if the IP address has changed
    if [ "$CURRENT_IP" != "$PREVIOUS_IP" ]; then
        # Save the new IP in argument called $IP
        IP=$CURRENT_IP

        # Use notify to send the new IP address
        echo "$IP" | notify -id telegram -silent
	echo "$IP" | notify -id slack -silent
	echo "$IP" | notify -id discord -silent

        # Update the previous IP to the current one
        PREVIOUS_IP=$CURRENT_IP
    fi

    # Wait for 1 minute before checking again
    sleep 60
done
