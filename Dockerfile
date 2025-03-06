# Verwende ein Node.js-Image als Basis
FROM node:16

# Erstelle ein Arbeitsverzeichnis
WORKDIR /app

# Kopiere package.json und package-lock.json
COPY package.json ./

# Installiere Abhängigkeiten
RUN npm install

# Kopiere den Rest des Anwendungs-Codes
COPY . .

# Baue das Projekt
RUN npm run build

# Exponiere den Port
EXPOSE 3000

# Starte die Anwendung
CMD ["npm", "run", "dev"]