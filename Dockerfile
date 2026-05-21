FROM node:20-alpine

# Installa git, utile a lean-ctx per tracciare il repository
RUN apk add --no-cache git

# Installa lean-ctx-bin globalmente nel container
RUN npm install -g lean-ctx-bin

# Imposta la directory di lavoro di default nel container
WORKDIR /app

# Di default, lancia lean-ctx in modalità stdio
CMD ["lean-ctx"]

