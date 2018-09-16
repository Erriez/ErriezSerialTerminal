#!/bin/sh

# Install Python platformio 
# pip install -U platformio

# Update library
# git fetch
# git pull

# Build example(s)
platformio ci --lib=".." --board uno --board micro --board d1_mini --board nanoatmega328 --board pro16MHzatmega328 --board pro8MHzatmega328 --board leonardo --board megaatmega2560 --board due --board d1_mini --board nodemcuv2 --board lolin_d32 ../examples/SerialTerminal/SerialTerminal.ino
