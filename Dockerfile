# syntax=docker/dockerfile:1.7-labs
# ^ This lets us use the --exclude flag in the COPY command, which at time of
# writing is still experimental.

# node_modules will be needed by both the `build` and `tests` stages. Extracting
# a separate stage for it means we only have to install node_modules once, and
# copy where needed.
FROM node:20 as dependencies
WORKDIR /app
# Docker tracks which files are needed by each COPY command. If a dependent
# file changes, that COPY line has to rerun, and so does every line after it.
# This can get inefficient if you're not careful.
# 
# Separately copying just the package.json files here means this line will only
# run if those files change, which is usually due to a change in dependencies,
# which shouldn't happen often. This effectively caches node_modules.
#
# So now, when you rebuild after code changes, as long as you haven't touched
# package.json, Docker will skip the expensive dependency install step.
COPY package*.json .
RUN npm ci

FROM node:20 as build
WORKDIR /app
COPY --from=dependencies /app/node_modules node_modules
# Since we have .dockerignore set up, we can copy everything and be assured that
# we're only getting the files we need, with some exclusions. This is can be
# more convenient than listing out every source file and folder. But you also
# have to update the exclude list if you change .dockerignore.
COPY --exclude=server . .
RUN npm run build

# This Dockerfile combines has two entrypoints: `server` and `tests`. You have
# to use `--target` on the command line or `build.target` in compose.yml to
# specify which one you want.
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