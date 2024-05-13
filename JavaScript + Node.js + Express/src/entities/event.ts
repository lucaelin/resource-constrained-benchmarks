// src/event.ts
import { Entity, PrimaryGeneratedColumn, Column, Index } from 'typeorm';

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