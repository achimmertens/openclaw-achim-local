#!/bin/bash
# Achims_OpenClaw_Build.sh
# git pull, Dockerfile patchen (Python+beem + Himalaya), Image bauen, Gateway neu starten

set -e

echo "Starting Achims_OpenClaw_Build.sh..."


#!/bin/bash

# Achims_OpenClaw_Build.sh
# Script to backup configs, pull updates, restore configs, modify Dockerfile, build image, and restart gateway

set -e  # Exit on any error

echo "Starting Achims_OpenClaw_Build.sh..."

# Backup der Konfigurationsdateien erstellen
echo "Creating backups..."
cp "D:\OpenClawConfig\openclaw.json" "C:\Users\User\OneDrive\Win-Documents\Notizen\Dokumentation\Openclaw\openclaw.json"
cp "D:\Users\User\git\openclaw\.env" "C:\Users\User\OneDrive\Win-Documents\Notizen\Dokumentation\Openclaw\.env"
cp "D:\Users\User\git\openclaw\docker-compose.yml" "C:\Users\User\OneDrive\Win-Documents\Notizen\Dokumentation\Openclaw\docker-compose.yml"
cp "D:\Users\User\git\openclaw\Dockerfile" "C:\Users\User\OneDrive\Win-Documents\Notizen\Dokumentation\Openclaw\Dockerfile"
cp "D:\Users\User\git\openclaw\Achims_README.md" "C:\Users\User\OneDrive\Win-Documents\Notizen\Dokumentation\Openclaw\Achims_README.md"

# Updates holen
echo "Stashing changes and pulling updates..."
git stash
git pull

# Backup Dateien wieder einspielen
echo "Restoring backups..."
cp "C:\Users\User\OneDrive\Win-Documents\Notizen\Dokumentation\Openclaw"/openclaw.json "D:\OpenClawConfig\openclaw.json"
cp "C:\Users\User\OneDrive\Win-Documents\Notizen\Dokumentation\Openclaw"/.env "D:\Users\User\git\openclaw\.env"
cp "C:\Users\User\OneDrive\Win-Documents\Notizen\Dokumentation\Openclaw"/docker-compose.yml "D:\Users\User\git\openclaw\docker-compose.yml"
cp "C:\Users\User\OneDrive\Win-Documents\Notizen\Dokumentation\Openclaw"/Achims_README.md "D:\Users\User\git\openclaw\Achims_README.md"


cd "D:\Users\User\git\openclaw"

########################################
# 1) git pull
########################################
echo "Stashing changes and pulling updates..."
git stash
git pull

DOCKERFILE_PATH="D:\Users\User\git\openclaw\Dockerfile"

########################################
# 2) Kombinierten Himalaya- und Python-Block vor erstem USER node einfügen
########################################
echo "Patching Dockerfile: Himalaya + Python venv + beem..."

# Nur patchen, wenn unser Marker noch nicht vorhanden ist
if ! grep -q "Python 3 + venv + beem bereitstellen" "$DOCKERFILE_PATH"; then
  # Erste Zeile mit "USER node" (der Block vor pnpm install)
  USER_LINE=$(grep -n "^USER node" "$DOCKERFILE_PATH" | sed -n 's/^\([0-9]\+\):.*/\1/p' | head -n1)
  if [ -z "$USER_LINE" ]; then
    echo "Error: first 'USER node' not found in Dockerfile"
    exit 1
  fi

  COMBINED_BLOCK=$'\n# Himalaya installieren (als root, Binary landet in /usr/local/bin)\nUSER root\nRUN curl -sSL https://raw.githubusercontent.com/pimalaya/himalaya/master/install.sh | sh -s -- --root /usr/local\nENV PATH=\"/usr/local/bin:${PATH}\"\n\n# Python 3 + venv + beem bereitstellen, damit Agent Python-Scripte ausführen kann\nRUN apt-get update && \\\n    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \\\n      python3 python3-venv ca-certificates curl && \\\n    python3 -m venv /opt/pyenv && \\\n    /opt/pyenv/bin/python -m pip install --no-cache-dir --upgrade pip && \\\n    /opt/pyenv/bin/python -m pip install --no-cache-dir beem && \\\n    apt-get clean && \\\n    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*\nENV PATH=\"/opt/pyenv/bin:${PATH}\"\n\nUSER node\n'

  awk -v line="$USER_LINE" -v block="$COMBINED_BLOCK" '
    NR == line { print block; next }  # den ursprünglichen "USER node" ersetzen
    { print }
  ' "$DOCKERFILE_PATH" > tmp_dockerfile && mv tmp_dockerfile "$DOCKERFILE_PATH"
else
  echo "Combined Himalaya + Python block already present, skipping."
fi


########################################
# 3) Image bauen und Gateway neu starten
########################################
echo "Building image..."
docker build -t openclaw:local -f Dockerfile .

echo "Restarting gateway..."
docker compose down openclaw-gateway
docker compose up openclaw-gateway

echo "Done. Test inside container with:"
echo "  docker exec -it openclaw-openclaw-gateway-1 bash"
echo "  python -c \"import beem; print(beem.__version__)\""
