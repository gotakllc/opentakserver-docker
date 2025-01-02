# OpenTAKServer Docker

This repository provides a Docker-based setup for **[OpenTAKServer](https://opentakserver.io/)**, bundling the official Ubuntu Installer Script, RabbitMQ, MediaMTX, Nginx, and more, all in a single container. It aims to offer a quick way to spin up an all-in-one OpenTAKServer environment for testing or development.

> **Important**  
> - The official Ubuntu installer is **interactive** and expects user inputs. Here, we’ve forcibly disabled certain prompts (e.g., ZeroTier, Mumble) to avoid blocking the Docker build process.  
> - **Systemd services** (e.g., `opentakserver`, `rabbitmq-server`, `nginx`, etc.) are typically not run inside Docker containers via `systemd`. This setup uses a simple `start_all.sh` script (or any other supervisor approach) to start them.

---

## Table of Contents

1. [Features](#features)  
2. [Prerequisites](#prerequisites)  
3. [Directory Structure](#directory-structure)  
4. [Usage](#usage)  
   - [Building the Image](#building-the-image)  
   - [Running the Container](#running-the-container)  
   - [Stopping & Removing Containers](#stopping--removing-containers)  
5. [Configuration](#configuration)  
   - [Exposed Ports](#exposed-ports)  
   - [Adjusting ZeroTier/Mumble Installs](#adjusting-zerotiermumble-installs)  
6. [Troubleshooting](#troubleshooting)  
7. [Further Reading](#further-reading)  
8. [License](#license)

---

## Features

- **Automated OTS Installation**: Leverages the official [Ubuntu Installer Script](https://i.opentakserver.io/ubuntu_installer) to install OpenTAKServer and dependencies.  
- **All-in-One Image**: RabbitMQ, MediaMTX, Nginx, and OTS run together in a single container.  
- **Simple Startup**: A basic script (`start_all.sh`) starts all necessary services in the foreground.  
- **Extensive Port Exposure**: Exposes the default ports used by OTS and related services.  

---

## Prerequisites

- **Docker**: v19+ recommended  
- **Docker Compose**: v1.29+ or Docker Compose Plugin v2+  
- At least 2 GB of memory available to the container (the combination of services can be resource-intensive).

---

## Directory Structure

A sample project layout might look like this:

```
.
├── docker-compose.yml
├── Dockerfile
├── README.md
└── start_all.sh
```

- **Dockerfile**  
  Defines the container environment and runs the official OTS Ubuntu installer script.  
- **start_all.sh**  
  Simple script to start all services (RabbitMQ, Nginx, MediaMTX, OpenTAKServer) in the foreground for Docker.  
- **docker-compose.yml**  
  Declares how to build and run your container with the necessary port mappings.

---

## Usage

### Building the Image

1. **Clone this repository** (or copy the Dockerfile, `docker-compose.yml`, and `start_all.sh` into your own folder).
2. Open a terminal in that folder.
3. Run the build command:

   ```bash
   docker-compose build
   ```

   This may take a while, as it installs a full Ubuntu environment plus all OTS dependencies.

### Running the Container

Once built, start the container:

```bash
docker-compose up -d
```

This starts your container in detached mode. The `Dockerfile` and `docker-compose.yml` will:

1. Create a non-root user `ots` (with sudo rights) in the container.  
2. Download and patch the official installer script to avoid blocking prompts.  
3. Install all necessary packages (Python, RabbitMQ, Nginx, MediaMTX, etc.).  
4. Run `start_all.sh` to launch services inside the container.

**Check logs**:

```bash
docker-compose logs -f
```

Look for lines indicating that `opentakserver`, `rabbitmq-server`, `nginx`, and `mediamtx` are running.

### Stopping & Removing Containers

Stop the running container:

```bash
docker-compose stop
```

Remove the container if needed:

```bash
docker-compose rm
```

Remove images as well (to rebuild from scratch):

```bash
docker-compose down --rmi all
```

---

## Configuration

### Exposed Ports

Below is a subset of the **default** ports exposed by the container (based on the script and your config). Refer to the `docker-compose.yml` file for the complete list.

| Port   | Service       | Protocol  | Purpose                                                                 |
|--------|---------------|-----------|-------------------------------------------------------------------------|
| 80     | Nginx         | TCP       | Unencrypted HTTP traffic to OTS UI                                      |
| 443    | Nginx         | TCP       | Encrypted HTTPS traffic to OTS UI                                       |
| 1883   | RabbitMQ      | TCP       | MQTT (unencrypted), used by Meshtastic                                  |
| 1935   | MediaMTX      | TCP       | RTMP streaming                                                          |
| 5672   | RabbitMQ      | TCP       | AMPQ clients, typically internal                                        |
| 8080   | Nginx         | TCP       | Proxy for HTTP requests to OTS port 8081                                |
| 8081   | OpenTAKServer | TCP       | Internal OTS listener (might be loopback in a VM)                       |
| 8088   | OpenTAKServer | TCP       | TCP CoT streaming                                                       |
| 8089   | OpenTAKServer | TCP       | SSL CoT streaming                                                       |
| 8443   | Nginx         | TCP       | HTTPS proxy for OTS port 8081                                           |
| 8446   | Nginx         | TCP       | Certificate enrollment proxy to OTS                                     |
| 8883   | RabbitMQ      | TCP       | Encrypted MQTT port (Meshtastic)                                        |
| 64738  | Mumble Server | TCP/UDP   | Mumble voice streams (disabled in script by default)                    |
| ...    | ...           | ...       | ...                                                                     |

*You can modify which ports get mapped in `docker-compose.yml` according to your needs.*

### Adjusting ZeroTier/Mumble Installs

In this setup, we **removed** the interactive prompts for ZeroTier and Mumble installation. If you do want to install these services, you’ll need to:

- Remove or comment out the lines in `Dockerfile` that use `sed -i` to delete the relevant script blocks.  
- Provide an automated way for the script to handle `read -p` prompts (e.g., set environment variables or integrate a pseudo-TTY approach).  

---

## Troubleshooting

1. **Container Exits Immediately**  
   - Check for errors in `docker-compose logs`. The start script might have failed if a service refused to start or if the OTS installer encountered an error.

2. **Services Not Running**  
   - In the default approach, we’re calling `sudo service <name> start`. Depending on changes in your distribution or container environment, you may need to adjust or switch to a supervisor approach (e.g., [supervisord](http://supervisord.org/), [s6-overlay](https://github.com/just-containers/s6-overlay), or [runit](https://smarden.org/runit/)).

3. **High Resource Usage**  
   - Running all of these services in a single container can be resource-heavy. Consider increasing Docker memory limits or splitting services into separate containers.

4. **SSL/TLS Certificates**  
   - The script generates a self-signed CA and server certificate. In a real production environment, consider using valid certificates from Let’s Encrypt or another CA.

---

## Further Reading

- [OpenTAKServer Official Website](https://opentakserver.io/)  
- [OpenTAKServer GitHub](https://github.com/AdvancedAviationTeam/OpenTAKServer)  
- [Docker Documentation](https://docs.docker.com/)  
- [Docker Compose Documentation](https://docs.docker.com/compose/)  

---

## License

The Dockerfile and scripts in this repository are distributed under the [MIT License](./LICENSE) (if you choose to include one). The **OpenTAKServer** code and its **Ubuntu Installer Script** are each under their respective licenses. Always refer to their repositories for licensing details.

---

> **Disclaimer**: This repository is an unofficial containerization approach for OpenTAKServer. Use it at your own discretion and test thoroughly before deploying to production.
```