FROM node:20-alpine

# Installa git, utile a lean-ctx per tracciare il repository
RUN apk add --no-cache git

# Installa lean-ctx-bin globalmente nel container
RUN npm install -g lean-ctx-bin

# Imposta la directory di lavoro di default nel container
WORKDIR /app

# Copia lo script proxy Loop Guard
COPY loop-guard.js /app/loop-guard.js

# Di default, lancia il proxy Loop Guard che avvia internamente lean-ctx
CMD ["node", "/app/loop-guard.js"]

