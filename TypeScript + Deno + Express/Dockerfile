FROM denoland/deno:alpine-1.37.2
WORKDIR /app
ENV NODE_ENV=production

COPY . .

RUN deno cache src/server.ts

EXPOSE 3000
CMD ["deno", "run", "--allow-all", "src/server.ts"]
