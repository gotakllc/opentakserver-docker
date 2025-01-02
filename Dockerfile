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
    EXPOSE 80
    EXPOSE 443
    EXPOSE 1883
    EXPOSE 1935
    EXPOSE 1936
    EXPOSE 5672
    EXPOSE 8000/udp
    EXPOSE 8001/udp
    EXPOSE 8080
    EXPOSE 8081
    EXPOSE 8088
    EXPOSE 8089
    EXPOSE 8189
    EXPOSE 8443
    EXPOSE 8446
    EXPOSE 8322
    EXPOSE 8554
    EXPOSE 8883
    EXPOSE 8888
    EXPOSE 8889
    EXPOSE 8890/udp
    EXPOSE 9997
    EXPOSE 25672
    EXPOSE 64738
    EXPOSE 64738/udp
    
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
    