#!/bin/bash

chown -R ots:ots /home/ots/ots
# Start RabbitMQ and wait for it to be ready
echo "Starting RabbitMQ..."
sudo service rabbitmq-server start
sleep 5  # Give RabbitMQ time to initialize

# Start Nginx
echo "Starting Nginx..."
sudo nginx -t  # Test config first
sudo service nginx start

# Keep container running and show logs
tail -f /home/ots/ots/logs/opentakserver.log /var/log/rabbitmq/rabbit@*.log /var/log/nginx/*.log