import { Injectable } from '@nestjs/common';
import { CarRepository } from './car.repository';


@Injectable()
export class CarService {
  public constructor(private readonly carRepository: CarRepository) {}
  async readAll(){
    return await this.carRepository.find();
  }

}