import type { INestApplication, Provider, Type } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Test } from '@nestjs/testing';
import { ConfigModule, ConfigService } from '@nestjs/config';


type AppOptions = {
  modules?: Type[];
  providers?: Provider[];
  controllers?: Type[];
};

export async function initializeNestApp(
  options: AppOptions,
): Promise<INestApplication> {
  const moduleFixture = await Test.createTestingModule({
    imports: [
      ConfigModule.forRoot({
        envFilePath: `env/dev.env`,
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
          synchronize: true,
          dropSchema: true,
          autoLoadEntities: true,
        }),
      }),
      ...(options.modules ?? []),
    ],
    providers: options.providers ?? [],
    controllers: options.controllers ?? [],
  }).compile();

  const app = moduleFixture.createNestApplication();
  await app.init();
  return app;
}
