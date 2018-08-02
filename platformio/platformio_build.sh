#!/bin/sh

# Install Python platformio 
# pip install -U platformio

# Update library
# git fetch
# git pull

# Build example(s)
platformio ci --lib=".." --project-conf=platformio.ini ../examples/SerialTerminal/SerialTerminal.ino
