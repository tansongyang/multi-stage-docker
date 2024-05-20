FROM node:20 as build
WORKDIR /app
COPY package*.json .
RUN npm ci
COPY . .
RUN npm run build

FROM node:20
WORKDIR /app
COPY --from=build /app/dist dist
COPY --from=build /app/index.cjs .
# CMD ["node", "index.cjs"]
CMD sleep infinity
