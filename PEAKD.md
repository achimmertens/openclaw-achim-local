
Hallo zusammen,

Hier möchte ich meine ersten Erfahrungen mit dem neuen Hype "OpenClaw" mitteilen.
Ich habe den Bot bei mir auf dem PC zum Laufen gebracht und es geschafft mit ihm über Telegramm zu kommunizieren und Infos zu erhalten, die er nur von mir kennen kann.

![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/23wXHxUy9L4w4ULYEThUKYb7mRYTtLtvryFpKPd6znD7rZxGFkVZyci73njPRJeBhdheQ.png)

Diese Infos hat der Bot von einer Datei, die bei mir lokal liegt:

![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/23ydC1yUMrD2fEixh5nvnsV6fA1UG3ESpbmn3BF2HPsgDn79dCiRRXQqPL4qqfoUpe8Fc.png)

Aber der Reihe nach:
# Vorwort
Was ist eigentlich Openclaw. Fragen wir doch mal Perplexity:
> OpenClaw ist ein lokal laufender, quelloffener KI‑Agent, der auf deinem eigenen Rechner installiert wird und große Sprachmodelle wie GPT oder Gemini nur als „Gehirn“ im Hintergrund nutzt. Statt nur Fragen zu beantworten, steuert er über Chat‑Kanäle wie Telegram oder WhatsApp deine Shell, Browser, Dateien, E‑Mails und Kalender und führt dadurch echte Aktionen in deinem System aus. Er merkt sich Konfiguration und Kontext in lokalen Markdown‑Dateien, kann autonom wiederkehrende Aufgaben ausführen und lässt sich über „Skills“ und Tools wie ein automatisierbarer Teamkollege für persönliche oder technische Workflows erweitern.

Das Thema wird gerade in den Median stark gehypt, nach dem Motto "Wir haben jetzt die Schwelle zur AGI und damit den Ereignishorizont zur Singularität überschritten, es gibt kein zurück mehr..."
Da ich ein Bastler bin und gerade die Zeit habe, kam mal wieder der Wunsch in mir auf "Das will ich auch haben! Ich will es verstehen." Und ich lerne hauptsächlich durch machen. 
Die Ergebnisse der ersten zwei Tage können sich sehen lassen und ich möchte Euch an meinen Erfahrungen teil haben lassen. Los geht's.

# Sicherheit
Zuerst habe ich ein bischen mit Perplexity gechattet. Ich habe gehört, dass dieser Agent noch große Sicherheitslücken hat und entsprechend gefährlich sein kann, was meine Daten betrifft. Im Extremfall könnte er aus seiner Sandbox ausbrechen, meine Daten kapern, meine Konten plündern,...
Aber lass uns mal realistisch bleiben. Ja, er könnte theoretisch auf eine Webseite stoßen, die ihn durch Prompt-Injection so programmiert, dass er oben genannte Scenarien versucht durchzuführen. Aber dazu muss er auch genügend Rechte von mir bekommen und ggf. auch Zugriffe auf diverse Konten. Und die kriegt er nicht. Er läuft in einem Docker Container und hat anfänglich nur wenig Spielraum um sich selbst zu erweitern oder gar aus seinem Käfig zu befreien. Und ich glaube auch nicht wirklich, dass die Technik tatsächlich schon so weit entwickelt ist, das zu tun. Meine Passwörter sind mehrfach gekapselt gesichert. Ich gehe also das Risiko ein, den Agenten auf meinem PC laufen zu lassen.

# Installation

## Vorbereitung
Ich habe zwei Ordner erstellt, die der Agent später braucht:
D:\OpenClawData
D:\OpenClawConfig
Dies ist die Schnittstelle zwischen seiner Welt und meinem PC. Beide verzeichnisse sind erst mal leer, aber später braucht man sie um Daten auszutauschen bzw. den Agenten von Außen zu steuern.
Ich habe in einer Git-Shell in meinem Bastel-Verzeichnis folgenden Befehl ausgeführt, um mir den Code von Stefan Steinberger, dem Autor des Claude Agenten, zu holen:
> ​git clone https://github.com/openclaw/openclaw
cd openclaw
./docker-setup.sh #Achtung, das dauert ca. 15 Minuten

Dann erscheint ein Auswahlmenü. Ich hatte einmal Probleme mit der Markierung der Radio-Buttons. Das Problem habe ich dadurch gelöst, das Script mit einer Powershell zu starten. Beim zweiten Versuch ging es aber in der Git-Bash.


![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/EoEiDPsbTz8rTBrcLJvYFmtMzbp632PtBhY88nJXCDxqdjBJmZLyGvvV6NYadMLwGHB.png)

Ich bin die einzelenen Menüpunkte durchgegangen und haber erst mal nur sehr wenig aktiviert:

![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/23tRta71hTa3sJoiiTUpETXXdKCpjvLEQoUJBxF4fEDA3PfNVoU9C5NZkLGJA98d57pds.png)

Aber der Agent braucht natürlich Schnittstellen. Und da sind dann die ersten Hürden. Denn wir müssen an mehreren Stellen API- und andere Schlüssel eingeben, die wir erst mal überhaupt besitzen müssen.
Der Agent will ja mit einer KI reden. Und dazu braucht er entsprechende API-Keys.


## Openrouter.ai
Ich habe einen für den Bot eigenen API-Key bei Openrouter.ai erstellt und ihm erst mal 20 Dollar zur Verfügung gestellt:
![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/23tmmf85xDQuSG535pzGEivq3tAxquqr1Evdzm2EQs9mL222HQCZZXqHRpWhAyBEDMdxr.png)

Ich hatte mit [Openrouter](https://openrouter.ai/) schon im Vorfeld gut Erfahrung gemacht, da man dort sehr flexibel zwischen den einzelnen KI-Modellen auswählen kann. Es gibt sehr günstige Modelle wie Gemini 2.5 Flash Lite und GPT-5 nano, wo eine einfache Chat-Abfrage wie im obigen Telegram Beispiel, ca. 1/10 Cent kostet. Und es gibt teure Abfragen, die ich für das Coden mal verwendet habe, wo ich mit einer einzigen AUfgabe 9 Dollar verbraten habe. Hier die Kosten meines letzten Monats:

![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/Eo6SDzz5P6yUcdJD7Sdrkf5uvYWSKV1TJL7vehcvkW5Qt4mqLPHHEbJXLuwtXwMcs9L.png)
Man sieht, die Kosten der Experimente mit dem Claw-Bot, die ich im Februar hatte, sind bisher verschwindend gering, gegenüber den Kosten, die ich mit meinen Programmierexperimenten hatte.

Jedenfalls habe ich jetzt einen Openrouter API Key, den ich für meinen Bot brauche und versucht habe im Setup-Menü einzugeben. Versucht deshalb, weil ich es offensichtlich im ersten Versuch (durch einmal zu viel Enter drücken) vergeigt habe. Was aber nicht schlimm ist, weil ich es nachholen konnte, siehe weiter unten.

Auch das Standard-Modell, welches ich erst auswählte (GPT-5 Mini) ist eigentlich immer noch zu teuer. Ich habe es weiter unten noch mal geändert:
![grafik.png](10)

## Telegram
Ich möchte, dass ich mit meinem Handy den Openclaw Agenten steuern kann. Dazu braucht man eine Verbindung zu einem Messanger, hier Telegram.

Auch dort muss man erst mal etwas vorbereiten. Ich habe die Kommuniktation zum @Botfather in Telegram gestartet.
Mit /newbot wurde mein neuer Bot "Helbardorbot" erstellt und mir der Token zur Verfügung gestellt.

![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/23uFqGVLjTbqZEm4b86Pd5pQPEQR9EpWH8YSj5c6inRq19CSAjjvqJAm3AexFTzq26khq.png)

Auch hier hat es nicht auf Anhieb geklappt eine Verbindung herzustellen. Aber später im lokalen Chataustausch mit dem Openclawbot, haben wir es irgendwie gemeinsam hinbekommen.


## Weitere Konfiguration
![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/Eo6Bm95odEKzPbXjLWg8jpt8na7mBo686Pv6o7uE9xK9iKwvSAXBxUV9aWo2DNnmUZ8.png)

![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/23tGTdnYRkhByzGAcLpFM3oqSV85tSrbntPuMFtBz6Zhvw2VLxYfqND7gsCKsTymMHC83.png)


![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/23tGVGDs1GyuwQNk4w3CqQB5hwodUcAuiHZ5Ayu8Bf71fujizUhgC7PgSWNXBBhUruKew.png)

![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/23t756dMTJXu1cBxZL1u6v8AuSpc5TTfkYkae9BXvgH3scGqVZovXvcm894CdU9vf215Z.png)

## Noch ein paar Nacharbeiten
Jetzt wurden einige Dateien erstellt. Die befinden sich alle in dem von Github heruntergeladenen Ordner:

![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/23t76tJUfLW283Wav8L5RZrbJSj9sc1Leu6cP5yHT5igxANwiz4wLwND6oEa7i392JXFR.png)

### .env
Ich musste in zweien davon manuell etwas ändern. Zum einen die .env Datei.
Diese beinhaltet die lokalen und auch geheimen Informationen, die in der Regel auch nicht nach Git hochgeladen werden dürfen (sollte man dieses Verzeichnis synchronisieren wollen, muss .env in die .gitignore mit aufgenommen werden).
Wichtig ist, dass die beiden oben erstellen Ordner hier aufgelistet werden:

![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/23tRvNFrrRjivsRDxQjiMYvqEJNeUtcDkLfTgENeFubjyPeqpyzftxYMsEXTJTD592ZRR.png)

### docker-compose.yml
Diese Datei erzeugt den Container, indem sich Openclaw aufhält. Auch hier musste ich etwas eintragen, nämlich das Container Netz, weil der lokale Client das Gateway auf Anhieb nicht gefunden hat. 
```
networks:
  openclaw-net:
    driver: bridge
```

# Das Openclaw Gateway
Das Kernstück, bzw. Backend von Openclaw ist das Gateway, dass wir gerade installiert haben. Es wird gestartet mit:
> docker compose up openclaw-gateway

![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/23t7BPuogPsHLfG1oHtJEwjEJkzWvHTDHrXSwqHtm62aomqfxguQdzfmswP4hYLCL2M9V.png)

Wenn man die Logausgaben sehen will, lässt man entweder im obigen Befehl das -d weg, oder man gibt anschließend folgenden Befehl ein:
> docker compose logs -f openclaw-gateway


![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/23tRtagXv1DJUSQFyqWfTcid4MpA8mttA3wvWf3nYVoUP46CvBHV6nPFsWBYwvk9KrkQT.png)


# Das lokale Command Line Interface (CLI)

Eigentlich müsste der Client in der Shell wie folgt gestartet werden können:
> docker compose up openclaw-cli

![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/Eo6CFSA4zwAYCjaoXKd31Zq8y13qhC9qMaqnakqSBVzVnZRYetph63BuySxke9CePPQ.png)

Aber bei mir stürzt der Client mit der Meldung "openclaw-cli-1 exited with code 1" ab. Das ist aber nicht tragisch (zumindest im Moment), da ich eine Alternative habe. Ich öffne eine Shell im Gateway Container und starte dort den Client:

Shell im Container ausführen:
docker compose exec openclaw-gateway sh

CLI im Container ausführen:
node dist/index.js tui --token 1e5*******47

![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/23tS12mDGXYd7YXh9WGSfA22R2VfQmsygGgJAuDFDaSVz83FwcKGVST2jJCqQC4oy8wmJ.png)


# Nachträgliche Konfigurationen
Der Bot behauptet zwar, er nutze GPT-5 Mini, aber die Konfigurtation der Modelle erfolgt in der Datei
D:\OpenClawConfig\openclaw.json
Wir fassen diese Datei auch in der Regel nicht von Hand an, sonder ändern die Konfiguration mit Befehlen (innerhalb der Gateway Shell) wie:

node dist/index.js onboard --auth-choice apiKey --token-provider openrouter --token "sk-or-v1-dd78a********13"

Ich habe noch nicht ausprobiert, ob der Bot das selber ändern kann...
Man muss auch aufpassen, da der Bot einem auch gerne nach dem Mund redet. Wenn man ihn drauf anspricht, wird er ehrlicher:


![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/23tbMLG6W462vbJBjNdTzbNtC1npWngNHdzrvfnb1BH8xjnAMzJXmVL2PaR6azB7PJsQr.png)

# Das Webinterface
Diese Shell CLI ist schon mal gut, um überhaupt mit dem Bot in Kontakt zu treten, aber lästig im Alltag. Neben der Telegram-Oberfläche, die ja auch erst mal eingerichtet sein will, gibt es eine lokale Weboberfläche:
Der Zugriff erfolgt über http://localhost:18789/?token=HIER_DEIN_TOKEN
Der Token steht in der .env Datei und wurde beim Erstellen des Gateways erzeugt/bekanntgegeben.

![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/23tSxMgV7CP8t2TP9JdE8GML1R8BuFzUZ7QyTGbVq3GDYn6evuq8c5G5cEZ9DNexLecwd.png)

Sobald man einmal diese Oberfläche hat, wird das Konfigurieren des Bots deutlich einfacher.


# Die Seele des Agenten
Im Ordner D:\OpenClawData befinden sich jetzt neu angelegte Dateien (Wobei die HUEHENER.md von mir ist):

![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/23tSym8QF6M8YohLEmfDWWoSKQG7vod28ZxZFTLF6gDrdTnHJGvpEyrnpxadcexyXQDDM.png)

Diese sollte man sich mal ansehen, denn dort wird das Verhalten des Bots vorgegeben.
Hier ein Ausschnitt:

![grafik.png](https://files.peakd.com/file/peakd-hive/achimmertens/23tGVGGcPoPE36uRfD1UM3MD68rHrQABS3D2w2CUtHFS38zY3JepNgTkVfeoPGq89MGCW.png)

# Weitere Aktionen
Ich möchte diesen Bot weiter besser kennen lernen. Ich möchte ihm Zugriff auf eine eigene Emailadresse geben, vielleicht auch auf Moltbook, vielleicht auch auf Github. Er soll für mich später Coden übernehmen ("Hier hast du ein paar Fotos und Informationen, mache eine Webseite daraus.") Wenn er sich als zuverlässig erweist, bekommt er vielleicht sogar ein eigenes Wallet mit ein bischen Geld drin, um damit Hostingaufträge oder andere Sachen zu kaufen.
Jedenfalls steckt hier noch viel Abenteuer und Potential drin ;-)

# Fazit
Die Installation ist definitiv nichts für Neulinge. Es müssen viele Schlüssel übertragen werden, vieles lief nicht auf Anhieb, wie z.B. der CLI in einem eigenem Docker Container. Man muss wissen was man tut und es werden Kosten erzeugt. 
Aber der Weg ist sehr spannend und man riecht das Potential. Wir sind hier schon dabei etwas ganz Neues zu erleben und mitzugestalten.

Ich werde euch auf dem Laufenden halten.

Achim Mertens

---
