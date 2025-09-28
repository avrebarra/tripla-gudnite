#!/bin/bash

# # Ensure .ssh directory exists and set permissions
# mkdir -p /home/vscode/.ssh
# sudo chown -R vscode:vscode /home/vscode/.ssh
# sudo chmod 700 /home/vscode/.ssh
# sudo chmod 600 /home/vscode/.ssh/* 2>/dev/null || true

# # Set up RubyGems environment
# if ! grep -q 'export GEM_HOME=/home/vscode/.gem' /home/vscode/.bashrc; then
#   echo 'export GEM_HOME=/home/vscode/.gem' >> /home/vscode/.bashrc
# fi
# if ! grep -q 'export PATH=$GEM_HOME/bin:$PATH' /home/vscode/.bashrc; then
#   echo 'export PATH=$GEM_HOME/bin:$PATH' >> /home/vscode/.bashrc
# fi
# mkdir -p /home/vscode/.gem
