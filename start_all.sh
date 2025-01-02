#!/usr/bin/env bash
# start_all.sh
# 
# Very simplistic approach: start each background service,
# then tail logs (or wait in a loop) so the container doesn't exit.

echo "Starting RabbitMQ..."
sudo service rabbitmq-server start

echo "Starting Nginx..."
sudo service nginx start

echo "Starting MediaMTX..."
sudo service mediamtx start

echo "Starting OpenTAKServer..."
sudo service opentakserver start

echo "All services started. Tailing system logs..."

# Simple approach: follow syslog to keep the container alive
# or you can do 'tail -f /var/log/some_service.log'
tail -F /var/log/syslog
