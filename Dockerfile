FROM node:20
WORKDIR /app
COPY package*.json .
RUN npm ci
COPY . .
RUN npm run build
# CMD ["node", "index.cjs"]
CMD sleep infinity
