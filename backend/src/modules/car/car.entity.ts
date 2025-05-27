import { Entity, Column, PrimaryGeneratedColumn, ManyToMany, JoinTable } from 'typeorm';
import { DriverEntity } from '../driver/driver.entity';

@Entity()
export class CarEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  brand: string;

  @Column()
  year: number;

  @ManyToMany(() => DriverEntity, (driver) => driver.cars)
  @JoinTable()
  drivers: DriverEntity[]
}