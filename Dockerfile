# Start with an Ubuntu base image
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies for Flutter
RUN apt-get update && apt-get install -y \
    curl unzip git clang cmake ninja-build pkg-config libgtk-3-dev libgl1-mesa-dev x11-xserver-utils sudo && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user and switch to it
RUN useradd -m flutteruser
USER flutteruser

# Download and install Flutter
RUN curl -LO https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.13.6-stable.tar.xz && \
    tar -xf flutter_linux_3.13.6-stable.tar.xz && \
    mv flutter /opt/flutter && \
    rm flutter_linux_3.13.6-stable.tar.xz

# Fix ownership for Flutter installation
RUN sudo chown -R flutteruser:flutteruser /opt/flutter

# Add Flutter to PATH
ENV PATH="/opt/flutter/bin:${PATH}"

# Enable Flutter web support
RUN flutter config --enable-web

# Set the working directory inside the container
WORKDIR /app

# Copy the namer.app project files into the container
COPY namer_app/ /app/

# Ensure Flutter dependencies are installed
RUN flutter pub get

# Build the Flutter web application
RUN flutter build web

# Expose the default web port
EXPOSE 8080

# Start a simple HTTP server to serve the Flutter web app
CMD ["python3", "-m", "http.server", "8080", "--directory", "/app/build/web"]
