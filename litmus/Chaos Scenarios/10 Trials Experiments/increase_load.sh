#!/bin/bash

# Function to perform a trial
perform_trial() {
    TRIAL=$1
    echo "-------------Start Trial ${TRIAL} $(date "+%Y-%m-%d %H:%M:%S")"
    
    # Wait for 30 seconds
    sleep 60

    # Increase number of users
    curl --location 'http://localhost:8822/swarm' \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode 'user_count=15' \
    --data-urlencode 'spawn_rate=0.5'

    echo "-------------Chaos injected: $(date "+%Y-%m-%d %H:%M:%S")"

    # Wait for 3 minutes
    sleep 180

    # Decrease number of users
    curl --location 'http://localhost:8822/swarm' \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode 'user_count=5' \
    --data-urlencode 'spawn_rate=1'
    echo "-------------Chaos Removed: $(date "+%Y-%m-%d %H:%M:%S")"

    echo "-------------Cool Down Time $(date "+%Y-%m-%d %H:%M:%S")"

    # Wait for 30 seconds
    sleep 60

    echo "-------------Trial ${TRIAL} over $(date "+%Y-%m-%d %H:%M:%S")"
}

# Perform the trials
perform_trial 1
perform_trial 2
perform_trial 3
perform_trial 4
perform_trial 5
perform_trial 6
perform_trial 7
perform_trial 8
perform_trial 9
perform_trial 10
