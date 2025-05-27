import { Controller, Get } from '@nestjs/common';


@Controller('drivers')
export class DriverController {
  public constructor(
  ) {}
  @Get()
  async readAll(
  ) {

  }
}