// src/controller.ts
import { Express } from 'express';
import { EventService } from './eventService';
import { Command } from './command';
import { Aggregate } from './aggregate';
import { Projection } from './projection';
import { Event } from './entities/event'

export function registerControllers(app: Express) {
  const eventService = new EventService();

  app.post('/:uuid/command', async (req, res) => {
    const { uuid } = req.params;
    const command = Object.assign(new Command(uuid), req.body);

    const events = await eventService.findByAggregateUuid(uuid);
    const aggregate = new Aggregate(uuid);
    events.forEach(event => aggregate.apply(event));

    const event = new Event();
    event.aggregateUuid = uuid;
    event.data = command.data;
    aggregate.apply(event);

    const savedEvent = await eventService.save(event);

    res.status(201).json(savedEvent);
  });

  app.get('/:uuid/query', async (req, res) => {
    const { uuid } = req.params;

    const events = await eventService.findByAggregateUuid(uuid);
    const projection = new Projection();
    events.forEach(event => projection.apply(event));

    res.status(200).json(projection.getState());
  });
}
