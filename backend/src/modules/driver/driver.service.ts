import { Injectable } from '@nestjs/common';
import { DriverRepository } from './driver.repository';


@Injectable()
export class DriverService {
  public constructor(private readonly driverRepository: DriverRepository) {}
  async readAll(){
    return await this.driverRepository.find();
  }

}