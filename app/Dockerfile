FROM node:18

# Instalar dependencias
RUN apt-get update && apt-get install -y python3-pip curl git && rm -rf /var/lib/apt/lists/*

# Instalar Docker CLI
RUN curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh && rm get-docker.sh

# Instalar Docker Compose
RUN pip3 install docker-compose

WORKDIR /app
COPY . .

RUN npm install

EXPOSE 3000

HEALTHCHECK --interval=10s --timeout=5s CMD curl -f http://localhost:3000/ || exit 1

CMD ["npm", "start"]