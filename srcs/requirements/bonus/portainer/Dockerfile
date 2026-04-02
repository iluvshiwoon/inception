FROM debian:bookworm

# We only install wget and ca-certificates. 
# We DO NOT try to install or purge tar, as it's already built into Debian.
RUN apt-get update && apt-get install -y wget ca-certificates --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Download and extract Portainer
RUN wget https://github.com/portainer/portainer/releases/download/2.19.4/portainer-2.19.4-linux-amd64.tar.gz && \
    tar -xvf portainer-2.19.4-linux-amd64.tar.gz && \
    rm portainer-2.19.4-linux-amd64.tar.gz

EXPOSE 9000

# The binary is located in the extracted 'portainer' folder
CMD ["./portainer/portainer"]
