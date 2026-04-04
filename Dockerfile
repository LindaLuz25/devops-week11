FROM node:18

WORKDIR /app
COPY . .

RUN npm install

EXPOSE 3000

HEALTHCHECK --interval=10s --timeout=5s CMD curl -f http://localhost:3000/ || exit 1

CMD ["npm", "start"]