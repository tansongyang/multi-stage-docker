# syntax=docker/dockerfile:1.7-labs

FROM node:20 as dependencies
WORKDIR /app
COPY package*.json .
RUN npm ci

FROM node:20 as build
WORKDIR /app
COPY --from=dependencies /app/node_modules node_modules
COPY --exclude=server . .
RUN npm run build

FROM node:20 as server
WORKDIR /app/server
COPY server/package*.json .
RUN npm ci
COPY --from=build /app/dist /app/dist
COPY server/index.cjs .
CMD ["node", "index.cjs"]

FROM mcr.microsoft.com/playwright:v1.44.0 as tests
WORKDIR /app
COPY --from=dependencies /app/node_modules node_modules
COPY --from=server /app .
COPY e2e e2e
COPY playwright.config.ts .
CMD ["npx", "playwright", "test"]