import { Entity, Column, PrimaryGeneratedColumn, ManyToMany, JoinTable } from 'typeorm';
import { CarEntity } from '../car/car.entity';

@Entity()
export class DriverEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @ManyToMany(() => CarEntity, (car) => car.drivers, {
    cascade: true,
  })
  cars: CarEntity[]
}