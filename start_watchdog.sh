#!/bin/bash

# Set up environment
export HOME=/home/ots
export PATH=$HOME/.opentakserver_venv/bin:$PATH
export PYTHONPATH=$HOME/.opentakserver_venv/lib/python3.10/site-packages

# Function to check if RabbitMQ is ready
wait_for_rabbitmq() {
    echo "Waiting for RabbitMQ to be ready..."
    for i in {1..30}; do
        if sudo rabbitmqctl status >/dev/null 2>&1; then
            echo "RabbitMQ is ready!"
            return 0
        fi
        echo "Waiting for RabbitMQ... attempt $i/30"
        sleep 2
    done
    return 1
}

# Function to start OpenTAKServer
start_opentakserver() {
    cd ${HOME}/ots
    wait_for_rabbitmq
    ${HOME}/.opentakserver_venv/bin/opentakserver &
    PID=$!
    echo $PID > /tmp/opentakserver.pid
}

# Function to check if process is running
check_process() {
    if [ -f /tmp/opentakserver.pid ]; then
        PID=$(cat /tmp/opentakserver.pid)
        if ps -p $PID > /dev/null; then
            return 0
        fi
    fi
    return 1
}

# Main watchdog loop
while true; do
    if ! check_process; then
        echo "OpenTAKServer not running. Starting..."
        start_opentakserver
        sleep 5
    fi
    sleep 5
done 