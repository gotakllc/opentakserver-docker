# --------------------------------------------------------
# Dockerfile to build an image that runs OpenTAKServer
# via the official Ubuntu-based installer script.
# --------------------------------------------------------

    FROM ubuntu:22.04

    # Prevent interactive tzdata prompts
    ENV DEBIAN_FRONTEND=noninteractive
    ENV TZ=Etc/UTC
    
    # --------------------------------------------------------
    # 1) Create non-root user "ots" who can sudo without a password
    # --------------------------------------------------------
    RUN apt-get update && apt-get install -y sudo curl ca-certificates git \
        && rm -rf /var/lib/apt/lists/* \
        && useradd -ms /bin/bash ots \
        && usermod -aG sudo ots \
        && echo "ots ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    
    # --------------------------------------------------------
    # 2) Switch to that user, prepare workspace
    # --------------------------------------------------------
    USER ots
    WORKDIR /home/ots
    
    # --------------------------------------------------------
    # 3) Fetch the OpenTAKServer Ubuntu installer script,
    #    patch out interactive prompts for ZeroTier and Mumble
    # --------------------------------------------------------
    RUN mkdir -p /home/ots/installer && cd /home/ots/installer \
        && curl -sL "https://i.opentakserver.io/ubuntu_installer" -o ./ubuntu_installer.sh \
        && chmod +x ./ubuntu_installer.sh \
        \
        # --- Example hack: remove lines that prompt for ZeroTier & Mumble ---
        # This forcibly disables ZeroTier and Mumble by skipping the questions.
        && sed -i '/read -p.*ZeroTier/,+16d' ./ubuntu_installer.sh \
        && sed -i '/read -p.*Mumble/,+22d' ./ubuntu_installer.sh
    
    # --------------------------------------------------------
    # 4) Run the script non-interactively ( ZeroTier = no, Mumble = no )
    #    The script does "apt update/install" and sets up OTS in systemd.
    # --------------------------------------------------------
    RUN cd /home/ots/installer \
        && ./ubuntu_installer.sh --force 2>&1
    
    # --------------------------------------------------------
    # 5) Expose ports commonly used by OTS
    #    (Below is a superset from your provided list—enable as needed)
    # --------------------------------------------------------
    EXPOSE 80      # Nginx HTTP
    EXPOSE 443     # Nginx HTTPS
    EXPOSE 1883    # RabbitMQ MQTT
    EXPOSE 1935    # MediaMTX RTMP
    EXPOSE 1936    # MediaMTX RTMPS
    EXPOSE 5672    # RabbitMQ AMQP
    EXPOSE 8000    # MediaMTX RTP (UDP)
    EXPOSE 8001    # MediaMTX RTCP (UDP)
    EXPOSE 8080    # Nginx Proxy -> OTS 8081
    EXPOSE 8081    # OTS direct (Loopback in VM, but we’ll expose just in case)
    EXPOSE 8088    # OTS TCP CoT
    EXPOSE 8089    # OTS SSL CoT
    EXPOSE 8189    # MediaMTX WebRTC (UDP)
    EXPOSE 8443    # Nginx HTTPS Proxy -> OTS 8081
    EXPOSE 8446    # Nginx Cert Enrollment -> OTS 8081
    EXPOSE 8322    # MediaMTX RTSP(S)
    EXPOSE 8554    # MediaMTX RTSP
    EXPOSE 8883    # RabbitMQ MQTT (Encrypted)
    EXPOSE 8888    # MediaMTX HLS
    EXPOSE 8889    # MediaMTX WebRTC
    EXPOSE 8890    # MediaMTX SRT (UDP)
    EXPOSE 9997    # MediaMTX API (Loopback typically)
    EXPOSE 25672   # RabbitMQ Federation
    EXPOSE 64738   # Mumble (if installed), but we forcibly disabled it
    
    # --------------------------------------------------------
    # 6) Container start command
    #    The official script sets up systemd services for:
    #      - opentakserver
    #      - rabbitmq
    #      - nginx
    #      - mediamtx
    #    But Docker containers typically don't run full systemd.
    #
    #    Option A: Use "init" or "systemd-like" approaches in Docker 
    #    Option B: Start each service in the foreground (Supervisor approach)
    #
    #    For simplicity, we’ll attempt to bring up all via a small script
    #    that manually starts them in the foreground (supervisord or runit).
    # --------------------------------------------------------
    
    # Copy in a small script that starts all processes in the foreground.
    COPY start_all.sh /home/ots/start_all.sh
    RUN chmod +x /home/ots/start_all.sh
    
    # For best results, consider supervisord, s6-overlay, or similar. 
    # This is a simple all-in-one script approach.
    CMD ["/home/ots/start_all.sh"]
    