import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CarEntity } from './car.entity';
import { CarRepository } from './car.repository';
import { CarService } from './car.service';
import { CarController } from './car.controller';

@Module({
  imports: [TypeOrmModule.forFeature([CarEntity])],
  providers: [CarRepository, CarService],
  controllers: [CarController],
  exports: [CarService],
})
export class CarModule {}