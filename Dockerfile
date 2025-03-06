# Verwende ein Node.js-Image als Basis
FROM node:18

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
EXPOSE 5173

# Starte die Anwendung
CMD ["npm", "run", "dev", "--", "--host"]