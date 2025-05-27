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
    .save(new DriverFactory().generate(10, {}));

  logSuccessEntity('Drivers', insertedDrivers);

  const insertedCar1 = await app
    .get(CarRepository)
    .save(new CarFactory().generateSingle({ drivers: insertedDrivers.slice(0, 2)}))

  const insertedCar2 = await app
    .get(CarRepository)
    .save(new CarFactory().generateSingle({ drivers: insertedDrivers.slice(2, 4)}))

  const insertedCar3 = await app
    .get(CarRepository)
    .save(new CarFactory().generateSingle({ drivers: insertedDrivers.slice(4, 6)}))

  const insertedCar5 = await app
    .get(CarRepository)
    .save(new CarFactory().generateSingle({ drivers: insertedDrivers.slice(6, 8)}))


  logFinished('Successfully seeded all entities');

  await process.exit(0);
})();

