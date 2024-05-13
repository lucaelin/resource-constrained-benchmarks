import { Event } from "./entities/event";

class Aggregate {
  private aggregateUuid: string;
  private state: string = "";

  constructor(aggregateUuid: string) {
    this.aggregateUuid = aggregateUuid;
  }

  apply(event: Event): void {
    this.state += event.data;
  }

  getAggregateUuid(): string {
    return this.aggregateUuid;
  }

  getState(): string {
    return this.state;
  }
}

export { Aggregate };