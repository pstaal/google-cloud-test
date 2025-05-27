import { Injectable } from '@nestjs/common';
import { DataSource, Repository } from 'typeorm';
import { CarEntity } from './car.entity';

@Injectable()
export class CarRepository extends Repository<CarEntity> {
  public constructor(private dataSource: DataSource) {
    super(CarEntity, dataSource.createEntityManager());
  }
}