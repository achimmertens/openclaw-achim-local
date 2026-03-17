#!/bin/bash
# Achims_OpenClaw_Build.sh
# git pull, apply custom patches, build image, restart gateway

# Frage nach, ob Docker im Hintergrund läuft und warte auf ein "y"
read -p "Is Docker running in the background? (y/n): " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Great! Proceeding with the build..."
else 
    echo "Bitte schalte das Windows Docker ein!"
    exit 1
fi

# Frage nach, ob git commit gemacht wurde in Achim-local Branch und warte auf ein "y"
read -p "Are you in the achim-local-branch? Have you committed your changes in the achim-local branch? (y/n): " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Great! Proceeding with the build..."
else
    echo "Please commit your changes in the achim-local branch before running this script."
    echo "Use i.e. 'git push mine achim-local -f' to push your commits to the remote repository."
    exit 1
fi

set -e

echo "Starting Achims_OpenClaw_Build.sh..."

# Stash lokale Änderungen
echo "Stashing local changes..."
cd "D:\Users\User\git\openclaw"
git stash

# Offizielles Repo aktualisieren
echo "Pulling updates from main..."
git checkout main
git pull origin -Xtheirs main

# Deinen Branch aktualisieren
# Make achim-local identical to main so OpenClaw updates are imported unconditionally.
echo "Resetting achim-local to main (upstream) ..."
git checkout achim-local
git reset --hard main

# Apply custom patches to original files
echo "Applying custom patches to original files..."

# Patch Dockerfile: Add Himalaya and Python blocks
DOCKERFILE_PATH="D:\Users\User\git\openclaw\Dockerfile"

# Block that will be inserted (used both before and after stash pop)


if ! grep -q "Python 3 + venv + beem bereitstellen" "$DOCKERFILE_PATH"; then
  USER_LINE=$(grep -n "^USER node" "$DOCKERFILE_PATH" | sed -n 's/^\([0-9]\+\):.*/\1/p' | head -n1)
  if [ -z "$USER_LINE" ]; then
    echo "Error: first 'USER node' not found in Dockerfile"
    exit 1
  fi
  COMBINED_BLOCK=$'\n# Himalaya installieren (als root, Binary landet in /usr/local/bin)\nUSER root\nRUN curl -sSL https://raw.githubusercontent.com/pimalaya/himalaya/master/install.sh | sh -s -- --root /usr/local\nENV PATH=\"/usr/local/bin:${PATH}\"\n\n# Python 3 + venv + beem bereitstellen, damit Agent Python-Scripte ausführen kann\nRUN apt-get update && \\\n    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \\\n      python3 python3-venv ca-certificates curl && \\\n    python3 -m venv /opt/pyenv && \\\n    /opt/pyenv/bin/python -m pip install --no-cache-dir --upgrade pip && \\\n    /opt/pyenv/bin/python -m pip install --no-cache-dir beem && \\\n    apt-get clean && \\\n    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*\nENV PATH=\"/opt/pyenv/bin:${PATH}\"\n\nUSER node\n'
  awk -v line="$USER_LINE" -v block="$COMBINED_BLOCK" '
    NR == line { print block; next }
    { print }
  ' "$DOCKERFILE_PATH" > tmp_dockerfile && mv tmp_dockerfile "$DOCKERFILE_PATH"
  echo "Dockerfile patched with Himalaya and Python."
else
  echo "Dockerfile already patched."
fi

# Patch docker-compose.yml: Add port 18791 if not present
COMPOSE_PATH="D:\Users\User\git\openclaw\docker-compose.yml"
if ! grep -q "18791:18791" "$COMPOSE_PATH"; then
  # Find the ports section and add the line
  sed -i '/ports:/a\      - "18791:18791"' "$COMPOSE_PATH"
  echo "docker-compose.yml patched with port 18791."
else
  echo "Port 18791 already present in docker-compose.yml."
fi

# Build the Docker image
echo "Building Docker image..."
docker build -t openclaw:local .

# Restart the gateway
echo "Restarting OpenClaw gateway..."
docker compose down
docker compose up -d

echo "Build and restart completed successfully!"

# Restore any stashed local changes (may reapply your working changes).
if git stash list | grep -q "stash@"; then
  echo "Restoring stashed changes..."
  git stash pop || true
  echo "Re-applying custom patches after stash pop..."
  # Re-run patch logic to ensure the files are still in the desired state
  # (this will harmlessly skip if already applied).
  if ! grep -q "Python 3 + venv + beem bereitstellen" "$DOCKERFILE_PATH"; then
    echo "Re-patching Dockerfile..."
    # (reuse same patch block as above)
    USER_LINE=$(grep -n "^USER node" "$DOCKERFILE_PATH" | sed -n 's/^\([0-9]\+\):.*/\1/p' | head -n1)
    if [ -z "$USER_LINE" ]; then
      echo "Error: first 'USER node' not found in Dockerfile"
      exit 1
    fi
    awk -v line="$USER_LINE" -v block="$COMBINED_BLOCK" '
      NR == line { print block; next }
      { print }
    ' "$DOCKERFILE_PATH" > tmp_dockerfile && mv tmp_dockerfile "$DOCKERFILE_PATH"
  fi
  if ! grep -q "18791:18791" "$COMPOSE_PATH"; then
    sed -i '/ports:/a\      - "18791:18791"' "$COMPOSE_PATH"
  fi
fi
