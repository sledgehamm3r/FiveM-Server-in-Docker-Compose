# QBCore Setup Skript

Dieses Skript ermöglicht eine einfache Einrichtung eines QBCore-basierten FiveM-Servers unter Debian/Ubuntu. 
Es prüft und installiert (falls gewünscht) Docker und Docker Compose, erstellt ein entsprechendes Docker-Image und startet anschließend den FiveM-Server mit QBCore-Framework und ausgewählten Ressourcen (z. B. `qb-core`, `qb-ambulancejob`, `qb-policejob`).
Dieser Script ist als Hilfestellung für Harry. Grüße gehen raus.

## Voraussetzungen

- Ein Debian/Ubuntu Server
- Root-Zugriff oder ausreichende Rechte, um Pakete zu installieren und Docker auszuführen
- Ein gültiger FiveM-Lizenzschlüssel (FiveM Server Key), erhältlich unter [https://keymaster.fivem.net](https://keymaster.fivem.net)

## Enthaltene Ressourcen

- **[qb-core](https://github.com/qbcore-framework/qb-core)**
- **[qb-ambulancejob](https://github.com/qbcore-framework/qb-ambulancejob)**
- **[qb-policejob](https://github.com/qbcore-framework/qb-policejob)**

Diese Ressourcen werden automatisch über Git in die Server-Struktur geklont.

## Vorgehensweise

1. **Script herunterladen**:  
   Lade das Skript auf deinen Server herunter oder clone dieses Repo.
   ```bash
   git clone https://github.com/sledgehamm3r/FiveM-Server-in-Docker-Compose.git
   cd FiveM-Server-in-Docker-Compose`` 

2.  **Ausführbar machen (falls nötig)**:
    
  
    `chmod +x setup.sh` 
    
3.  **Skript ausführen**:
    
    `./setup.sh` 
    
4.  **Abfrage nach Docker/Docker Compose Installation**:  
    Falls Docker oder Docker Compose nicht installiert sind, wirst du gefragt, ob diese installiert werden sollen. Antworte mit `y`, um die Installation automatisch durchzuführen.
    
5.  **IP-Adresse eingeben**:  
    Gib die öffentliche IP-Adresse deines Servers an. Diese wird in der `server.cfg` für den FiveM-Server konfiguriert.
    
6.  **License Key eingeben**:  
    Gib deinen gültigen FiveM License Key ein, um den Server lizenzieren und starten zu können.
    

Anschließend werden die notwendigen Dateien (`Dockerfile`, `server.cfg`, `docker-compose.yml`) erstellt, das Docker-Image gebaut und der Container gestartet.

## Nutzung des Servers

Nach erfolgreicher Installation läuft der QBCore-Server im Hintergrund. Du kannst die Logs mit folgendem Befehl einsehen:

`docker logs qbcore_server` 

Um den Container zu stoppen:



`docker compose down` 

Um den Container neu zu starten:

`docker compose up -d` 

## Anpassungen

-   **server.cfg**: Im Ordner `qbcore-docker` findest du die generierte `server.cfg`. Hier kannst du Einstellungen wie Hostname, Max Clients, Ressourcen oder das RCON-Passwort anpassen.
-   **Dockerfile** / **docker-compose.yml**: Bei Bedarf kannst du weitere Ressourcen oder Plugins hinzufügen, indem du diese im `Dockerfile` oder als zusätzliche Services in `docker-compose.yml` konfigurierst.

## Fehlerbehebung

-   **Fehlende Rechte**: Stelle sicher, dass du das Skript mit ausreichenden Rechten (root oder via `sudo`) ausführst.
-   **Fehlende Docker-Installation**: Wenn du die Installation von Docker/Docker Compose abbrichst, aber nicht bereits installiert hast, kann das Skript nicht erfolgreich ausgeführt werden. Installiere Docker manuell oder führe das Skript erneut aus und stimme der Installation zu.

## Lizenz

Dieses Skript steht unter der [MIT License](LICENSE).
