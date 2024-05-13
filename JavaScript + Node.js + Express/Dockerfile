FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
COPY tsconfig.json ./
RUN npm install

COPY ./src ./src
RUN npm run build

# ---- Release ----
FROM node:22-alpine
WORKDIR /app
COPY --from=build /app .
EXPOSE 3000
CMD ["node", "build/server.js"]
