// src/server.ts
import "https://deno.land/x/reflect_metadata@v0.1.12/mod.ts";
import "npm:pg";
import { createConnection } from "npm:typeorm";
import express from "npm:express";
import bodyParser from "npm:body-parser";
import { registerControllers } from "./controller.ts";
import { Event } from "./entities/event.ts";

const port = 8080;

export async function createApp() {
  const app = express();

  app.use(bodyParser.json());

  registerControllers(app);

  return app;
}

createConnection({
  type: "postgres",
  host: "db",
  port: 5432,
  username: "dbuser",
  password: "dbpass",
  database: "apples",
  synchronize: true,
  logging: false,
  entities: [Event], // Specify your entities directly
}).then(async () => {
  const app = await createApp();

  app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
  });
}).catch((error) => console.log(error));
