#!/bin/bash

# Docker-Image bauen
docker build -t aurora-app . --network=host

echo "Docker-Image wurde erfolgreich erstellt."