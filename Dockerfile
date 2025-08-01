# syntax=docker/dockerfile:1

# Build Stage 0
# Build the application.
FROM node:22 AS base

WORKDIR /usr/app

COPY . .

# Build Stage 1
FROM base AS build

WORKDIR /usr/app

# Install all dependencies, including development dependencies, since they will
# be needed to compile the application.
RUN npm ci --no-audit --no-fund

RUN npm run compile

# Build Stage 2
# Install production dependencies
FROM base AS prod_deps

WORKDIR /usr/app

COPY . .

# Clean up and install only production dependencies.
RUN npm ci --omit=dev --no-audit --no-fund --ignore-scripts

# Build Stage 3
# Copy production dependencies and build artifacts from previous stage.
FROM base AS runtime

WORKDIR /usr/app

COPY . .

COPY --from=prod_deps /usr/app/node_modules ./node_modules
COPY --from=build /usr/app/dist ./dist

EXPOSE 3000
CMD ["npm", "start"]
