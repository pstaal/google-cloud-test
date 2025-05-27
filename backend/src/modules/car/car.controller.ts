import { Controller, Get } from '@nestjs/common';


@Controller('cars')
export class CarController {
  public constructor(
  ) {}
  @Get()
  async readAll(
  ) {

  }
}
