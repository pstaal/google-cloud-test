import { Controller, Get } from '@nestjs/common';
import { DriverService } from './driver.service';


@Controller('api/drivers')
export class DriverController {
  public constructor( private readonly driverService: DriverService
  ) {}
  @Get()
  async readAll(
  ) {
  return await this.driverService.readAll()
  }
}