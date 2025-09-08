#!/bin/bash
# ================================================================
# Initial User Data Script
# ================================================================
# Variables injected by Terraform templatefile function:
# - project_name: Name of the project for directory creation

set -e

# Update system
apt-get update
apt-get upgrade -y

# Install basic packages
apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    htop \
    ufw \
    fail2ban

# Create project directory
mkdir -p /opt/"${project_name}"

# Log setup progress
echo "$(date): Initial setup completed" >> /var/log/immich-setup.log