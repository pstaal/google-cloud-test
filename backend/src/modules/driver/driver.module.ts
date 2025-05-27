import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DriverEntity } from './driver.entity';
import { DriverRepository } from './driver.repository';
import { DriverService } from './driver.service';
import { DriverController } from './driver.controller';

@Module({
  imports: [TypeOrmModule.forFeature([DriverEntity])],
  providers: [DriverRepository, DriverService],
  controllers: [DriverController],
  exports: [DriverService],
})
export class DriverModule {}