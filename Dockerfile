# --------------------------------------------------------
# Dockerfile to build an image that runs OpenTAKServer
# via the official Ubuntu-based installer script.
# --------------------------------------------------------

    FROM ubuntu:24.10

    # Prevent interactive tzdata prompts and set proper timezone
    ENV DEBIAN_FRONTEND=noninteractive
    ENV TZ=America/New_York
    
    # --------------------------------------------------------
    # 1) Create non-root user "ots" who can sudo without a password
    # --------------------------------------------------------
    RUN apt-get update && apt-get install -y sudo curl python3 python3-pip python3-venv \
        rabbitmq-server openssl nginx ffmpeg libnginx-mod-stream python3-dev tzdata wget git expect \
        && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
        && rm -rf /var/lib/apt/lists/* \
        && useradd -ms /bin/bash ots \
        && usermod -aG sudo ots \
        && echo "ots ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
        && mkdir -p /home/ots/ots/ca /home/ots/ots/logs \
        && chown -R ots:ots /home/ots/ots

    # --------------------------------------------------------
    # 2) Run the installer script with expect
    # --------------------------------------------------------
    USER ots
    WORKDIR /home/ots

    # Download and run installer with expect
    RUN mkdir -p /tmp/ots_installer \
        && cd /tmp/ots_installer \
        && curl -sL "https://raw.githubusercontent.com/brian7704/OpenTAKServer-Installer/refs/heads/master/ubuntu_installer.sh" -o ubuntu_installer.sh \
        && chmod +x ubuntu_installer.sh \
        && expect -c "set timeout -1; \
            spawn ./ubuntu_installer.sh --force; \
            expect \"Would you like to install ZeroTier?\"; \
            send \"n\r\"; \
            expect \"Would you like to install Mumble?\"; \
            send \"n\r\"; \
            expect eof"

    ENV PYTHONUNBUFFERED=1
    ENV EVENTLET_NO_GREENDNS=yes
    ENV FLASK_APP=opentakserver.app
    ENV FLASK_ENV=production

    # --------------------------------------------------------
    # 3) Expose ports commonly used by OTS
    # --------------------------------------------------------
    EXPOSE 80 443 1883 1935 1936 5672 8000/udp 8001/udp 8080 8081 8088 8089 \
           8189 8443 8446 8322 8554 8883 8888 8889 8890/udp 9997 25672 64738 64738/udp
    
    # --------------------------------------------------------
    # 4) Container start command setup
    # --------------------------------------------------------
    USER root
    COPY start_all.sh /home/ots/start_all.sh
    COPY start_watchdog.sh /home/ots/start_watchdog.sh
    RUN chmod +x /home/ots/start_all.sh /home/ots/start_watchdog.sh && \
        chown ots:ots /home/ots/start_all.sh /home/ots/start_watchdog.sh
    USER ots
    
    # Start both the main services and the watchdog
    CMD ["/bin/bash", "-c", "/home/ots/start_all.sh & /home/ots/start_watchdog.sh"]
    