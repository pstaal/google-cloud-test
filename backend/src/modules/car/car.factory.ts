import { Factory } from '../../shared/factory/factory';
import { fakerNL as faker } from '@faker-js/faker';
import { CarEntity } from './car.entity';

export class CarFactory extends Factory<CarEntity> {
  private static id = 0;

  protected createEntity(
    overriddenValues: Partial<CarEntity>,
  ): CarEntity {
    const id = ++CarFactory.id;

    const entity = new CarEntity();
    entity.id = overriddenValues.id ?? id;
    entity.brand= overriddenValues.brand ?? faker.vehicle.manufacturer();
    entity.year = overriddenValues.year ?? faker.date.past().getFullYear();
    if (overriddenValues.drivers) entity.drivers = overriddenValues.drivers;
    else entity.drivers = [];

    return entity;
  }
}