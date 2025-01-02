#!/bin/bash

# Ensure directories exist with proper permissions
sudo mkdir -p /home/ots/ots/ca /home/ots/ots/logs
sudo chown -R ots:ots /home/ots/ots

# Ensure Nginx has access to certificates
sudo mkdir -p /home/ots/ots/ca/certs/opentakserver
sudo chown -R www-data:www-data /home/ots/ots/ca/certs
sudo chmod 644 /home/ots/ots/ca/certs/opentakserver/opentakserver.pem
sudo chmod 644 /home/ots/ots/ca/certs/opentakserver/opentakserver.nopass.key
sudo chmod -R 755 /home/ots/ots/ca/certs/opentakserver

# Start RabbitMQ and wait for it to be ready
echo "Starting RabbitMQ..."
sudo service rabbitmq-server start
sleep 5  # Give RabbitMQ time to initialize

# Start Nginx
echo "Starting Nginx..."
sudo nginx -t  # Test config first
sudo service nginx start

# Start MediaMTX
echo "Starting MediaMTX..."
sudo service mediamtx start

# Keep container running and show logs
tail -f /home/ots/ots/logs/opentakserver.log /var/log/rabbitmq/rabbit@*.log /var/log/nginx/*.log