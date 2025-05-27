import { Injectable } from '@nestjs/common';
import { DataSource, Repository } from 'typeorm';
import { DriverEntity } from './driver.entity';

@Injectable()
export class DriverRepository extends Repository<DriverEntity> {
  public constructor(private dataSource: DataSource) {
    super(DriverEntity, dataSource.createEntityManager());
  }
}