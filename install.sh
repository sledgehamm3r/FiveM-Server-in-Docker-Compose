#!/usr/bin/env bash
set -e

print_header() {
    clear
    echo -e "\e[1;34m=========================================\e[0m"
    echo -e "\e[1;34m  Copyright 2024 © sledgehamm3r\e[0m"
    echo -e "\e[1;34m=========================================\e[0m\n"
}

print_header

DOCKER_INSTALLED=true
if ! command -v docker &> /dev/null; then
    DOCKER_INSTALLED=false
fi

COMPOSE_INSTALLED=true
if ! command -v docker compose &> /dev/null; then
    COMPOSE_INSTALLED=false
fi

if [ "$DOCKER_INSTALLED" = false ] || [ "$COMPOSE_INSTALLED" = false ]; then
    print_header
    read -p "Docker und Docker Compose wurden nicht gefunden oder sind unvollständig installiert. Möchten Sie beides installieren? (y/n): " INSTALL_DOCKER
    print_header
    if [ "$INSTALL_DOCKER" = "y" ] || [ "$INSTALL_DOCKER" = "Y" ]; then
        # Docker installieren
        apt-get update
        apt-get install -y ca-certificates curl gnupg lsb-release
        mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/debian $(lsb_release -cs) stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        apt-get update
        apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        
        # Prüfen ob jetzt docker verfügbar ist
        if ! command -v docker &> /dev/null; then
            print_header
            echo "Fehler bei der Installation von Docker."
            exit 1
        fi
        
        # Prüfen ob jetzt docker compose verfügbar ist
        if ! command -v docker compose &> /dev/null; then
            print_header
            echo "Fehler bei der Installation von Docker Compose."
            exit 1
        fi
        
        print_header
        echo "Docker und Docker Compose erfolgreich installiert."
    else
        print_header
        echo "Installation von Docker/Docker Compose übersprungen."
        if [ "$DOCKER_INSTALLED" = false ]; then
            echo "Docker ist nicht installiert. Das Skript kann nicht fortfahren."
            exit 1
        fi
        if [ "$COMPOSE_INSTALLED" = false ]; then
            echo "Docker Compose ist nicht installiert. Das Skript kann nicht fortfahren."
            exit 1
        fi
    fi
fi

print_header
# Abfrage der IP-Adresse
read -p "Bitte geben Sie die IP-Adresse für den Server ein: " SERVER_IP
print_header
if [ -z "$SERVER_IP" ]; then
    echo "Keine IP-Adresse eingegeben, Skript wird abgebrochen."
    exit 1
fi

print_header
# Abfrage des Lizenzkeys
read -p "Bitte geben Sie Ihren FiveM License Key ein: " LICENSE_KEY
print_header
if [ -z "$LICENSE_KEY" ]; then
    echo "Kein License Key eingegeben, Skript wird abgebrochen."
    exit 1
fi

print_header
# Arbeitsverzeichnis anlegen
mkdir -p qbcore-docker
cd qbcore-docker

# Dockerfile erstellen
cat > Dockerfile <<EOF
FROM debian:stable-slim

# Systemupdates & notwendige Pakete für den FiveM Server
RUN apt-get update && \
    apt-get install -y wget xz-utils libatomic1 screen git ca-certificates && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# FiveM Server installieren (feste Version verwenden)
ENV FX_VERSION=7290-a654bcc2adfa27c4e020fc915a1a6343c3b4f921
RUN mkdir -p /fivem && \
    cd /fivem && \
    wget https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/\${FX_VERSION}/fx.tar.xz && \
    tar xf fx.tar.xz && \
    rm fx.tar.xz

# QBCore herunterladen
RUN mkdir -p /fivem/server-data/resources/[qb] && \
    cd /fivem/server-data/resources/[qb] && \
    git clone https://github.com/qbcore-framework/qb-core.git && \
    git clone https://github.com/qbcore-framework/qb-ambulancejob.git && \
    git clone https://github.com/qbcore-framework/qb-policejob.git

# Lokale server.cfg einspielen
COPY server.cfg /fivem/server-data/server.cfg

# Arbeitsverzeichnis
WORKDIR /fivem

# Ports
EXPOSE 30120/udp
EXPOSE 30120/tcp

# Server-Startbefehl
CMD ["bash", "-c", "./run.sh +exec server-data/server.cfg"]
EOF

# server.cfg erstellen, IP und LicenseKey einfügen
cat > server.cfg <<EOF
sv_hostname "Mein QBCore Server"
sv_maxclients 32

endpoint_add_tcp "${SERVER_IP}:30120"
endpoint_add_udp "${SERVER_IP}:30120"

ensure qb-core
ensure qb-ambulancejob
ensure qb-policejob

sv_licenseKey "${LICENSE_KEY}"

rcon_password "geheim"
EOF

# docker-compose.yml erstellen
cat > docker-compose.yml <<EOF
version: '3.9'
services:
  qbcore:
    build: .
    container_name: qbcore_server
    ports:
      - "30120:30120/udp"
      - "30120:30120/tcp"
    restart: unless-stopped
EOF

print_header
echo "Erstelle Docker-Image ..."
docker compose build

print_header
echo "Starte Container ..."
docker compose up -d

print_header
echo "Setup abgeschlossen."
echo "Server läuft im Hintergrund. Logs mit 'docker logs qbcore_server' einsehen."
