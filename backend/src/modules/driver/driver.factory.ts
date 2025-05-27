import { Factory } from '../../shared/factory/factory';
import { fakerNL as faker } from '@faker-js/faker';
import { DriverEntity } from './driver.entity';

export class DriverFactory extends Factory<DriverEntity> {
  private static id = 0;

  protected createEntity(
    overriddenValues: Partial<DriverEntity>,
  ): DriverEntity {
    const id = ++DriverFactory.id;

    const entity = new DriverEntity();
    entity.id = overriddenValues.id ?? id;
    entity.name = overriddenValues.name ?? faker.person.fullName();
    if (overriddenValues.cars) entity.cars = overriddenValues.cars;
    else entity.cars = [];

    return entity;
  }
}
