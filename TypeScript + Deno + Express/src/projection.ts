import { Event } from "./entities/event.ts";

class Projection {
  private state: string = "";

  apply(event: Event): void {
    this.state += event.data;
  }

  getState(): string {
    return this.state;
  }
}

export { Projection };
