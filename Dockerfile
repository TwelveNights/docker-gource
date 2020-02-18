FROM ubuntu:18.04

# Update the repositories list and install software to add a PPA
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    apt-get install -y git \
        mercurial \
        xvfb \
        xfonts-base \
        xfonts-75dpi \
        xfonts-100dpi \
        xfonts-cyrillic \
        gource \
        screen \
        ffmpeg && \
    apt-get -yq autoremove && \
    apt-get -yq clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

# Add the init script
COPY init.sh /usr/local/bin/init.sh

# Mount volumes
VOLUME ["/repoRoot", "/avatars", "/results"]

# Set the working directory to where the git repository is stored
WORKDIR /repoRoot

# Run the init script by default
CMD [""]
ENTRYPOINT ["bash", "/usr/local/bin/init.sh"]
