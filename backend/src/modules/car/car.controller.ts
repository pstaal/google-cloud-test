import { Controller, Get } from '@nestjs/common';
import { CarService } from './car.service';


@Controller('api/cars')
export class CarController {
  public constructor( private readonly carService: CarService
  ) {}
  @Get()
  async readAll(
  ) {
    //return await this.carService.readAll()
    return 'Hello Cars 3'
  }
}
