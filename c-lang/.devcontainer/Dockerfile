FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y \
    gcc \
    build-essential \
    make \
    gdb \
    libc6-dev \
    ncurses-dev \
    git \
    vim \
    python3 \
    python3-pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
