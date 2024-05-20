FROM node:20 as build
WORKDIR /app
COPY package*.json .
RUN npm ci
COPY . .
RUN npm run build

FROM node:20 as server
WORKDIR /app/server
COPY server/package*.json .
RUN npm ci
COPY --from=build /app/dist /app/dist
COPY server/index.cjs .
CMD ["node", "index.cjs"]
