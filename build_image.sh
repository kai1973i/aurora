#!/bin/bash

# Docker-Image bauen
docker build -t aurora-app . --network=host

echo "Docker-Image wurde erfolgreich erstellt."

docker run -d -p 5173:5173 --name aurora-container aurora-app

echo "Docker-Container wurde erfolgreich gestartet."

