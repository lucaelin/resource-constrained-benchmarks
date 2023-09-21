// src/server.ts
import { createConnection } from 'typeorm';
import express from 'express';
import { json } from 'body-parser';
import { registerControllers } from './controller';
import {Event} from './entities/event'

const port = 8080;

export async function createApp() {
  const app = express();

  app.use(json());

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
  entities: [Event] // Specify your entities directly
}).then(async () => {
  const app = await createApp();
  
  app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
  });
}).catch(error => console.log(error));