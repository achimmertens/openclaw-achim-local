# Wie man das OpenClaw- und ein eigenes Git Repository kombiniert

## 📑 Inhaltsverzeichnis

1. [Worum geht es?](#-worum-geht-es)
2. [Das Problem: Zwei Repositories, ein Ziel](#-das-problem-zwei-repositories-ein-ziel)
3. [Die Lösung: Das Build-Script automatisiert alles](#-die-lösung-das-build-script-automatisiert-alles)
4. [Wie das Script funktioniert](#-wie-das-script-funktioniert-schritt-für-schritt)
5. [Was ermöglicht das? – Mein persönlicher OpenClaw-Agent](#-was-ermöglicht-das--mein-persönlicher-openclaw-agent)
6. [Die Vorteile auf einen Blick](#-die-vorteile-auf-einen-blick)
7. [Quick Start](#-quick-start)
8. [Sicherheit & Best Practices](#-sicherheit--best-practices)
9. [Nächste Schritte](#-nächste-schritte)

---

## 🎯 Worum geht es?

Openclaw ist ein faszinierendes Projekt. Ich habe es lokal als Docker Variante ausprobiert, komme aber schnell an den Punkt, wo ich eigenen Code verwenden möchte, um z.B. zusätzliche Tools zu installieren oder eigene Skripte zu integrieren. Gleichzeitig möchte ich aber auch die Updates vom offiziellen OpenClaw-Repo bekommen, ohne ständig Merge-Konflikte zu haben.

Dazu habe ich mir ein Build und Merge-Script erstellt, welches ich hier vorstellen möchte.


![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/23vrrSx6y3AhqebYTF4mm2jYtXvKwHTHgD7qKuiWxzXZXiRtNmRY33bfDAV2mgUdRih1X.png)

Desweiteren habe ich schon diverse, auch positive, Erfahrungen mit meinem eigenen KI-Agenten gemacht, die ich hier auch kurz vorstellen möchte.

Aber fangen wir mit dem Merge-Problem an:

## 🌳 Das Problem: Zwei Repositories, ein Ziel

### Das offizielle OpenClaw-Repository
Das Original-Projekt `openclaw/openclaw` wird ständig aktualisiert:
- Neue Features
- Bug-Fixes
- Sicherheits-Updates

Wenn ich darin direkt Änderungen mache und dann `git pull` mache, bekomme ich **Merge-Konflikte** – weil OpenClaw auch an denselben Dateien arbeitet.

### Mein persönliches Repository (achim-local)
Ich möchte aber Änderungen machen, die **nur ich brauche**:
- Zusätzliche Tools (wie **Himalaya** für E-Mail)
- Extra Python-Pakete (wie **beem** für die Hive-Blockchain)
- Custom Ports für meine Infrastruktur

## ⚡ Die Lösung: Das Build-Script automatisiert alles

Das Script folgt dieser Strategie:

```
[Original OpenClaw]
        ↓
  [Update holen]
        ↓
  [Auf meinem Branch anwenden]
        ↓
  [Meine Customizations hinzufügen]
        ↓
  [Docker Image bauen]
        ↓
  [Gateway neu starten]
```

## 🔄 Wie das Script funktioniert (Schritt für Schritt)

### 1️⃣ Lokale Änderungen sichern (Stash)
Zuerst frage ich ab, ob ich in meinem Branch "achim-local" bin und "git stash" oder "git commit" ausgeführt habe. Das ist wichtig, damit meine lokalen Änderungen nicht verloren gehen, wenn ich den Branch wechsle.

### 2️⃣ Die neuesten Updates von OpenClaw holen

```bash
# Offizielles Repo aktualisieren
echo "Pulling updates from main..."
git checkout main
git pull origin -Xtheirs main
```

### 3️⃣ Mein Branch wird auf `achim` zurückgesetzt und mit `main` synchronisiert

```bash
# Deinen Branch aktualisieren
# Make achim-local identical to main so OpenClaw updates are imported unconditionally.
echo "Resetting achim-local to main (upstream) ..."
git checkout achim-local
git merge -Xours main
```

**Das ist der Trick!** 
Durch die Merge-Strategien `-Xtheirs` und `-Xours` erzwinge ich, dass die Änderungen von `main` immer übernommen werden, ohne dass es zu Konflikten kommt. Das bedeutet:
- ✅ Alle Updates von OpenClaw werden automatisch in meinen Branch integriert
- ✅ Meine eigenen Änderungen bleiben erhalten, weil sie nach dem Merge wieder hinzugefügt werden


### 4️⃣ Meine Custom Changes werden automatisch hinzugefügt
In meinen lokalen Dockerfiles, bzw. docker-compose.yml habe ich bereits die Änderungen vorgenommen, damit z.B. Himalaya und Python mit beem installiert werden. Mein Merge-Script sorgt dafür, dass diese Änderungen nach dem Merge wieder hinzugefügt werden, falls sie verschwunden sind.

#### 🐘 Himalaya (E-Mail-Verwaltung)
Himalaya soll im Docker-Container installiert werden, sodass mein Agent in die Lage kommt automatisch E-Mails zu lesen, zu schreiben und zu verwalten.
Das Dockerfile wird also um die Zeilen erweitert, die nötig sind, um Himalaya zu installieren.
Ähnlich gehen wir mit Python um. Auch hier wird dafür gesorgt, dass im Dockerfile die Installation von Python 3, einem virtuellen Environment und dem `beem`-Package erfolgt. Das ermöglicht meinem Agenten, z.B. direkt mit der Hive-Blockchain zu interagieren.
Wir fügen beide Installationsanweisungen gemeinsam in einem Block hinzu, da es programmatisch einfacher ist:


```bash
 COMBINED_BLOCK=$'\n# Himalaya installieren (als root, Binary landet in /usr/local/bin)\nUSER root\nRUN curl -sSL https://raw.githubusercontent.com/pimalaya/himalaya/master/install.sh | sh -s -- --root /usr/local\nENV PATH=\"/usr/local/bin:${PATH}\"\n\n# Python 3 + venv + beem bereitstellen, damit Agent Python-Scripte ausführen kann\nRUN apt-get update && \\\n    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \\\n      python3 python3-venv ca-certificates curl && \\\n    python3 -m venv /opt/pyenv && \\\n    /opt/pyenv/bin/python -m pip install --no-cache-dir --upgrade pip && \\\n    /opt/pyenv/bin/python -m pip install --no-cache-dir beem && \\\n    apt-get clean && \\\n    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*\nENV PATH=\"/opt/pyenv/bin:${PATH}\"\n\nUSER node\n'
  awk -v line="$USER_LINE" -v block="$COMBINED_BLOCK" '
    NR == line { print block; next }
    { print }
  ' "$DOCKERFILE_PATH" > tmp_dockerfile && mv tmp_dockerfile "$DOCKERFILE_PATH"
  echo "Dockerfile patched with Himalaya and Python."
```

### Docker-compose.yml
Auch in der Docker-compose.yml habe ich persönliche Anpassungen gemacht. Z.B. werden meine Laufwerke gemountet.
Das Script sorgt dafür, dass diese Zeilen durch die gewählte Merge-Strategie erhalten bleiben, auch wenn OpenClaw Änderungen an der docker-compose.yml vornimmt.

``` yaml
    volumes:
      - ${OPENCLAW_CONFIG_DIR}:/home/node/.openclaw
      - ${OPENCLAW_WORKSPACE_DIR}:/home/node/.openclaw/workspace
      - ${OPENCLAW_WORKSPACE_DIR}/workspace-susi:/home/node/.openclaw/workspace/workspace-susi
      - ${OPENCLAW_CONFIG_DIR}/.config/himalaya:/home/node/.config/himalaya
      - ${OPENCLAW_CONFIG_DIR}/.local:/home/node/.local
```

### 5️⃣ Docker Image bauen
```bash
# Build the Docker image
echo "Building Docker image..."
docker build -t openclaw:local .
```
Mit all meinen Änderungen wird jetzt ein neues Docker Image erstellt.

### 6️⃣ Container neu starten
```bash
docker compose down
docker compose up 
```
Der alte Container wird gestoppt, der neue mit allen Updates startet neu.

![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/Eo6C8Kk5sbyobcuiPLik4Xr21LAopX3kgLGF2mTezFak2ahqKGUDa4ucocjcSBkarH8.png)


## Image Backup und Restore

Nun habe ich ein lauffähiges Image. Da immer die Gefahr besteht, dass beim nächsten Build etwas nicht funktioniert, wäre es sschön, direkt auf das letzte Image zugreifen zu können. Das geht wie folgt:

``` Bash
# Image sichern und wieder herstellen
#
# Sichern des Images
docker tag openclaw:local openclaw_achim:local
docker save -o openclaw_achim.tar openclaw_achim:local
#
# Image wieder herstellen:
docker load -i openclaw_achim.tar
# 
# In der docker-compose.yml dann das Image auf openclaw_achim:local ändern, damit es verwendet wird.

```


## 🤖 Was ermöglicht das? – Mein persönlicher OpenClaw-Agent

Mit diesem Setup bekomme ich einen Agent, der folgendes kann:

### 📊 Daten-Assistent
Der Agent kann meine Daten abfragen und aufbereiten.
![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/EopxF6eYqzV9keAHzZyC7DeGyXkowWqaoUzHKj4PwWjbBDks4dEoEio87xFHqQEDBMu.png)

Ich habe ihn auch gebeten, einen Zahlungs-Posten in der letzten Zeile hinzuzufügen. Der Agent hat darufhin das ODS-Format in ein anderes umgewandelt, die Textzeile sauber hinzugefügt und die Datei wieder zurück in ODS konvertiert. Das alles automatisch, ohne dass ich manuell eingreifen musste.

### 📝 Blog-Publishing
Ich habe dem Agenten die Aufgabe gegeben, einen Test-Blog-Artikel zu schreiben und auf Hive zu veröffentlichen.
Ich habe dazu in meiner lokalen .env Datei den Posting Key eines Accounts gegeben. Er hat daraufhin im Internet recherchiert, ein Python Script eigenständig erstellt und so lange ausprobiert, bis es klappte.

![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/23tRtVuiKGraPqzermj1mbYU9QHxFD77TiwGkbEGyFLG3WRA9eBWek5CDgvLiV2ehcCFf.png)
Btw. Ich habe das vor ca. drei Jahren mal selber recherchiert. Ich habe um so weit zu kommen ca. ein halbes Jahr gebracht.

Wichtig ist, dass man nach erfolgreicher Durchführung dem Bot sagen muss, dass er sich den Erfolg merken soll. 
Seine MEMORY.MD Datei kann dann z.B. so aussehen:
![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/23tGXuSR9MsZm339tRbmcdvnzkwFnqL9wSEwmtL51CBWjAmqEB4KuuMk3b8fKm82go3Ek.png)

### 📧 E-Mail Management
Die Installation von Himalaya habe ich hier beschrieben: 
https://peakd.com/hive-121566/@achimmertens/openclaw-mailverkehr-und-weitere-agenten-erstellen

Mit Himalaya kann der Agent:
- E-Mails automatisch lesen
- Antworten schreiben und versenden
- E-Mail-basierte Workflows automatisieren

Bisher bin ich da aber noch sehr vorsichtig mit. Er hat zwar jetzt eine eigene Mail Adresse, aber wer liest schon gerne automatisch generierte Mails von einem KI-Agenten? Zumindest ist dies ein Medium, wie ich dem Bot weitere Daten und Informationen zukommen lassen kann.

### 🖼️ Bild-Extraktion & Cloud-Upload
Ich habe im Vorfeld mir ein paar Notizen und Screenshots bei der Installation von Openclaw in einem Word Dokument gemacht. Ich wollte diese Bilder gerne in meinen Blog-Posts verwenden, aber sie manuell zu extrahieren und hochzuladen ist mühsam. Hier hat mir der Agent erstmals Zeit erspart, indem er die Bilder automatisch extrahiert, auf BackBlaze hochlädt und die URLs in einem Markdown-Dokument speichert. So kann ich sie direkt in meinen Blog-Posts verwenden, ohne manuell Dateien zu verwalten.

## 🎉 Fazit
## 🎁 Die Vorteile auf einen Blick

| Feature               | Vorher                   | Nachher                  |
| --------------------- | ------------------------ | ------------------------ |
| **Merge-Konflikte**   | Ständig 😞                | Hoffentlich Nie wieder 🎉 |
| **OpenClaw-Updates**  | Manuell + fehleranfällig | Automatisch ✅            |
| **Custom Tools**      | Nur out of the Box       | Eigene Tools dabei 🔧     |
| **Zeit pro Build**    | 30 Minuten               | 3-5 Minuten ⚡            |
| **Agent-Fähigkeiten** | allgemein                | personalisiert 🚀         |

## 📋 Quick Start

```bash
# Script ausführbar machen
chmod +x Achims_OpenClaw_Build.sh

# Ausführen
./Achims_OpenClaw_Build.sh

# Fragen beantworten:
# "Is Docker running in the background?" → y
# "Have you committed your changes?" → y
```

Das war's! ✨


## 🚀 Nächste Schritte

Jetzt, wo mein Agent alle Tools hat (Himalaya, Python, beem), kann ich meinen Agent trainieren für:
- **Autonome Blog-Publikation** 📝
- **E-Mail-Automation** 📧
- **Content-Verarbeitung** 🖼️
- **Blockchain-Integration** ⛓️

Die Möglichkeiten sind endlos!

Ich möchte als nächstes Speech To Text und Text To Speech ausprobieren, damit ich in Telegram einfach nur noch in mein Handy sprechen brauche. Ich habe schon die ersten Erfahrungen mit Whisper gesammelt.

So, Stay tuned,

Achim Mertens
---
*Ich stelle meinen Code öffentlich zur Verfügung. Ihr könnt Euch dort alle Dateien anschauen: 
https://github.com/achimmertens/openclaw-achim-local/tree/achim-local*

*Habt ihr ähnliche Probleme mit Git und Merge-Konflikten gelöst? Erzählt mir in den Kommentaren, wie ihr solche Herausforderungen meistert!* 💬
