FROM oven/bun:1.0.7-slim
WORKDIR /app
ENV NODE_ENV=production

COPY package*.json ./
COPY tsconfig.json ./
COPY bun.lockb ./
RUN bun install --production

COPY ./src ./src

EXPOSE 3000
CMD ["bun", "run", "src/server.ts"]
