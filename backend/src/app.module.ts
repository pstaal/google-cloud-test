import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import process from "node:process";
import { CarModule } from './modules/car/car.module';
import { DriverModule } from './modules/driver/driver.module';

@Module({
  imports: [ConfigModule.forRoot({
    envFilePath: `env/${process.env.NODE_ENV}.env`,
    isGlobal: true,
  }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: async (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.getOrThrow('TYPEORM_HOST'),
        port: configService.getOrThrow('TYPEORM_PORT'),
        username: configService.getOrThrow('TYPEORM_USERNAME'),
        password: configService.getOrThrow('TYPEORM_PASSWORD'),
        database: configService.getOrThrow('TYPEORM_DATABASE'),
        autoLoadEntities: true,
        synchronize: configService.getOrThrow('SYNCHRONIZE_DATABASE'),
        logging: true,
      }),
    }), CarModule, DriverModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
