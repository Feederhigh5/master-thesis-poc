#!/bin/bash

# Function to perform a trial
perform_trial() {
    TRIAL=$1
    echo "Start Trial ${TRIAL} $(date "+%Y-%m-%d %H:%M:%S")"
    
    # Wait for 30 seconds
    sleep 30

    # Update the yaml file
    yq eval ".deployments.frontend.podAnnotations.deployUpdateTest = \"${TRIAL}\"" -i ./values/bank-of-anthos.yaml

    # Git commit and push
    git add ./values/bank-of-anthos.yaml
    git commit -m "update frontend ${TRIAL}"
    git push

    echo "Update pushed: $(date "+%Y-%m-%d %H:%M:%S")"

    # Wait for 2 minutes
    sleep 120

    echo "Cool Down Time $(date "+%Y-%m-%d %H:%M:%S")"

    # Wait for 30 seconds
    sleep 30

    echo "Trial ${TRIAL} over $(date "+%Y-%m-%d %H:%M:%S")"
}

# Perform the trials
perform_trial 1
perform_trial 2
perform_trial 3
