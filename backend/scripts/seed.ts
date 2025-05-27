import { initializeNestApp } from './initialize-nest-app';
import { logFinished, logSuccessEntity } from './cli.logger'
import { CarModule } from '../src/modules/car/car.module';
import { DriverModule } from '../src/modules/driver/driver.module';
import { DriverRepository } from '../src/modules/driver/driver.repository';
import { DriverFactory } from '../../backend/src/modules/driver/driver.factory';
import { CarRepository } from '../src/modules/car/car.repository';
import { CarFactory } from '../src/modules/car/car.factory';


(async (): Promise<void> => {
  if (!process.env.NODE_ENV) process.env.NODE_ENV = 'dev';

  const app = await initializeNestApp({
    modules: [CarModule, DriverModule],
  });

  const insertedDrivers = await app
    .get(DriverRepository)
    .insert(new DriverFactory().generate(10, {}));

  logSuccessEntity('Drivers', insertedDrivers.identifiers);

  const insertedCar1 = await app
    .get(CarRepository)
    .insert(new CarFactory().generateSingle({drivers: [insertedDrivers[0], insertedDrivers[1]]}))

  const insertedCar2 = await app
    .get(CarRepository)
    .insert(new CarFactory().generateSingle({drivers: [insertedDrivers[2], insertedDrivers[3]]}))

  const insertedCar3 = await app
    .get(CarRepository)
    .insert(new CarFactory().generateSingle({drivers: [insertedDrivers[3], insertedDrivers[4]]}))


  logFinished('Successfully seeded all entities');

  await process.exit(0);
})();