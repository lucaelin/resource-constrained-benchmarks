// src/eventService.ts
import { getRepository } from "npm:typeorm";
import { Event } from "./entities/event.ts";

export class EventService {
  private repository = getRepository(Event);

  async findByAggregateUuid(aggregateUuid: string): Promise<Event[]> {
    return this.repository.find({ where: { aggregateUuid } });
  }

  async save(event: Event): Promise<Event> {
    return this.repository.save(event);
  }
}
