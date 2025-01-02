# OpenTAKServer Docker

This repository provides a Docker-based setup for **[OpenTAKServer](https://opentakserver.io/)**, bundling the official Ubuntu Installer Script, RabbitMQ, MediaMTX, Nginx, and more in a containerized environment. It aims to offer a quick way to spin up an OpenTAKServer environment with proper service monitoring and SSL certificate handling.

## Features

- **Automated OTS Installation**: Uses the official [Ubuntu Installer Script](https://github.com/brian7704/OpenTAKServer-Installer)
- **Service Monitoring**: Includes watchdog script to ensure OpenTAKServer stays running
- **MediaMTX Integration**: Separate container for streaming functionality with proper SSL certificate sharing
- **Automated Certificate Management**: Proper handling of SSL certificates between services
- **Non-Interactive Installation**: Automated responses for ZeroTier and Mumble prompts

## Quick Start

1. Clone this repository:
```bash
git clone <repository-url>
cd opentakserver-docker
```

2. Build and start the containers:
```bash
docker-compose up -d
```

3. Check the logs:
```bash
docker-compose logs -f
```

## Components

- **OpenTAKServer Container**:
  - Ubuntu 24.10 base
  - OpenTAKServer with all dependencies
  - RabbitMQ message broker
  - Nginx reverse proxy
  - Service watchdog

- **MediaMTX Container**:
  - Latest MediaMTX version
  - Shared SSL certificates
  - Multiple streaming protocol support

## Configuration

### Volumes

- `ots_certs`: Shared volume for SSL certificates between containers

### Environment Variables

Default environment variables in the containers:
```env
DEBIAN_FRONTEND=noninteractive
TZ=America/New_York
PYTHONUNBUFFERED=1
EVENTLET_NO_GREENDNS=yes
FLASK_APP=opentakserver.app
FLASK_ENV=production
```

### Ports

Below is the complete list of ports exposed by the containers:

| Port      | Service       | Protocol  | Purpose                                          |
|-----------|---------------|-----------|--------------------------------------------------|
| 80        | Nginx         | TCP       | HTTP traffic to OTS UI                           |
| 443       | Nginx         | TCP       | HTTPS traffic to OTS UI                          |
| 1883      | RabbitMQ     | TCP       | MQTT (unencrypted)                               |
| 1935      | MediaMTX     | TCP       | RTMP streaming                                    |
| 1936      | MediaMTX     | TCP       | RTMPS (encrypted RTMP)                           |
| 5672      | RabbitMQ     | TCP       | AMQP protocol                                    |
| 8000      | MediaMTX     | UDP       | RTP streaming                                    |
| 8001      | MediaMTX     | UDP       | RTCP streaming                                   |
| 8080      | Nginx        | TCP       | HTTP proxy to OTS                                |
| 8081      | OTS          | TCP       | Direct OTS access                                |
| 8088      | OTS          | TCP       | TCP CoT                                          |
| 8089      | OTS          | TCP       | SSL CoT                                          |
| 8189      | MediaMTX     | UDP       | WebRTC                                          |
| 8443      | Nginx        | TCP       | HTTPS proxy to OTS                               |
| 8446      | Nginx        | TCP       | Certificate enrollment                           |
| 8322      | MediaMTX     | TCP       | RTSP(S)                                         |
| 8554      | MediaMTX     | TCP       | RTSP                                            |
| 8883      | RabbitMQ     | TCP       | MQTT (encrypted)                                 |
| 8888      | MediaMTX     | TCP       | HLS                                             |
| 8889      | MediaMTX     | TCP       | WebRTC                                          |
| 8890      | MediaMTX     | UDP       | SRT                                             |
| 9997      | MediaMTX     | TCP       | API                                             |
| 25672     | RabbitMQ     | TCP       | Inter-node and CLI tool communication           |
| 64738     | Mumble       | TCP/UDP   | Voice communication (if enabled)                 |

All these ports are defined in the `docker-compose.yml` file and can be modified as needed. Note that some ports (like UDP ports) require specific protocol handling in your Docker configuration.

## Service Management

The containers use two main scripts for service management:

- `start_all.sh`: Manages RabbitMQ, Nginx, and MediaMTX services
- `start_watchdog.sh`: Monitors and auto-restarts OpenTAKServer if needed

## Troubleshooting

### Common Issues

1. **Certificate Errors**:
   - Check permissions on the shared certificate volume
   - Ensure certificates are in the correct format for Nginx

2. **Service Start Failures**:
   - Check logs: `docker-compose logs -f`
   - Verify service permissions and ownership
   - Check certificate paths and permissions

3. **OpenTAKServer Crashes**:
   - The watchdog should automatically restart it
   - Check logs for specific error messages

## Development

To modify or extend this setup:

1. Edit the Dockerfile or docker-compose.yml
2. Rebuild the containers:
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- OpenTAKServer Team
- MediaMTX Project
- Docker Community

---

For more information, visit the [OpenTAKServer website](https://opentakserver.io/).
```