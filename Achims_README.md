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

$ git remote -v
mine    https://github.com/achimmertens/openclaw-achim-local.git (fetch)
mine    https://github.com/achimmertens/openclaw-achim-local.git (push)
origin  https://github.com/openclaw/openclaw (fetch)
origin  https://github.com/openclaw/openclaw (push)

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


# ---- GitHub Repo für Achims lokalen Branch -----

Könnte ich meinen lokalen Branch irgendwie als eigenes Repo auf Github anlegen? Ich hätte dann immer die Updates vom offiziellen Mainbranch + meine eigenen Scripte in einem eigenen Repo in Github gesichert.

Ja, das geht sehr gut: Du kannst aus deinem lokalen Branch ein **eigenes GitHub‑Repo** machen, das weiterhin den offiziellen OpenClaw‑Repo als „upstream“ eingebunden hat. So bekommst du Updates von dort und sicherst deine eigenen Sachen in deinem privaten/fork‑ähnlichen Repo.

### 1. Lokalen Branch für deine Arbeit vorbereiten

Im bestehenden OpenClaw‑Clone:

```bash
cd /d/Users/User/git/openclaw

# sicherstellen, dass du auf main bist und alles aktuell ist
git checkout main
git pull

# eigenen Arbeits-Branch (falls noch nicht vorhanden)
git checkout -b achim-local
```

Jetzt commitest du **alle deine eigenen Dateien** (Scripts, Dockerfile‑Patch, Doku) auf `achim-local`:

```bash
git add Achims_OpenClaw_Build.sh post_to_hive.py ...   # alle deine Files
git commit -m "Achim: lokale OpenClaw-Scripts und Doku"
```

### 2. Neues Repo auf GitHub anlegen und verbinden

1. Auf GitHub ein neues Repo erstellen, z.B. `openclaw-achim-local` (ohne Template, leer).  
2. Die URL merken, z.B.:

```text
https://github.com/deinuser/openclaw-achim-local.git
```

3. In deinem lokalen Clone einen **zweiten Remote** hinzufügen:

```bash
git remote add mine https://github.com/achimmertens/openclaw-achim-local.git
```

4. Deinen Branch dorthin pushen:

```bash
git push -u mine achim-local
```

Damit hast du:

- `origin` → offizielles OpenClaw‑Repo (nur lesen).  
- `mine` → dein eigenes GitHub‑Repo mit deinem Branch `achim-local`.

### 3. Upstream‑Updates weiter einziehen

Workflow in Zukunft:

```bash
# Offizielles Repo aktualisieren
git checkout main
git pull origin main

# Deinen Branch auf neuesten Stand bringen
git checkout achim-local
git rebase main       # oder: git merge main

# Deine neuen Änderungen committen und zu DEINEM Repo pushen
git push mine achim-local
```

So:

- bleibt dein `main` sauber und identisch zu upstream,  
- lebt deine gesamte Arbeit in `achim-local`,  
- und du hast sie sicher in deinem eigenen GitHub‑Repo, ohne das OpenClaw‑Projekt anzufassen. [stackoverflow](https://stackoverflow.com/questions/63557584/how-do-i-keep-a-local-version-and-commit-changes-on-git-without-pushing-upstream)
