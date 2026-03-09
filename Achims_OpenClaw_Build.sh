#!/bin/bash
# Achims_OpenClaw_Build.sh
# git pull, Dockerfile patchen (Python+beem + Himalaya), Image bauen, Gateway neu starten

# Frage nach, ob git commit gemacht wurde in Achim-local Branch und warte auf ein "y"
read -p "Have you committed your changes in the achim-local branch? (y/n): " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Great! Proceeding with the build..."
else
    echo "Please commit your changes in the achim-local branch before running this script."
    echo "Use 'git push mine achim-local -f' to push your commits to the remote repository."
    exit 1
fi

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




########################################
# 1) git pull
########################################
echo "Stashing changes and pulling updates..."
cd "D:\Users\User\git\openclaw"

echo "Stashing changes and pulling updates..."
git stash
# Offizielles Repo aktualisieren
git checkout main
git pull origin main

# Deinen Branch auf neuesten Stand bringen
git checkout achim-local
git rebase main -Xours       # oder: git merge main

# Backup Dateien wieder einspielen
echo "Restoring backups..."
cp "C:\Users\User\OneDrive\Win-Documents\Notizen\Dokumentation\Openclaw"/openclaw.json "D:\OpenClawConfig\openclaw.json"
cp "C:\Users\User\OneDrive\Win-Documents\Notizen\Dokumentation\Openclaw"/.env "D:\Users\User\git\openclaw\.env"
cp "C:\Users\User\OneDrive\Win-Documents\Notizen\Dokumentation\Openclaw"/docker-compose.yml "D:\Users\User\git\openclaw\docker-compose.yml"
cp "C:\Users\User\OneDrive\Win-Documents\Notizen\Dokumentation\Openclaw"/Achims_README.md "D:\Users\User\git\openclaw\Achims_README.md"




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
# docker-compose.yml: Volumes anpassen
########################################
echo "Patching docker-compose.yml volumes..."

COMPOSE_PATH="D:\Users\User\git\openclaw\docker-compose.yml"

node << 'NODE_VOL_EOF'
const fs = require('fs');

const file = "D:\\Users\\User\\git\\openclaw\\docker-compose.yml";
let content = fs.readFileSync(file, 'utf8');

// Hilfsfunktion: Volumes-Block eines Service ersetzen
function replaceVolumes(yml, serviceName, newVolumesBlock) {
  const serviceRegex = new RegExp(
    `(  ${serviceName}:[\\s\\S]*?)(    volumes:[\\s\\S]*?)(?=^  [a-z]|^services:|\\Z)`,
    'm'
  );
  return yml.replace(serviceRegex, (match, head, volumes) => {
    return head + newVolumesBlock;
  });
}

const gatewayVolumes = `
    volumes:
      - \${OPENCLAW_CONFIG_DIR}:/home/node/.openclaw
      - \${OPENCLAW_WORKSPACE_DIR}:/home/node/.openclaw/workspace
      - \${OPENCLAW_WORKSPACE_DIR}/workspace-susi:/home/node/.openclaw/workspace/workspace-susi
      - \${OPENCLAW_CONFIG_DIR}/.config/himalaya:/home/node/.config/himalaya
      - \${OPENCLAW_CONFIG_DIR}/.local:/home/node/.local
`;

const cliVolumes = `
    volumes:
      - \${OPENCLAW_CONFIG_DIR}:/home/node/.openclaw
      - \${OPENCLAW_WORKSPACE_DIR}:/home/node/.openclaw/workspace
      - \${OPENCLAW_WORKSPACE_DIR}/workspace-susi:/home/node/.openclaw/workspace/workspace-susi
      - \${OPENCLAW_CONFIG_DIR}/.config/himalaya:/home/node/.config/himalaya
      - \${OPENCLAW_CONFIG_DIR}/.local:/home/node/.local
`;

let out = content;
out = replaceVolumes(out, 'openclaw-gateway', gatewayVolumes);
out = replaceVolumes(out, 'openclaw-cli', cliVolumes);

fs.writeFileSync(file, out, 'utf8');
console.log('✓ docker-compose.yml volumes patched');
NODE_VOL_EOF




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
