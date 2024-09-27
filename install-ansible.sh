#!/bin/bash

# Prevent interactive prompts during package installation
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y

# Install Ansible
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ansible
