// src/event.ts
import { Column, Entity, Index, PrimaryGeneratedColumn } from "npm:typeorm";

@Entity()
export class Event {
  @PrimaryGeneratedColumn()
  id!: number;

  @Index()
  @Column()
  aggregateUuid!: string;

  @Column()
  data!: string;
}
