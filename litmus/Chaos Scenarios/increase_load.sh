#!/bin/bash

# Function to perform a trial
perform_trial() {
    TRIAL=$1
    echo "-------------Start Trial ${TRIAL} $(date "+%Y-%m-%d %H:%M:%S")"
    
    # Wait for 30 seconds
    sleep 30

    # Increase number of users
    curl --location 'http://localhost:8822/swarm' \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode 'user_count=15' \
    --data-urlencode 'spawn_rate=0.5'

    echo "-------------Chaos injected: $(date "+%Y-%m-%d %H:%M:%S")"

    # Wait for 2 minutes
    sleep 120

    # Decrease number of users
    curl --location 'http://localhost:8822/swarm' \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode 'user_count=5' \
    --data-urlencode 'spawn_rate=1'
    echo "-------------Chaos Removed: $(date "+%Y-%m-%d %H:%M:%S")"

    echo "-------------Cool Down Time $(date "+%Y-%m-%d %H:%M:%S")"

    # Wait for 30 seconds
    sleep 360

    echo "-------------Trial ${TRIAL} over $(date "+%Y-%m-%d %H:%M:%S")"
}

# Perform the trials
perform_trial 1
perform_trial 2
perform_trial 3
