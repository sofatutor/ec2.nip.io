# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update the package index and install common dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    vim \
    python3 \
    python3-dev \
    python3-pip \
    zsh \
    awscli \
    dnsutils \
    software-properties-common

# Install starship prompt
RUN sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --force \
    && echo 'eval "$(starship init zsh)"' >> /root/.zshrc \
    && mkdir -p /root/.config

COPY starship.toml /root/.config/

# Install docker
RUN curl -fsSL https://get.docker.com | sh

# Add environment variable for the prompt
ENV SHELL /usr/bin/zsh

# Set the default command to start a ZSH shell
CMD ["zsh"]
