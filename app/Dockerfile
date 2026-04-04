FROM node:18

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    python3-pip \
    curl \
    git \
    docker-compose \
    && rm -rf /var/lib/apt/lists/*

# Instalar Docker CLI
RUN curl -fsSL https://get.docker.com -o get-docker.sh \
    && sh get-docker.sh \
    && rm get-docker.sh

# Directorio de la app
WORKDIR /app
COPY . .

# Instalar dependencias de Node
RUN npm install

# Exponer puerto
EXPOSE 3000

# Healthcheck
HEALTHCHECK --interval=10s --timeout=5s CMD curl -f http://localhost:3000/ || exit 1

# Comando por defecto
CMD ["npm", "start"]