# OpenClaw Gateway - Achims README
Docker starten

# Backup der Konfigurationsdateien erstellen
cp "D:\OpenClawConfig\openclaw.json" "C:\Users\User\OneDrive\Win-Documents\Notizen\Dokumentation\Openclaw\openclaw.json"
cp "D:\Users\User\git\openclaw\.env" "C:\Users\User\OneDrive\Win-Documents\Notizen\Dokumentation\Openclaw\.env"
cp "D:\Users\User\git\openclaw\docker-compose.yml" "C:\Users\User\OneDrive\Win-Documents\Notizen\Dokumentation\Openclaw\docker-compose.yml"
cp "D:\Users\User\git\openclaw\Dockerfile" "C:\Users\User\OneDrive\Win-Documents\Notizen\Dokumentation\Openclaw\Dockerfile"
cp "D:\Users\User\git\openclaw\Achims_README.md" "C:\Users\User\OneDrive\Win-Documents\Notizen\Dokumentation\Openclaw\Achims_README.md"

# Updates holen
git stash
git pull

# Backup Dateien wieder einspielen
cp "C:\Users\User\OneDrive\Win-Documents\Notizen\Dokumentation\Openclaw"/openclaw.json "D:\OpenClawConfig\openclaw.json"
cp "C:\Users\User\OneDrive\Win-Documents\Notizen\Dokumentation\Openclaw"/.env "D:\Users\User\git\openclaw\.env"
cp "C:\Users\User\OneDrive\Win-Documents\Notizen\Dokumentation\Openclaw"/docker-compose.yml "D:\Users\User\git\openclaw\docker-compose.yml"
cp "C:\Users\User\OneDrive\Win-Documents\Notizen\Dokumentation\Openclaw"/Achims_README.md "D:\Users\User\git\openclaw\Achims_README.md"

Dockerfile anpassen:
Anstelle von:
cp "C:\Users\User\OneDrive\Win-Documents\Notizen\Dokumentation\Openclaw"/Dockerfile "D:\Users\User\git\openclaw\Dockerfile"
Füge die Himalaya-Installation und den Pfad in das Dockerfile hinzu (vor den COPY Befehlen):
----
# Himalaya installieren
# Als root installieren, Binary landet standardmäßig in /usr/local/bin
RUN curl -sSL https://raw.githubusercontent.com/pimalaya/himalaya/master/install.sh | \
sh -s -- --root /usr/local

# Falls nötig, sicherstellen, dass /usr/local/bin im PATH ist
ENV PATH="/usr/local/bin:${PATH}"
----

# Neues Image bauen
docker build -t openclaw:local -f Dockerfile .   # -t: Tag für das Image, -f: Dockerfile angeben, .: Kontext (aktuelles Verzeichnis)
docker compose down openclaw-gateway
docker compose up openclaw-gateway

# Normales Starten und stoppen
Starten des Gateways:
docker compose up openclaw-gateway

Stoppen des Gateways:
docker compose down openclaw-gateway

Logs anzeigen:
docker compose logs -f openclaw-gateway

Shell im Container ausführen:
docker compose exec openclaw-gateway bash

ClI im Container ausführen:
node dist/index.js tui --token cafcd22d5b3bb902e02abef2076cf89ff0417a6461c72ed6
# Der Token liegt in openclaw.json


# gmx Mail
Vorname: Helbard
Nachname:Bot
Geb: Datum: 1.1.2010
helbard.bot@gmx.de
Passwort: $GMAIL_PASSWORD
Posteingang (IMAP)
Server: imap.gmx.net
Port: 993
Postausgang (SMTP)
Server: mail.gmx.net
Port: 587

# Skills:
https://clawhub.ai/

# Neues Setup
Achtung. Hierbei wird ein neuer Token erzeugt. Diesen Sieht man nur einmal bei "Dashboard ready"
Man muss den Token ändern in openclaw.json, den Container einmal neu starten und dann eingeben: http://localhost:18789/#token=2446d52b0efd797ea78cd6479203b05a0454efa1ddf30ede
