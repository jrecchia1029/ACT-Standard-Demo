#!/bin/bash
# ~/start-github-runner.sh

# Path to your runner directory
RUNNER_DIR="/home/cvpadmin/github/actions-runner"

# Change to runner directory
cd "$RUNNER_DIR"

# Start the runner in the background
nohup ./run.sh > "$RUNNER_DIR/runner.log" 2>&1 &

# Optional: Log the startup
echo "$(date): GitHub runner started" >> "$RUNNER_DIR/startup.log"