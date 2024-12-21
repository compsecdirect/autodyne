#!/bin/bash

# Autodyne compose generator
# Oct 23, 2023
# Creates docker-compose.yml based on the amount of sample files present in the target folder
# This reduces the need to manually add entries into compose files.
# Requires python3

EMULATOR=0
SUBNET